<?php

namespace App\Http\Controllers;

use App\Models\Service;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Response;

class ServiceController extends BaseController
{
    /**
     * List all active services.
     */
    public function index(): JsonResponse
    {
        $services = Service::query()
            ->where('is_active', true)
            ->latest()
            ->get();

        return $this->sendResponse([
            'items' => $services,
            'total' => $services->count(),
        ], 'Services retrieved successfully');
    }

    /**
     * Show a service.
     */
    public function show(int $id): JsonResponse
    {
        $service = Service::find($id);

        if (! $service) {
            return $this->sendNotFound('Service not found');
        }

        return $this->sendResponse($service, 'Service retrieved successfully');
    }

    /**
     * Return technicians for a service.
     */
    public function technicians(int $id): JsonResponse
    {
        $service = Service::find($id);

        if (! $service) {
            return $this->sendNotFound('Service not found');
        }

        return $this->sendResponse([
            'service_id' => $service->id,
            'items' => [],
            'total' => 0,
        ], 'Technicians retrieved successfully');
    }
}
