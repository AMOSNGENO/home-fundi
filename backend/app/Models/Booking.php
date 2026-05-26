<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Booking extends Model
{
    use HasFactory;

    protected $fillable = [
        'service_id',
        'customer_id',
        'technician_id',
        'chat_id',
        'payment_id',
        'scheduled_at',
        'status',
        'address',
        'latitude',
        'longitude',
        'notes',
        'amount',
        'currency',
        'otp_code',
        'confirmation_code',
        'confirmed_at',
        'completed_at',
        'cancelled_at',
        'cancel_reason',
        'rating',
        'reviewed_at',
    ];

    protected $casts = [
        'scheduled_at' => 'datetime',
        'confirmed_at' => 'datetime',
        'completed_at' => 'datetime',
        'cancelled_at' => 'datetime',
        'reviewed_at' => 'datetime',
        'latitude' => 'decimal:7',
        'longitude' => 'decimal:7',
        'amount' => 'decimal:2',
        'rating' => 'decimal:2',
    ];

    public function service()
    {
        return $this->belongsTo(Service::class);
    }

    public function customer()
    {
        return $this->belongsTo(User::class, 'customer_id');
    }

    public function technician()
    {
        return $this->belongsTo(User::class, 'technician_id');
    }

    public function chat()
    {
        return $this->belongsTo(Chat::class, 'chat_id');
    }

    public function payment()
    {
        return $this->belongsTo(Payment::class, 'payment_id');
    }

    public function review()
    {
        return $this->hasOne(Review::class);
    }

    public function messages()
    {
        return $this->hasManyThrough(Message::class, Chat::class);
    }
}