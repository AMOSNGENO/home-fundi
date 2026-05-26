<?php

namespace App\Http\Controllers;

use App\Models\Booking;
use App\Models\Payment;
use App\Models\Service;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rule;

class AdminController extends BaseController
{
    public function dashboard(Request $request)
    {
        return $this->success([
            'users_count' => User::count(),
            'services_count' => Service::count(),
            'bookings_count' => Booking::count(),
            'payments_count' => Payment::count(),
        ], 'Admin dashboard retrieved successfully');
    }

    public function users(Request $request)
    {
        return $this->paginated(
            User::query()->latest()->paginate($request->integer('per_page', 15)),
            'Users retrieved successfully'
        );
    }

    public function userShow(User $user)
    {
        return $this->success($user->loadCount(['services', 'customerBookings', 'technicianBookings']), 'User retrieved successfully');
    }

    public function userUpdate(Request $request, User $user)
    {
        $validated = $request->validate([
            'name' => ['sometimes', 'string', 'max:255'],
            'email' => ['sometimes', 'email', 'max:255', Rule::unique('users', 'email')->ignore($user->id)],
            'password' => ['nullable', 'string', 'min:8'],
            'phone' => ['nullable', 'string', 'max:30'],
            'role' => ['sometimes', Rule::in(['customer', 'technician', 'admin'])],
            'avatar' => ['nullable', 'string', 'max:2048'],
            'bio' => ['nullable', 'string', 'max:1000'],
            'city' => ['nullable', 'string', 'max:120'],
            'state' => ['nullable', 'string', 'max:120'],
            'country' => ['nullable', 'string', 'max:120'],
            'is_active' => ['nullable', 'boolean'],
        ]);

        if (!empty($validated['password'])) {
            $validated['password'] = Hash::make($validated['password']);
        } else {
            unset($validated['password']);
        }

        $user->update($validated);

        return $this->success($user->fresh(), 'User updated successfully');
    }

    public function userDelete(User $user)
    {
        $user->delete();

        return $this->success(null, 'User deleted successfully');
    }

    public function suspendUser(User $user)
    {
        $user->update(['is_active' => false]);

        return $this->success($user->fresh(), 'User suspended successfully');
    }

    public function activateUser(User $user)
    {
        $user->update(['is_active' => true]);

        return $this->success($user->fresh(), 'User activated successfully');
    }

    public function services(Request $request)
    {
        return $this->paginated(
            Service::query()->with('technician')->latest()->paginate($request->integer('per_page', 15)),
            'Services retrieved successfully'
        );
    }

    public function storeService(Request $request)
    {
        return app(ServiceController::class)->store($request);
    }

    public function serviceShow(Service $service)
    {
        return $this->success($service->load(['technician', 'bookings', 'reviews']), 'Service retrieved successfully');
    }

    public function serviceUpdate(Request $request, Service $service)
    {
        return app(ServiceController::class)->update($request, $service);
    }

    public function serviceDelete(Service $service)
    {
        return app(ServiceController::class)->destroy(request(), $service);
    }

    public function payments(Request $request)
    {
        return $this->paginated(
            Payment::query()->with(['booking', 'user'])->latest()->paginate($request->integer('per_page', 15)),
            'Payments retrieved successfully'
        );
    }

    public function paymentShow(Payment $payment)
    {
        return $this->success($payment->load(['booking', 'user']), 'Payment retrieved successfully');
    }

    public function approvePayment(Payment $payment)
    {
        $payment->update(['status' => 'approved', 'verified_at' => now()]);

        return $this->success($payment->fresh(), 'Payment approved successfully');
    }

    public function rejectPayment(Payment $payment)
    {
        $payment->update(['status' => 'rejected']);

        return $this->success($payment->fresh(), 'Payment rejected successfully');
    }

    public function bookingsReport()
    {
        return $this->success([
            'total' => Booking::count(),
            'completed' => Booking::query()->where('status', 'completed')->count(),
            'cancelled' => Booking::query()->where('status', 'cancelled')->count(),
        ], 'Bookings report retrieved successfully');
    }

    public function revenueReport()
    {
        return $this->success([
            'total' => Payment::query()->where('status', 'verified')->sum('amount'),
            'currency' => 'USD',
        ], 'Revenue report retrieved successfully');
    }

    public function usersReport()
    {
        return $this->success([
            'total' => User::count(),
            'customers' => User::query()->where('role', 'customer')->count(),
            'technicians' => User::query()->where('role', 'technician')->count(),
            'admins' => User::query()->where('role', 'admin')->count(),
        ], 'Users report retrieved successfully');
    }
}