<?php

namespace App\Http\Controllers;

use App\Models\Booking;
use App\Models\Chat;
use App\Models\Message;
use Illuminate\Http\Request;

class ChatController extends BaseController
{
    public function index(Request $request)
    {
        $user = $request->user();

        $query = Chat::query()->with(['booking', 'customer', 'technician', 'messages']);

        if ($user->role === 'customer') {
            $query->where('customer_id', $user->id);
        } elseif ($user->role === 'technician') {
            $query->where('technician_id', $user->id);
        }

        return $this->paginated(
            $query->latest('last_message_at')->paginate($request->integer('per_page', 15)),
            'Chats retrieved successfully'
        );
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'booking_id' => ['required', 'exists:bookings,id'],
        ]);

        $booking = Booking::query()->findOrFail($validated['booking_id']);

        $chat = Chat::firstOrCreate([
            'booking_id' => $booking->id,
        ], [
            'customer_id' => $booking->customer_id,
            'technician_id' => $booking->technician_id,
            'status' => 'active',
            'last_message_at' => now(),
        ]);

        return $this->created($chat->load(['booking', 'customer', 'technician']), 'Chat created successfully');
    }

    public function show(Request $request, Chat $chat)
    {
        if (!$this->canAccess($request->user()?->id, $request->user()?->role, $chat)) {
            return $this->error('Forbidden', [], 403);
        }

        return $this->success($chat->load(['booking', 'customer', 'technician', 'messages.sender']), 'Chat retrieved successfully');
    }
>>>>>>> REPLACE

    public function destroy(Chat $chat)
    {
        $chat->delete();

        return $this->success(null, 'Chat deleted successfully');
    }

    public function messages(Request $request, Chat $chat)
    {
        $messages = $chat->messages()->with('sender')->latest()->paginate($request->integer('per_page', 20));

        return $this->paginated($messages, 'Messages retrieved successfully');
    }

    public function sendMessage(Request $request, Chat $chat)
    {
        $validated = $request->validate([
            'body' => ['required', 'string', 'max:5000'],
            'attachment_url' => ['nullable', 'string', 'max:2048'],
        ]);

        $message = Message::create([
            'chat_id' => $chat->id,
            'sender_id' => $request->user()->id,
            'body' => $validated['body'],
            'attachment_url' => $validated['attachment_url'] ?? null,
            'is_read' => false,
            'sent_at' => now(),
        ]);

        $chat->update(['last_message_at' => now()]);

        return $this->created($message->load('sender'), 'Message sent successfully');
    }
}