<?php

namespace App\Http\Controllers;

use App\Models\Service;
use Illuminate\Http\Request;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;

class ServiceController extends BaseController
{
    public function index(Request $request)
    {
        $query = Service::query()->with('technician');

        if ($request->filled('category')) {
            $query->where('category', $request->string('category'));
        }

        if ($request->filled('technician_id')) {
            $query->where('technician_id', $request->integer('technician_id'));
        }

        if ($request->filled('status')) {
            $query->where('status', $request->string('status'));
        } else {
            $query->active();
        }

        return $this->paginated(
            $query->latest()->paginate($request->integer('per_page', 15)),
            'Services retrieved successfully'
        );
    }

    public function show(Service $service)
    {
        return $this->success($service->load(['technician', 'bookings', 'reviews']), 'Service retrieved successfully');
    }

    public function store(Request $request)
    {
        $this->assertCanManage($request);

        $validated = $request->validate([
            'technician_id' => ['nullable', 'exists:users,id'],
            'title' => ['required', 'string', 'max:255'],
            'category' => ['required', 'string', 'max:120'],
            'description' => ['required', 'string', 'max:5000'],
            'price' => ['required', 'numeric', 'min:0'],
            'currency' => ['nullable', 'string', 'size:3'],
            'duration_minutes' => ['nullable', 'integer', 'min:1'],
            'location' => ['nullable', 'string', 'max:255'],
            'service_area' => ['nullable', 'string', 'max:255'],
            'image_url' => ['nullable', 'string', 'max:2048'],
            'status' => ['nullable', Rule::in(['active', 'inactive', 'draft'])],
        ]);

        $service = Service::create([
            'technician_id' => $request->user()->role === 'technician' ? $request->user()->id : ($validated['technician_id'] ?? $request->user()->id),
>>>>>>> REPLACE
            'title' => $validated['title'],
            'slug' => Str::slug($validated['title']) . '-' . Str::lower(Str::random(6)),
            'category' => $validated['category'],
            'description' => $validated['description'],
            'price' => $validated['price'],
            'currency' => $validated['currency'] ?? 'USD',
            'duration_minutes' => $validated['duration_minutes'] ?? 60,
            'location' => $validated['location'] ?? null,
            'service_area' => $validated['service_area'] ?? null,
            'image_url' => $validated['image_url'] ?? null,
            'status' => $validated['status'] ?? 'active',
            'rating_average' => 0,
            'rating_count' => 0,
        ]);

        return $this->created($service->load('technician'), 'Service created successfully');
    }

    public function update(Request $request, Service $service)
    {
        $this->assertCanManage($request);

        $validated = $request->validate([
            'technician_id' => ['nullable', 'exists:users,id'],
            'title' => ['sometimes', 'string', 'max:255'],
            'category' => ['sometimes', 'string', 'max:120'],
            'description' => ['sometimes', 'string', 'max:5000'],
            'price' => ['sometimes', 'numeric', 'min:0'],
            'currency' => ['nullable', 'string', 'size:3'],
            'duration_minutes' => ['nullable', 'integer', 'min:1'],
            'location' => ['nullable', 'string', 'max:255'],
            'service_area' => ['nullable', 'string', 'max:255'],
            'image_url' => ['nullable', 'string', 'max:2048'],
            'status' => ['sometimes', Rule::in(['active', 'inactive', 'draft'])],
        ]);
>>>>>>> REPLACE

        if (isset($validated['title'])) {
            $validated['slug'] = Str::slug($validated['title']) . '-' . Str::lower(Str::random(6));
        }

        $service->update($validated);

        return $this->success($service->fresh()->load('technician'), 'Service updated successfully');
    }

    public function destroy(Request $request, Service $service)
    {
        $this->assertCanManage($request);

        $service->delete();

        return $this->success(null, 'Service deleted successfully');
    }

    private function assertCanManage(Request $request): void
    {
        if (!in_array($request->user()?->role, ['admin', 'technician'], true)) {
            abort(response()->json([
                'success' => false,
                'message' => 'Forbidden',
            ], 403));
        }
    }
}