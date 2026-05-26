<?php

namespace App\Http\Controllers;

use App\Models\Chat;
use App\Models\Message;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;

class ChatController extends BaseController
{
    /**
     * List chats for the current user.
     */
    public function index(): JsonResponse
    {
        $user = auth('api')->user();
        $query = Chat::query()->with(['booking', 'participantOne', 'participantTwo']);

        $query->where('participant_1_id', $user->id)
            ->orWhere('participant_2_id', $user->id);

        $items = $query->latest('updated_at')->get();

        return $this->sendResponse([
            'items' => $items,
            'total' => $items->count(),
        ], 'Chats retrieved successfully');
    }

    /**
     * Create a chat conversation.
     */
    public function store(Request $request): JsonResponse
    {
        $user = auth('api')->user();

        $validated = $request->validate([
            'participant_2_id' => ['required', 'integer', 'exists:users,id', Rule::notIn([$user->id])],
            'booking_id' => ['nullable', 'integer', 'exists:bookings,id'],
            'message' => ['nullable', 'string', 'max:1000'],
        ]);

        $participantOne = min($user->id, (int) $validated['participant_2_id']);
        $participantTwo = max($user->id, (int) $validated['participant_2_id']);

        $chat = Chat::firstOrCreate(
            [
                'participant_1_id' => $participantOne,
                'participant_2_id' => $participantTwo,
            ],
            [
                'booking_id' => $validated['booking_id'] ?? null,
                'is_active' => true,
            ]
        );

        if (! empty($validated['message'])) {
            $this->appendMessage($chat, $user->id, (int) $validated['participant_2_id'], $validated['message']);
        }

        return $this->sendResponse(
            $chat->fresh()->load(['booking', 'participantOne', 'participantTwo']),
            'Chat created successfully',
            Response::HTTP_CREATED
        );
    }

    /**
     * Show a chat conversation.
     */
    public function show(int $id): JsonResponse
    {
        $chat = Chat::with(['booking', 'participantOne', 'participantTwo'])->find($id);

        if (! $chat) {
            return $this->sendNotFound('Chat not found');
        }

        $user = auth('api')->user();

        if ($chat->participant_1_id !== $user->id && $chat->participant_2_id !== $user->id && ! $user->isAdmin()) {
            return $this->sendError('You are not authorized to view this chat', [], Response::HTTP_FORBIDDEN);
        }

        return $this->sendResponse($chat, 'Chat retrieved successfully');
    }

    /**
     * Send a message in a conversation.
     */
    public function sendMessage(Request $request, int $id): JsonResponse
    {
        $chat = Chat::find($id);

        if (! $chat) {
            return $this->sendNotFound('Chat not found');
        }

        $user = auth('api')->user();

        if ($chat->participant_1_id !== $user->id && $chat->participant_2_id !== $user->id && ! $user->isAdmin()) {
            return $this->sendError('You are not authorized to send messages in this chat', [], Response::HTTP_FORBIDDEN);
        }

        $validated = $request->validate([
            'message_text' => ['required', 'string', 'max:5000'],
            'message_type' => ['sometimes', Rule::in(['text', 'image', 'file', 'location', 'quote'])],
            'media_url' => ['nullable', 'string', 'max:500'],
        ]);

        $receiverId = $chat->participant_1_id === $user->id ? $chat->participant_2_id : $chat->participant_1_id;

        $message = $this->appendMessage(
            $chat,
            $user->id,
            $receiverId,
            $validated['message_text'],
            $validated['message_type'] ?? 'text',
            $validated['media_url'] ?? null
        );

        return $this->sendResponse($message, 'Message sent successfully', Response::HTTP_CREATED);
    }

    /**
     * Return messages for a chat.
     */
    public function getMessages(int $id): JsonResponse
    {
        $chat = Chat::find($id);

        if (! $chat) {
            return $this->sendNotFound('Chat not found');
        }

        $user = auth('api')->user();

        if ($chat->participant_1_id !== $user->id && $chat->participant_2_id !== $user->id && ! $user->isAdmin()) {
            return $this->sendError('You are not authorized to view these messages', [], Response::HTTP_FORBIDDEN);
        }

        $items = Message::query()
            ->where('conversation_id', $chat->id)
            ->orderBy('created_at')
            ->get();

        return $this->sendResponse([
            'chat_id' => $chat->id,
            'items' => $items,
            'total' => $items->count(),
        ], 'Messages retrieved successfully');
    }

    /**
     * Delete a chat conversation.
     */
    public function delete(int $id): JsonResponse
    {
        $chat = Chat::find($id);

        if (! $chat) {
            return $this->sendNotFound('Chat not found');
        }

        $user = auth('api')->user();

        if ($chat->participant_1_id !== $user->id && $chat->participant_2_id !== $user->id && ! $user->isAdmin()) {
            return $this->sendError('You are not authorized to delete this chat', [], Response::HTTP_FORBIDDEN);
        }

        $chat->delete();

        return $this->sendResponse([], 'Chat deleted successfully');
    }

    /**
     * Append a message and update the chat preview.
     */
    private function appendMessage(Chat $chat, int $senderId, int $receiverId, string $text, string $type = 'text', ?string $mediaUrl = null): Message
    {
        $message = Message::create([
            'conversation_id' => $chat->id,
            'sender_id' => $senderId,
            'receiver_id' => $receiverId,
            'message_text' => $text,
            'message_type' => $type,
            'media_url' => $mediaUrl,
            'is_read' => false,
            'read_at' => null,
        ]);

        $chat->last_message_id = $message->id;
        $chat->last_message_time = now();
        $chat->last_message_preview = Str::limit($text, 255);
        $chat->save();

        return $message;
    }
}
