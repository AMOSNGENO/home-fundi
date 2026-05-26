<?php

namespace App\Http\Controllers;

use App\Models\Booking;
use App\Models\Review;
use App\Models\Service;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;

class BookingController extends BaseController
{
    /**
     * List bookings for the current user or all bookings for admins.
     */
    public function index(Request $request): JsonResponse
    {
        $user = auth('api')->user();
        $query = Booking::query()->with(['customer', 'technician', 'service']);

        if (! $user->isAdmin()) {
            if ($user->isTechnician()) {
                $query->where('technician_id', $user->id);
            } else {
                $query->where('customer_id', $user->id);
            }
        }

        $items = $query->latest('created_at')->get();

        return $this->sendResponse([
            'items' => $items,
            'total' => $items->count(),
        ], 'Bookings retrieved successfully');
    }

    /**
     * Create a new booking.
     */
    public function store(Request $request): JsonResponse
    {
        $user = auth('api')->user();

        $validated = $request->validate([
            'service_id' => ['required', 'integer', 'exists:services,id'],
            'service_date' => ['required', 'date'],
            'service_start_time' => ['required', 'date_format:H:i'],
            'estimated_duration_minutes' => ['nullable', 'integer', 'min:1'],
            'service_end_time' => ['nullable', 'date_format:H:i'],
            'customer_location_latitude' => ['nullable', 'numeric'],
            'customer_location_longitude' => ['nullable', 'numeric'],
            'service_address' => ['required', 'string', 'max:500'],
            'base_price' => ['nullable', 'numeric', 'min:0'],
            'tax_amount' => ['nullable', 'numeric', 'min:0'],
            'total_price' => ['required', 'numeric', 'min:0'],
            'discount_amount' => ['nullable', 'numeric', 'min:0'],
            'description' => ['nullable', 'string'],
        ]);

        $service = Service::find($validated['service_id']);

        if (! $service || ! $service->isActive()) {
            return $this->sendError('Selected service is not available', [], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $booking = Booking::create([
            'booking_reference' => 'BK-' . strtoupper(Str::random(10)),
            'customer_id' => $user->id,
            'technician_id' => null,
            'service_id' => $validated['service_id'],
            'status' => 'pending',
            'service_date' => $validated['service_date'],
            'service_start_time' => $validated['service_start_time'],
            'estimated_duration_minutes' => $validated['estimated_duration_minutes'] ?? null,
            'service_end_time' => $validated['service_end_time'] ?? null,
            'customer_location_latitude' => $validated['customer_location_latitude'] ?? null,
            'customer_location_longitude' => $validated['customer_location_longitude'] ?? null,
            'service_address' => $validated['service_address'],
            'base_price' => $validated['base_price'] ?? null,
            'tax_amount' => $validated['tax_amount'] ?? null,
            'total_price' => $validated['total_price'],
            'discount_amount' => $validated['discount_amount'] ?? 0,
            'description' => $validated['description'] ?? null,
            'otp_code' => (string) random_int(100000, 999999),
            'otp_verified' => false,
        ]);

        return $this->sendResponse(
            $booking->load(['customer', 'technician', 'service']),
            'Booking created successfully',
            Response::HTTP_CREATED
        );
    }

    /**
     * Show a booking.
     */
    public function show(int $id): JsonResponse
    {
        $booking = Booking::with(['customer', 'technician', 'service'])->find($id);

        if (! $booking) {
            return $this->sendNotFound('Booking not found');
        }

        $user = auth('api')->user();

        if (! $user->isAdmin() && $booking->customer_id !== $user->id && $booking->technician_id !== $user->id) {
            return $this->sendError('You are not authorized to view this booking', [], Response::HTTP_FORBIDDEN);
        }

        return $this->sendResponse($booking, 'Booking retrieved successfully');
    }

    /**
     * Update a booking.
     */
    public function update(Request $request, int $id): JsonResponse
    {
        $booking = Booking::find($id);

        if (! $booking) {
            return $this->sendNotFound('Booking not found');
        }

        $user = auth('api')->user();

        if (! $user->isAdmin() && $booking->customer_id !== $user->id) {
            return $this->sendError('You are not authorized to update this booking', [], Response::HTTP_FORBIDDEN);
        }

        if ($booking->isCompleted() || $booking->isCancelled()) {
            return $this->sendError('Completed or cancelled bookings cannot be updated', [], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $validated = $request->validate([
            'service_id' => ['sometimes', 'integer', 'exists:services,id'],
            'service_date' => ['sometimes', 'date'],
            'service_start_time' => ['sometimes', 'date_format:H:i'],
            'estimated_duration_minutes' => ['sometimes', 'nullable', 'integer', 'min:1'],
            'service_end_time' => ['sometimes', 'nullable', 'date_format:H:i'],
            'customer_location_latitude' => ['sometimes', 'nullable', 'numeric'],
            'customer_location_longitude' => ['sometimes', 'nullable', 'numeric'],
            'service_address' => ['sometimes', 'string', 'max:500'],
            'base_price' => ['sometimes', 'nullable', 'numeric', 'min:0'],
            'tax_amount' => ['sometimes', 'nullable', 'numeric', 'min:0'],
            'total_price' => ['sometimes', 'numeric', 'min:0'],
            'discount_amount' => ['sometimes', 'nullable', 'numeric', 'min:0'],
            'description' => ['sometimes', 'nullable', 'string'],
            'cancellation_reason' => ['sometimes', 'nullable', 'string'],
            'cancelled_by' => ['sometimes', Rule::in(['customer', 'technician', 'system'])],
            'cancelled_at' => ['sometimes', 'nullable', 'date'],
            'otp_code' => ['sometimes', 'nullable', 'string', 'max:6'],
            'otp_verified' => ['sometimes', 'boolean'],
            'status' => ['sometimes', Rule::in(['pending', 'accepted', 'in_progress', 'completed', 'cancelled', 'no_show'])],
        ]);

        $booking->fill($validated);
        $booking->save();

        return $this->sendResponse(
            $booking->fresh()->load(['customer', 'technician', 'service']),
            'Booking updated successfully'
        );
    }

    /**
     * Cancel a booking.
     */
    public function cancel(Request $request, int $id): JsonResponse
    {
        $booking = Booking::find($id);

        if (! $booking) {
            return $this->sendNotFound('Booking not found');
        }

        $user = auth('api')->user();

        if (! $user->isAdmin() && $booking->customer_id !== $user->id) {
            return $this->sendError('You are not authorized to cancel this booking', [], Response::HTTP_FORBIDDEN);
        }

        if ($booking->isCompleted()) {
            return $this->sendError('Completed bookings cannot be cancelled', [], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $validated = $request->validate([
            'cancellation_reason' => ['nullable', 'string'],
        ]);

        $booking->status = 'cancelled';
        $booking->cancellation_reason = $validated['cancellation_reason'] ?? $booking->cancellation_reason;
        $booking->cancelled_by = $user->isTechnician() ? 'technician' : ($user->isAdmin() ? 'system' : 'customer');
        $booking->cancelled_at = now();
        $booking->save();

        return $this->sendResponse($booking->fresh(), 'Booking cancelled successfully');
    }

    /**
     * Confirm a booking.
     */
    public function confirm(int $id): JsonResponse
    {
        $booking = Booking::find($id);

        if (! $booking) {
            return $this->sendNotFound('Booking not found');
        }

        $user = auth('api')->user();

        if (! $user->isAdmin() && $booking->customer_id !== $user->id && $booking->technician_id !== $user->id) {
            return $this->sendError('You are not authorized to confirm this booking', [], Response::HTTP_FORBIDDEN);
        }

        if ($booking->status !== 'pending') {
            return $this->sendError('Only pending bookings can be confirmed', [], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $booking->status = 'accepted';
        $booking->save();

        return $this->sendResponse($booking->fresh(), 'Booking confirmed successfully');
    }

    /**
     * Rate a completed booking.
     */
    public function rate(Request $request, int $id): JsonResponse
    {
        $booking = Booking::find($id);

        if (! $booking) {
            return $this->sendNotFound('Booking not found');
        }

        $user = auth('api')->user();

        if ($booking->customer_id !== $user->id && ! $user->isAdmin()) {
            return $this->sendError('You are not authorized to rate this booking', [], Response::HTTP_FORBIDDEN);
        }

        if (! $booking->isCompleted()) {
            return $this->sendError('Only completed bookings can be rated', [], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $validated = $request->validate([
            'rating' => ['required', 'numeric', 'min:1', 'max:5'],
            'review' => ['nullable', 'string'],
            'is_anonymous' => ['sometimes', 'boolean'],
        ]);

        if (! $booking->technician_id) {
            return $this->sendError('Booking must be assigned to a technician before it can be rated', [], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $review = Review::updateOrCreate(
            ['booking_id' => $booking->id],
            [
                'reviewer_id' => $user->id,
                'reviewee_id' => $booking->technician_id,
                'rating' => $validated['rating'],
                'comment' => $validated['review'] ?? null,
                'is_anonymous' => $validated['is_anonymous'] ?? false,
            ]
        );

        return $this->sendResponse($review, 'Booking rated successfully', Response::HTTP_CREATED);
    }

    /**
     * Return the booking status.
     */
    public function status(int $id): JsonResponse
    {
        $booking = Booking::find($id);

        if (! $booking) {
            return $this->sendNotFound('Booking not found');
        }

        $user = auth('api')->user();

        if (! $user->isAdmin() && $booking->customer_id !== $user->id && $booking->technician_id !== $user->id) {
            return $this->sendError('You are not authorized to view this booking', [], Response::HTTP_FORBIDDEN);
        }

        return $this->sendResponse([
            'id' => $booking->id,
            'booking_reference' => $booking->booking_reference,
            'status' => $booking->status,
            'service_date' => $booking->service_date,
            'service_start_time' => $booking->service_start_time,
            'service_end_time' => $booking->service_end_time,
            'cancelled_at' => $booking->cancelled_at,
            'otp_verified' => $booking->otp_verified,
        ], 'Booking status retrieved successfully');
    }
}
