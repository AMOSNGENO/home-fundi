<?php

namespace App\Http\Controllers;

use App\Models\Payment;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;

class PaymentController extends BaseController
{
    /**
     * List payments for the current user.
     */
    public function index(): JsonResponse
    {
        $user = auth('api')->user();
        $query = Payment::query()->with(['booking', 'user']);

        if (! $user->isAdmin()) {
            $query->where('user_id', $user->id);
        }

        $items = $query->latest('created_at')->get();

        return $this->sendResponse([
            'items' => $items,
            'total' => $items->count(),
        ], 'Payments retrieved successfully');
    }

    /**
     * Create a payment record.
     */
    public function store(Request $request): JsonResponse
    {
        $user = auth('api')->user();

        $validated = $request->validate([
            'booking_id' => ['nullable', 'integer', 'exists:bookings,id'],
            'transaction_type' => ['required', Rule::in(['payment', 'refund', 'wallet_credit', 'wallet_debit', 'earning'])],
            'payment_method' => ['required', Rule::in(['credit_card', 'debit_card', 'upi', 'net_banking', 'wallet', 'cash'])],
            'amount' => ['required', 'numeric', 'min:0'],
            'currency' => ['sometimes', 'string', 'size:3'],
            'description' => ['nullable', 'string'],
        ]);

        $payment = Payment::create([
            'transaction_reference' => 'TX-' . strtoupper(Str::random(12)),
            'booking_id' => $validated['booking_id'] ?? null,
            'user_id' => $user->id,
            'transaction_type' => $validated['transaction_type'],
            'payment_method' => $validated['payment_method'],
            'amount' => $validated['amount'],
            'currency' => $validated['currency'] ?? 'INR',
            'status' => 'pending',
            'description' => $validated['description'] ?? null,
        ]);

        return $this->sendResponse(
            $payment->load(['booking', 'user']),
            'Payment created successfully',
            Response::HTTP_CREATED
        );
    }

    /**
     * Show a payment record.
     */
    public function show(int $id): JsonResponse
    {
        $payment = Payment::with(['booking', 'user'])->find($id);

        if (! $payment) {
            return $this->sendNotFound('Payment not found');
        }

        $user = auth('api')->user();

        if (! $user->isAdmin() && $payment->user_id !== $user->id) {
            return $this->sendError('You are not authorized to view this payment', [], Response::HTTP_FORBIDDEN);
        }

        return $this->sendResponse($payment, 'Payment retrieved successfully');
    }

    /**
     * Verify a payment record.
     */
    public function verify(int $id): JsonResponse
    {
        $payment = Payment::find($id);

        if (! $payment) {
            return $this->sendNotFound('Payment not found');
        }

        $user = auth('api')->user();

        if (! $user->isAdmin() && $payment->user_id !== $user->id) {
            return $this->sendError('You are not authorized to verify this payment', [], Response::HTTP_FORBIDDEN);
        }

        $payment->status = 'completed';
        $payment->save();

        return $this->sendResponse($payment->fresh(), 'Payment verified successfully');
    }

    /**
     * Refund a payment record.
     */
    public function refund(int $id): JsonResponse
    {
        $payment = Payment::find($id);

        if (! $payment) {
            return $this->sendNotFound('Payment not found');
        }

        $user = auth('api')->user();

        if (! $user->isAdmin() && $payment->user_id !== $user->id) {
            return $this->sendError('You are not authorized to refund this payment', [], Response::HTTP_FORBIDDEN);
        }

        $payment->status = 'refunded';
        $payment->transaction_type = 'refund';
        $payment->save();

        return $this->sendResponse($payment->fresh(), 'Payment refunded successfully');
    }
}
