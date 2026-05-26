<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Tymon\JWTAuth\Contracts\JWTSubject;

class User extends Authenticatable implements JWTSubject
{
    use HasFactory, Notifiable;

    /**
     * The table associated with the model.
     *
     * @var string
     */
    protected $table = 'users';

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'name',
        'email',
        'phone',
        'password',
        'user_type',
        'profile_image',
        'address',
        'city',
        'state',
        'zip_code',
        'latitude',
        'longitude',
        'rating',
        'is_active',
        'is_verified',
        'email_verified_at',
        'phone_verified_at',
    ];

    /**
     * The attributes that are hidden for serialization.
     *
     * @var array<int, string>
     */
    protected $hidden = [
        'password_hash',
        'remember_token',
    ];

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'phone_verified_at' => 'datetime',
            'is_active' => 'boolean',
            'is_verified' => 'boolean',
            'password_hash' => 'hashed',
        ];
    }

    /**
     * Get the password used by Laravel authentication.
     */
    public function getAuthPassword(): string
    {
        return (string) $this->password_hash;
    }

    /**
     * Mutate the incoming password into the password_hash column.
     */
    public function setPasswordAttribute(string $value): void
    {
        $this->attributes['password_hash'] = $value;
    }

    /**
     * Get the identifier that will be stored in the subject claim of the JWT.
     *
     * @return mixed
     */
    public function getJWTIdentifier()
    {
        return $this->getKey();
    }

    /**
     * Return a key value array, containing any custom claims to be added to the JWT.
     *
     * @return array
     */
    public function getJWTCustomClaims()
    {
        return [
            'user_type' => $this->user_type,
            'email' => $this->email,
        ];
    }

    /**
     * User's bookings
     */
    public function bookings()
    {
        return $this->hasMany(Booking::class, 'customer_id');
    }

    /**
     * User's chats
     */
    public function chats()
    {
        return $this->hasMany(Chat::class, 'participant_1_id');
    }

    /**
     * User's payments
     */
    public function payments()
    {
        return $this->hasMany(Payment::class, 'user_id');
    }

    /**
     * User's reviews
     */
    public function reviews()
    {
        return $this->hasMany(Review::class, 'reviewer_id');
    }

    /**
     * Check if user is a technician
     */
    public function isTechnician(): bool
    {
        return $this->user_type === 'technician';
    }

    /**
     * Check if user is an admin
     */
    public function isAdmin(): bool
    {
        return $this->user_type === 'admin';
    }

    /**
     * Check if user is a customer
     */
    public function isCustomer(): bool
    {
        return $this->user_type === 'customer';
    }
}
