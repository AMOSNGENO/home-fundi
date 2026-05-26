<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\SoftDeletes;

class Booking extends Model
{
    use HasFactory, SoftDeletes;

    /**
     * The table associated with the model.
     *
     * @var string
     */
    protected $table = 'bookings';

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'booking_reference',
        'customer_id',
        'technician_id',
        'service_id',
        'status',
        'service_date',
        'service_start_time',
        'estimated_duration_minutes',
        'service_end_time',
        'customer_location_latitude',
        'customer_location_longitude',
        'service_address',
        'base_price',
        'tax_amount',
        'total_price',
        'discount_amount',
        'description',
        'cancellation_reason',
        'cancelled_by',
        'cancelled_at',
        'otp_code',
        'otp_verified',
    ];

    /**
     * The attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'service_date' => 'date',
            'service_start_time' => 'string',
            'service_end_time' => 'string',
            'customer_location_latitude' => 'decimal:8',
            'customer_location_longitude' => 'decimal:8',
            'base_price' => 'decimal:2',
            'tax_amount' => 'decimal:2',
            'total_price' => 'decimal:2',
            'discount_amount' => 'decimal:2',
            'cancelled_at' => 'datetime',
            'otp_verified' => 'boolean',
        ];
    }

    /**
     * Booking customer.
     */
    public function customer(): BelongsTo
    {
        return $this->belongsTo(User::class, 'customer_id');
    }

    /**
     * Booking technician.
     */
    public function technician(): BelongsTo
    {
        return $this->belongsTo(User::class, 'technician_id');
    }

    /**
     * Booking service.
     */
    public function service(): BelongsTo
    {
        return $this->belongsTo(Service::class, 'service_id');
    }

    /**
     * Check whether booking is completed.
     */
    public function isCompleted(): bool
    {
        return $this->status === 'completed';
    }

    /**
     * Check whether booking is cancelled.
     */
    public function isCancelled(): bool
    {
        return $this->status === 'cancelled';
    }
}
