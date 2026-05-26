<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rule;

class AuthController extends BaseController
{
    public function register(Request $request)
    {
        $validated = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'email', 'max:255', 'unique:users,email'],
            'password' => ['required', 'string', 'min:8', 'confirmed'],
            'phone' => ['nullable', 'string', 'max:30'],
            'role' => ['nullable', Rule::in(['customer', 'technician'])],
            'avatar' => ['nullable', 'string', 'max:2048'],
            'bio' => ['nullable', 'string', 'max:1000'],
            'city' => ['nullable', 'string', 'max:120'],
            'state' => ['nullable', 'string', 'max:120'],
            'country' => ['nullable', 'string', 'max:120'],
        ]);

        $user = User::create([
            'name' => $validated['name'],
            'email' => $validated['email'],
            'password' => Hash::make($validated['password']),
            'phone' => $validated['phone'] ?? null,
            'role' => $validated['role'] ?? 'customer',
            'avatar' => $validated['avatar'] ?? null,
            'bio' => $validated['bio'] ?? null,
            'city' => $validated['city'] ?? null,
            'state' => $validated['state'] ?? null,
            'country' => $validated['country'] ?? null,
            'is_active' => true,
            'last_login_at' => now(),
        ]);

        $token = $user->createToken('api-token')->plainTextToken;

        return $this->created([
            'user' => $this->profilePayload($user),
            'token' => $token,
            'token_type' => 'Bearer',
        ], 'Registration successful');
    }

    public function login(Request $request)
    {
        $credentials = $request->validate([
            'email' => ['required', 'email'],
            'password' => ['required', 'string'],
        ]);

        $user = User::where('email', $credentials['email'])->first();

        if (!$user || !Hash::check($credentials['password'], $user->password)) {
            return $this->error('Invalid credentials', [], 422);
        }

        if (!$user->is_active) {
            return $this->error('Account is disabled', [], 403);
        }

        $user->forceFill(['last_login_at' => now()])->save();

        $token = $user->createToken('api-token')->plainTextToken;

        return $this->success([
            'user' => $this->profilePayload($user),
            'token' => $token,
            'token_type' => 'Bearer',
        ], 'Login successful');
    }

    public function logout(Request $request)
    {
        $request->user()?->currentAccessToken()?->delete();

        return $this->success(null, 'Logged out successfully');
    }

    public function refresh(Request $request)
    {
        $user = $request->user();

        if (!$user) {
            return $this->error('Unauthenticated', [], 401);
        }

        $request->user()?->currentAccessToken()?->delete();

        $token = $user->createToken('api-token')->plainTextToken;

        return $this->success([
            'token' => $token,
            'token_type' => 'Bearer',
            'user' => $this->profilePayload($user),
        ], 'Token refreshed successfully');
    }

    public function profile(Request $request)
    {
        $user = $request->user();

        if (!$user) {
            return $this->error('Unauthenticated', [], 401);
        }

        return $this->success([
            'user' => $this->profilePayload($user),
        ], 'Profile retrieved successfully');
    }

    private function profilePayload(User $user): array
    {
        return array_merge($user->toArray(), [
            'services_count' => $user->services()->count(),
            'customer_bookings_count' => $user->customerBookings()->count(),
            'technician_bookings_count' => $user->technicianBookings()->count(),
        ]);
    }
}