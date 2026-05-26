<?php

namespace App\Http\Controllers;

use App\Models\Booking;
use App\Models\Service;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class BookingController extends BaseController
{
    public function index(Request $request)
    {
        $user = $request->user();

        $query = Booking::query()->with(['service.technician', 'customer', 'technician', 'payment', 'review', 'chat']);

        if ($user && $user->role === 'customer') {
            $query->where('customer_id', $user->id);
        } elseif ($user && $user->role === 'technician') {
            $query->where('technician_id', $user->id);
        }

        if ($request->filled('status')) {
            $query->where('status', $request->string('status'));
        }

        return $this->paginated(
            $query->latest()->paginate($request->integer('per_page', 15)),
            'Bookings retrieved successfully'
        );
    }

    public function store(Request $request)
    {
        $user = $request->user();

        $validated = $request->validate([
            'service_id' => ['required', 'exists:services,id'],
            'scheduled_at' => ['required', 'date'],
            'address' => ['required', 'string', 'max:500'],
            'latitude' => ['nullable', 'numeric'],
            'longitude' => ['nullable', 'numeric'],
            'notes' => ['nullable', 'string', 'max:2000'],
            'amount' => ['nullable', 'numeric', 'min:0'],
            'currency' => ['nullable', 'string', 'size:3'],
        ]);

        $service = Service::query()->findOrFail($validated['service_id']);

        $booking = Booking::create([
            'service_id' => $service->id,
            'customer_id' => $user?->id,
            'technician_id' => $service->technician_id,
            'scheduled_at' => $validated['scheduled_at'],
            'status' => 'pending',
            'address' => $validated['address'],
            'latitude' => $validated['latitude'] ?? null,
            'longitude' => $validated['longitude'] ?? null,
            'notes' => $validated['notes'] ?? null,
            'amount' => $validated['amount'] ?? $service->price,
            'currency' => $validated['currency'] ?? $service->currency ?? 'USD',
            'otp_code' => (string) random_int(100000, 999999),
        ]);

        return $this->created($booking->load(['service', 'customer', 'technician']), 'Booking created successfully');
    }

    public function show(Request $request, Booking $booking)
    {
        if (!$this->canAccess($request->user()?->id, $request->user()?->role, $booking)) {
            return $this->error('Forbidden', [], 403);
        }

        return $this->success($booking->load(['service.technician', 'customer', 'technician', 'payment', 'review', 'chat.messages']), 'Booking retrieved successfully');
    }
>>>>>>> REPLACE

    public function update(Request $request, Booking $booking)
    {
        $user = $request->user();

        if (!$this->canAccess($user?->id, $user?->role, $booking)) {
            return $this->error('Forbidden', [], 403);
        }

        $validated = $request->validate([
            'scheduled_at' => ['sometimes', 'date'],
            'address' => ['sometimes', 'string', 'max:500'],
            'latitude' => ['nullable', 'numeric'],
            'longitude' => ['nullable', 'numeric'],
            'notes' => ['nullable', 'string', 'max:2000'],
            'status' => ['sometimes', Rule::in(['pending', 'accepted', 'rejected', 'confirmed', 'in_progress', 'completed', 'cancelled'])],
        ]);

        $booking->update($validated);

        return $this->success($booking->fresh()->load(['service', 'customer', 'technician']), 'Booking updated successfully');
    }

    public function destroy(Request $request, Booking $booking)
    {
        $user = $request->user();

        if (!$this->canAccess($user?->id, $user?->role, $booking)) {
            return $this->error('Forbidden', [], 403);
        }

        $booking->update([
            'status' => 'cancelled',
            'cancelled_at' => now(),
            'cancel_reason' => $request->input('cancel_reason', 'Cancelled by user'),
        ]);

        return $this->success(null, 'Booking cancelled successfully');
    }

    public function confirm(Request $request, Booking $booking)
    {
        if ($request->user()?->id !== $booking->technician_id && $request->user()?->role !== 'admin') {
            return $this->error('Forbidden', [], 403);
        }

        $validated = $request->validate([
            'confirmation_code' => ['nullable', 'string', 'max:50'],
        ]);

        $booking->update([
            'status' => 'confirmed',
            'confirmation_code' => $validated['confirmation_code'] ?? $booking->confirmation_code,
            'confirmed_at' => now(),
        ]);

        return $this->success($booking->fresh(), 'Booking confirmed successfully');
    }

    public function rate(Request $request, Booking $booking)
    {
        if (!$this->canAccess($request->user()?->id, $request->user()?->role, $booking)) {
            return $this->error('Forbidden', [], 403);
        }

        $validated = $request->validate([
            'rating' => ['required', 'numeric', 'min:1', 'max:5'],
            'review' => ['nullable', 'string', 'max:2000'],
        ]);
>>>>>>> REPLACE

        $booking->update([
            'rating' => $validated['rating'],
            'reviewed_at' => now(),
        ]);

        return $this->success([
            'booking' => $booking->fresh(),
            'review' => $validated['review'] ?? null,
        ], 'Booking rated successfully');
    }

    public function status(Request $request, Booking $booking)
    {
        if (!$this->canAccess($request->user()?->id, $request->user()?->role, $booking)) {
            return $this->error('Forbidden', [], 403);
        }

        return $this->success([
            'id' => $booking->id,
            'status' => $booking->status,
            'confirmed_at' => $booking->confirmed_at,
            'completed_at' => $booking->completed_at,
            'cancelled_at' => $booking->cancelled_at,
        ], 'Booking status retrieved successfully');
    }
>>>>>>> REPLACE

    private function canAccess(?int $userId, ?string $role, Booking $booking): bool
    {
        if ($role === 'admin') {
            return true;
        }

        return $userId !== null && ($booking->customer_id === $userId || $booking->technician_id === $userId);
    }
}