<?php

namespace App\Http\Controllers;

use App\Models\Booking;
use App\Models\Payment;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class PaymentController extends BaseController
{
    public function index(Request $request)
    {
        $user = $request->user();

        $query = Payment::query()->with(['booking.service', 'user']);

        if ($user->role === 'customer') {
            $query->where('user_id', $user->id);
        } elseif ($user->role !== 'admin') {
            $query->where('user_id', $user->id);
        }

        return $this->paginated(
            $query->latest()->paginate($request->integer('per_page', 15)),
            'Payments retrieved successfully'
        );
    }
>>>>>>> REPLACE

    public function store(Request $request)
    {
        $validated = $request->validate([
            'booking_id' => ['required', 'exists:bookings,id'],
            'amount' => ['required', 'numeric', 'min:0'],
            'currency' => ['nullable', 'string', 'size:3'],
            'method' => ['required', 'string', 'max:50'],
            'provider' => ['nullable', 'string', 'max:50'],
            'reference' => ['nullable', 'string', 'max:100'],
            'metadata' => ['nullable', 'array'],
        ]);

        $booking = Booking::query()->findOrFail($validated['booking_id']);

        $payment = Payment::create([
            'booking_id' => $booking->id,
            'user_id' => $request->user()->id,
            'amount' => $validated['amount'],
            'currency' => $validated['currency'] ?? 'USD',
            'method' => $validated['method'],
            'provider' => $validated['provider'] ?? 'manual',
            'reference' => $validated['reference'] ?? null,
            'status' => 'pending',
            'metadata' => $validated['metadata'] ?? [],
        ]);

        return $this->created($payment->load(['booking', 'user']), 'Payment created successfully');
    }

    public function show(Request $request, Payment $payment)
    {
        if (!$this->canAccess($request->user()?->id, $request->user()?->role, $payment)) {
            return $this->error('Forbidden', [], 403);
        }

        return $this->success($payment->load(['booking.service', 'user']), 'Payment retrieved successfully');
    }
>>>>>>> REPLACE

    public function verify(Request $request, Payment $payment)
    {
        if ($request->user()?->role !== 'admin' && $request->user()?->id !== $payment->user_id) {
            return $this->error('Forbidden', [], 403);
        }

        $validated = $request->validate([
            'provider_reference' => ['nullable', 'string', 'max:100'],
        ]);
>>>>>>> REPLACE

        $payment->update([
            'status' => 'verified',
            'reference' => $validated['provider_reference'] ?? $payment->reference,
            'verified_at' => now(),
        ]);

        return $this->success($payment->fresh(), 'Payment verified successfully');
    }

    public function refund(Request $request, Payment $payment)
    {
        if ($request->user()?->role !== 'admin') {
            return $this->error('Forbidden', [], 403);
        }

        $payment->update([
            'status' => 'refunded',
            'refunded_at' => now(),
        ]);

        return $this->success($payment->fresh(), 'Payment refunded successfully');
    }

    private function canAccess(?int $userId, ?string $role, Payment $payment): bool
    {
        return $role === 'admin' || ($userId !== null && $payment->user_id === $userId);
    }
}
>>>>>>> REPLACE