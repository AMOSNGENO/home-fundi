<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rule;

class UserController extends BaseController
{
    public function index(Request $request)
    {
        if ($request->user()?->role !== 'admin') {
            return $this->error('Forbidden', [], 403);
        }

        $users = User::query()->latest()->paginate($request->integer('per_page', 15));

        return $this->paginated($users, 'Users retrieved successfully');
    }

    public function store(Request $request)
    {
        if ($request->user()?->role !== 'admin') {
            return $this->error('Forbidden', [], 403);
        }

        $validated = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'email', 'max:255', 'unique:users,email'],
            'password' => ['required', 'string', 'min:8'],
            'phone' => ['nullable', 'string', 'max:30'],
            'role' => ['required', Rule::in(['customer', 'technician', 'admin'])],
            'avatar' => ['nullable', 'string', 'max:2048'],
            'bio' => ['nullable', 'string', 'max:1000'],
            'city' => ['nullable', 'string', 'max:120'],
            'state' => ['nullable', 'string', 'max:120'],
            'country' => ['nullable', 'string', 'max:120'],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $user = User::create([
            'name' => $validated['name'],
            'email' => $validated['email'],
            'password' => Hash::make($validated['password']),
            'phone' => $validated['phone'] ?? null,
            'role' => $validated['role'],
            'avatar' => $validated['avatar'] ?? null,
            'bio' => $validated['bio'] ?? null,
            'city' => $validated['city'] ?? null,
            'state' => $validated['state'] ?? null,
            'country' => $validated['country'] ?? null,
            'is_active' => $validated['is_active'] ?? true,
        ]);

        return $this->created($user, 'User created successfully');
    }

    public function show(Request $request, User $user)
    {
        if ($request->user()?->role !== 'admin') {
            return $this->error('Forbidden', [], 403);
        }

        return $this->success($user->loadCount(['services', 'customerBookings', 'technicianBookings']), 'User retrieved successfully');
    }

    public function update(Request $request, User $user)
    {
        if ($request->user()?->role !== 'admin') {
            return $this->error('Forbidden', [], 403);
        }

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

        if (array_key_exists('password', $validated) && $validated['password']) {
            $validated['password'] = Hash::make($validated['password']);
        } else {
            unset($validated['password']);
        }

        $user->update($validated);

        return $this->success($user->fresh(), 'User updated successfully');
    }

    public function destroy(Request $request, User $user)
    {
        if ($request->user()?->role !== 'admin') {
            return $this->error('Forbidden', [], 403);
        }

        $user->delete();

        return $this->success(null, 'User deleted successfully');
    }
}