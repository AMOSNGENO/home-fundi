<?php

namespace App\Http\Controllers;

use App\Models\Booking;
use App\Models\Review;
use App\Models\Service;
use Illuminate\Http\Request;

class TechnicianController extends BaseController
{
    public function dashboard(Request $request)
    {
        $technicianId = $request->user()->id;

        return $this->success([
            'services_count' => Service::query()->where('technician_id', $technicianId)->count(),
            'bookings_count' => Booking::query()->where('technician_id', $technicianId)->count(),
            'completed_bookings_count' => Booking::query()->where('technician_id', $technicianId)->where('status', 'completed')->count(),
            'earnings_total' => Booking::query()->where('technician_id', $technicianId)->where('status', 'completed')->sum('amount'),
            'rating_average' => Review::query()->where('technician_id', $technicianId)->avg('rating') ?? 0,
        ], 'Technician dashboard retrieved successfully');
    }

    public function bookings(Request $request)
    {
        $bookings = Booking::query()
            ->with(['service', 'customer', 'payment', 'review'])
            ->where('technician_id', $request->user()->id)
            ->latest()
            ->paginate($request->integer('per_page', 15));

        return $this->paginated($bookings, 'Technician bookings retrieved successfully');
    }

    public function availability(Request $request)
    {
        return $this->success([
            'available' => true,
            'schedule' => [],
        ], 'Availability retrieved successfully');
    }

    public function updateAvailability(Request $request)
    {
        return $this->success([
            'available' => (bool) $request->boolean('available', true),
            'schedule' => $request->input('schedule', []),
        ], 'Availability updated successfully');
    }

    public function earnings(Request $request)
    {
        $technicianId = $request->user()->id;

        return $this->success([
            'total' => Booking::query()->where('technician_id', $technicianId)->where('status', 'completed')->sum('amount'),
            'currency' => 'USD',
        ], 'Earnings retrieved successfully');
    }

    public function ratings(Request $request)
    {
        $ratings = Review::query()
            ->where('technician_id', $request->user()->id)
            ->latest()
            ->paginate($request->integer('per_page', 15));

        return $this->paginated($ratings, 'Ratings retrieved successfully');
    }
}