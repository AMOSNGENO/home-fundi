<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Chat extends Model
{
    use HasFactory;

    /**
     * The table associated with the model.
     *
     * @var string
     */
    protected $table = 'conversations';

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'booking_id',
        'participant_1_id',
        'participant_2_id',
        'last_message_id',
        'last_message_time',
        'last_message_preview',
        'is_active',
    ];

    /**
     * The attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'last_message_time' => 'datetime',
            'is_active' => 'boolean',
        ];
    }

    /**
     * Booking associated with the conversation.
     */
    public function booking(): BelongsTo
    {
        return $this->belongsTo(Booking::class, 'booking_id');
    }

    /**
     * First participant.
     */
    public function participantOne(): BelongsTo
    {
        return $this->belongsTo(User::class, 'participant_1_id');
    }

    /**
     * Second participant.
     */
    public function participantTwo(): BelongsTo
    {
        return $this->belongsTo(User::class, 'participant_2_id');
    }
}
