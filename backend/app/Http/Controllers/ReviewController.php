<?php

namespace App\Http\Controllers;

use App\Models\Booking;
use App\Models\Review;
use Illuminate\Http\Request;

class ReviewController extends BaseController
{
    public function index(Request $request)
    {
        $query = Review::query()->with(['booking', 'service', 'customer', 'technician']);

        if ($request->filled('service_id')) {
            $query->where('service_id', $request->integer('service_id'));
        }

        if ($request->filled('technician_id')) {
            $query->where('technician_id', $request->integer('technician_id'));
        }

        return $this->paginated(
            $query->latest()->paginate($request->integer('per_page', 15)),
            'Reviews retrieved successfully'
        );
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'booking_id' => ['required', 'exists:bookings,id'],
            'rating' => ['required', 'numeric', 'min:1', 'max:5'],
            'comment' => ['nullable', 'string', 'max:5000'],
            'is_public' => ['nullable', 'boolean'],
        ]);

        $booking = Booking::query()->findOrFail($validated['booking_id']);

        $review = Review::create([
            'booking_id' => $booking->id,
            'service_id' => $booking->service_id,
            'customer_id' => $request->user()->id,
            'technician_id' => $booking->technician_id,
            'rating' => $validated['rating'],
            'comment' => $validated['comment'] ?? null,
            'is_public' => $validated['is_public'] ?? true,
        ]);

        return $this->created($review->load(['booking', 'service', 'customer', 'technician']), 'Review created successfully');
    }

    public function show(Request $request, Review $review)
    {
        if (!$this->canAccess($request->user()?->id, $request->user()?->role, $review)) {
            return $this->error('Forbidden', [], 403);
        }

        return $this->success($review->load(['booking', 'service', 'customer', 'technician']), 'Review retrieved successfully');
    }
>>>>>>> REPLACE

    public function update(Request $request, Review $review)
    {
        if (!$this->canAccess($request->user()?->id, $request->user()?->role, $review)) {
            return $this->error('Forbidden', [], 403);
        }

        $validated = $request->validate([
            'rating' => ['sometimes', 'numeric', 'min:1', 'max:5'],
            'comment' => ['nullable', 'string', 'max:5000'],
            'is_public' => ['nullable', 'boolean'],
            'response' => ['nullable', 'string', 'max:5000'],
        ]);
>>>>>>> REPLACE

        $review->update($validated);

        return $this->success($review->fresh(), 'Review updated successfully');
    }

    public function destroy(Request $request, Review $review)
    {
        if (!$this->canAccess($request->user()?->id, $request->user()?->role, $review)) {
            return $this->error('Forbidden', [], 403);
        }

        $review->delete();

        return $this->success(null, 'Review deleted successfully');
    }

    private function canAccess(?int $userId, ?string $role, Review $review): bool
    {
        return $role === 'admin'
            || ($userId !== null && ($review->customer_id === $userId || $review->technician_id === $userId));
    }
}
>>>>>>> REPLACE
>>>>>>> REPLACE