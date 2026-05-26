<?php

namespace App\Http\Controllers;

use App\Models\Booking;
use App\Models\Review;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Validation\Rule;

class ReviewController extends BaseController
{
    /**
     * List reviews relevant to the current user.
     */
    public function index(): JsonResponse
    {
        $user = auth('api')->user();

        $query = Review::query()->with(['booking', 'reviewer', 'reviewee']);

        if (! $user->isAdmin()) {
            $query->where('reviewer_id', $user->id)
                ->orWhere('reviewee_id', $user->id);
        }

        $items = $query->latest('created_at')->get();

        return $this->sendResponse([
            'items' => $items,
            'total' => $items->count(),
        ], 'Reviews retrieved successfully');
    }

    /**
     * Create or update a review for a completed booking.
     */
    public function store(Request $request): JsonResponse
    {
        $user = auth('api')->user();

        $validated = $request->validate([
            'booking_id' => ['required', 'integer', 'exists:bookings,id'],
            'rating' => ['required', 'numeric', 'min:1', 'max:5'],
            'comment' => ['nullable', 'string'],
            'review' => ['nullable', 'string'],
            'is_anonymous' => ['sometimes', 'boolean'],
        ]);

        $booking = Booking::find($validated['booking_id']);

        if (! $booking) {
            return $this->sendNotFound('Booking not found');
        }

        if (! $user->isAdmin() && $booking->customer_id !== $user->id) {
            return $this->sendError('You are not authorized to review this booking', [], Response::HTTP_FORBIDDEN);
        }

        if (! $booking->isCompleted()) {
            return $this->sendError('Only completed bookings can be reviewed', [], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        if (! $booking->technician_id) {
            return $this->sendError('Booking must be assigned to a technician before it can be reviewed', [], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $comment = $validated['comment'] ?? $validated['review'] ?? null;

        $review = Review::updateOrCreate(
            [
                'booking_id' => $booking->id,
                'reviewer_id' => $user->id,
            ],
            [
                'reviewee_id' => $booking->technician_id,
                'rating' => $validated['rating'],
                'comment' => $comment,
                'is_anonymous' => $validated['is_anonymous'] ?? false,
            ]
        );

        return $this->sendResponse(
            $review->fresh()->load(['booking', 'reviewer', 'reviewee']),
            'Review created successfully',
            $review->wasRecentlyCreated ? Response::HTTP_CREATED : Response::HTTP_OK
        );
    }

    /**
     * Show a review.
     */
    public function show(int $id): JsonResponse
    {
        $review = Review::with(['booking', 'reviewer', 'reviewee'])->find($id);

        if (! $review) {
            return $this->sendNotFound('Review not found');
        }

        $user = auth('api')->user();

        if (! $user->isAdmin() && $review->reviewer_id !== $user->id && $review->reviewee_id !== $user->id) {
            return $this->sendError('You are not authorized to view this review', [], Response::HTTP_FORBIDDEN);
        }

        return $this->sendResponse($review, 'Review retrieved successfully');
    }

    /**
     * Update a review.
     */
    public function update(Request $request, int $id): JsonResponse
    {
        $review = Review::find($id);

        if (! $review) {
            return $this->sendNotFound('Review not found');
        }

        $user = auth('api')->user();

        if (! $user->isAdmin() && $review->reviewer_id !== $user->id) {
            return $this->sendError('You are not authorized to update this review', [], Response::HTTP_FORBIDDEN);
        }

        $validated = $request->validate([
            'rating' => ['sometimes', 'numeric', 'min:1', 'max:5'],
            'comment' => ['nullable', 'string'],
            'review' => ['nullable', 'string'],
            'is_anonymous' => ['sometimes', 'boolean'],
        ]);

        if (array_key_exists('rating', $validated)) {
            $review->rating = $validated['rating'];
        }

        if (array_key_exists('comment', $validated) || array_key_exists('review', $validated)) {
            $review->comment = $validated['comment'] ?? $validated['review'] ?? null;
        }

        if (array_key_exists('is_anonymous', $validated)) {
            $review->is_anonymous = $validated['is_anonymous'];
        }

        $review->save();

        return $this->sendResponse(
            $review->fresh()->load(['booking', 'reviewer', 'reviewee']),
            'Review updated successfully'
        );
    }

    /**
     * Delete a review.
     */
    public function delete(int $id): JsonResponse
    {
        $review = Review::find($id);

        if (! $review) {
            return $this->sendNotFound('Review not found');
        }

        $user = auth('api')->user();

        if (! $user->isAdmin() && $review->reviewer_id !== $user->id) {
            return $this->sendError('You are not authorized to delete this review', [], Response::HTTP_FORBIDDEN);
        }

        $review->delete();

        return $this->sendResponse([], 'Review deleted successfully');
    }
}
