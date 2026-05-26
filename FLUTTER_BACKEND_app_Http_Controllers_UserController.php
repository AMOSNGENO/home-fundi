<?php

namespace App\Http\Controllers;

use App\Http\Resources\UserResource;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Validation\Rule;

class UserController extends BaseController
{
    /**
     * Show a user profile.
     */
    public function show(int $id): JsonResponse
    {
        $user = User::find($id);

        if (! $user) {
            return $this->sendNotFound('User not found');
        }

        return $this->sendResponse(
            new UserResource($user),
            'User retrieved successfully'
        );
    }

    /**
     * Update a user profile.
     */
    public function update(Request $request, int $id): JsonResponse
    {
        $currentUser = auth('api')->user();
        $user = User::find($id);

        if (! $user) {
            return $this->sendNotFound('User not found');
        }

        if ($currentUser->id !== $user->id && ! $currentUser->isAdmin()) {
            return $this->sendError('You are not authorized to update this user', [], Response::HTTP_FORBIDDEN);
        }

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
            'user_type' => ['sometimes', 'in:customer,technician,admin'],
            'profile_image' => ['nullable', 'string', 'max:255'],
            'address' => ['nullable', 'string', 'max:255'],
            'city' => ['nullable', 'string', 'max:255'],
            'state' => ['nullable', 'string', 'max:255'],
            'zip_code' => ['nullable', 'string', 'max:20'],
            'latitude' => ['nullable', 'numeric'],
            'longitude' => ['nullable', 'numeric'],
            'is_active' => ['sometimes', 'boolean'],
        ]);

        $user->fill($validated);
        $user->save();

        return $this->sendResponse(
            new UserResource($user->fresh()),
            'User updated successfully'
        );
    }

    /**
     * Soft delete a user.
     */
    public function delete(int $id): JsonResponse
    {
        $currentUser = auth('api')->user();
        $user = User::find($id);

        if (! $user) {
            return $this->sendNotFound('User not found');
        }

        if ($currentUser->id !== $user->id && ! $currentUser->isAdmin()) {
            return $this->sendError('You are not authorized to delete this user', [], Response::HTTP_FORBIDDEN);
        }

        $user->delete();

        return $this->sendResponse([], 'User deleted successfully');
    }

    /**
     * Return a user's bookings.
     */
    public function bookings(int $id): JsonResponse
    {
        $user = User::find($id);

        if (! $user) {
            return $this->sendNotFound('User not found');
        }

        return $this->sendResponse([
            'items' => [],
            'total' => 0,
            'user_id' => $user->id,
        ], 'User bookings retrieved successfully');
    }

    /**
     * Return a user's chats.
     */
    public function chats(int $id): JsonResponse
    {
        $user = User::find($id);

        if (! $user) {
            return $this->sendNotFound('User not found');
        }

        return $this->sendResponse([
            'items' => [],
            'total' => 0,
            'user_id' => $user->id,
        ], 'User chats retrieved successfully');
    }
}
