<?php

namespace App\Http\Controllers;

use App\Http\Requests\LoginRequest;
use App\Http\Requests\StoreUserRequest;
use App\Http\Resources\UserResource;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Password;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;
use Tymon\JWTAuth\Facades\JWTAuth;

class AuthController extends BaseController
{
    /**
     * Register a new user and return a JWT token.
     */
    public function register(StoreUserRequest $request): JsonResponse
    {
        $user = User::create([
            'name' => $request->input('name'),
            'email' => $request->input('email'),
            'phone' => $request->input('phone'),
            'password' => $request->input('password'),
            'user_type' => $request->input('user_type', 'customer'),
        ]);

        $token = JWTAuth::fromUser($user);

        return $this->respondWithToken(
            $token,
            $user,
            'User registered successfully',
            Response::HTTP_CREATED
        );
    }

    /**
     * Authenticate a user and return a JWT token.
     */
    public function login(LoginRequest $request): JsonResponse
    {
        $credentials = $request->only('email', 'password');

        if (! $token = JWTAuth::attempt($credentials)) {
            return $this->sendUnauthorized();
        }

        $user = auth('api')->user();

        return $this->respondWithToken($token, $user, 'Login successful');
    }

    /**
     * Invalidate the current JWT token.
     */
    public function logout(): JsonResponse
    {
        auth('api')->logout();

        return $this->sendResponse([], 'Logged out successfully');
    }

    /**
     * Refresh the current JWT token.
     */
    public function refresh(): JsonResponse
    {
        $token = auth('api')->refresh();
        $user = auth('api')->user();

        return $this->respondWithToken($token, $user, 'Token refreshed successfully');
    }

    /**
     * Return the authenticated user's profile.
     */
    public function profile(): JsonResponse
    {
        $user = auth('api')->user();

        return $this->sendResponse(
            new UserResource($user),
            'Profile retrieved successfully'
        );
    }

    /**
     * Update the authenticated user's profile.
     */
    public function updateProfile(Request $request): JsonResponse
    {
        $user = auth('api')->user();

        $validated = $request->validate([
            'name' => ['sometimes', 'string', 'max:255'],
            'email' => [
                'sometimes',
                'string',
                'email',
                'max:255',
                Rule::unique('users', 'email')->ignore($user->id),
            ],
            'phone' => [
                'sometimes',
                'string',
                'max:20',
                Rule::unique('users', 'phone')->ignore($user->id),
            ],
            'profile_image' => ['nullable', 'string', 'max:255'],
            'address' => ['nullable', 'string', 'max:255'],
            'city' => ['nullable', 'string', 'max:255'],
            'state' => ['nullable', 'string', 'max:255'],
            'zip_code' => ['nullable', 'string', 'max:20'],
            'latitude' => ['nullable', 'numeric'],
            'longitude' => ['nullable', 'numeric'],
        ]);

        $user->fill($validated);
        $user->save();

        return $this->sendResponse(
            new UserResource($user->fresh()),
            'Profile updated successfully'
        );
    }

    /**
     * Change the authenticated user's password.
     */
    public function changePassword(Request $request): JsonResponse
    {
        $user = auth('api')->user();

        $validated = $request->validate([
            'current_password' => ['required', 'string'],
            'password' => ['required', 'string', 'min:8', 'confirmed'],
        ]);

        if (! Hash::check($validated['current_password'], $user->password)) {
            return $this->sendError('Current password is incorrect', [], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $user->password = $validated['password'];
        $user->save();

        return $this->sendResponse([], 'Password changed successfully');
    }

    /**
     * Send a password reset link.
     */
    public function forgotPassword(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'email' => ['required', 'string', 'email', 'exists:users,email'],
        ]);

        $status = Password::sendResetLink($validated);

        if ($status !== Password::RESET_LINK_SENT) {
            return $this->sendError(__($status), [], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        return $this->sendResponse([], 'Password reset link sent successfully');
    }

    /**
     * Reset a password using a reset token.
     */
    public function resetPassword(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'token' => ['required', 'string'],
            'email' => ['required', 'string', 'email', 'exists:users,email'],
            'password' => ['required', 'string', 'min:8', 'confirmed'],
        ]);

        $status = Password::reset(
            $validated,
            function (User $user, string $password): void {
                $user->password = $password;
                $user->setRememberToken(Str::random(60));
                $user->save();
            }
        );

        if ($status !== Password::PASSWORD_RESET) {
            return $this->sendError(__($status), [], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        return $this->sendResponse([], 'Password reset successfully');
    }

    /**
     * Mark a user's email as verified.
     */
    public function verifyEmail(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'email' => ['required', 'string', 'email', 'exists:users,email'],
        ]);

        $user = User::where('email', $validated['email'])->firstOrFail();

        if (! $user->email_verified_at) {
            $user->email_verified_at = now();
            $user->is_verified = true;
            $user->save();
        }

        return $this->sendResponse([], 'Email verified successfully');
    }

    /**
     * Placeholder OTP resend endpoint for the current backend slice.
     */
    public function resendOtp(Request $request): JsonResponse
    {
        $request->validate([
            'email' => ['required', 'string', 'email', 'exists:users,email'],
        ]);

        return $this->sendResponse([], 'OTP resend is not wired to an SMS provider yet');
    }

    /**
     * Build a standard token response.
     */
    private function respondWithToken(string $token, ?User $user, string $message, int $statusCode = Response::HTTP_OK): JsonResponse
    {
        return $this->sendResponse([
            'access_token' => $token,
            'token_type' => 'bearer',
            'expires_in' => auth('api')->factory()->getTTL() * 60,
            'user' => new UserResource($user),
        ], $message, $statusCode);
    }
}
