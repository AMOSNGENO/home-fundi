import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../features/models/homefundi_models.dart';
import '../../state/homefundi_state.dart';
import '../../theme/app_theme.dart';

class ChatRoomScreen extends StatefulWidget {
  const ChatRoomScreen({
    super.key,
    this.threadId,
    this.title,
  });

  final String? threadId;
  final String? title;

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _messageController = TextEditingController();
  bool _loaded = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;

    final threadId =
        widget.threadId ?? context.read<HomefundiState>().selectedThreadId;
    if (threadId != null) {
      context.read<HomefundiState>().loadMessages(threadId);
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    final threadId =
        widget.threadId ?? context.read<HomefundiState>().selectedThreadId;
    if (text.isEmpty || threadId == null) return;

    _messageController.clear();
    await context
        .read<HomefundiState>()
        .sendMessage(threadId: threadId, message: text);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<HomefundiState>();
    final threadId = widget.threadId ?? state.selectedThreadId;
    final thread = threadId == null ? null : state.threadById(threadId);
    final messages = threadId == null
        ? const <MessageDto>[]
        : state.messagesForThread(threadId);
    final title = widget.title ??
        thread?.participants.firstOrNull?.displayName ??
        'Chat room';

    return Scaffold(
      backgroundColor: AppTheme.canvas,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppTheme.canvas,
        foregroundColor: AppTheme.ink,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: thread?.bookingId == null
                ? () => context.go('/tabs/bookings')
                : () => context.go('/tracking/${thread!.bookingId}'),
            child: const Text('TRACK', style: TextStyle(color: AppTheme.ink)),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppTheme.ink, width: 2),
                  boxShadow: const [
                    BoxShadow(
                        color: AppTheme.leaf,
                        offset: Offset(4, 4),
                        blurRadius: 0),
                  ],
                ),
                child: Text(
                  'Thread ${threadId ?? 'support'}',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
            Expanded(
              child: messages.isEmpty
                  ? const Center(
                      child: Text(
                        'No messages yet. Start the conversation below.',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: messages.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        return Align(
                          alignment: message.isMine == true
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 420),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: message.isMine == true
                                    ? AppTheme.ink
                                    : Colors.white,
                                border:
                                    Border.all(color: AppTheme.ink, width: 2),
                                boxShadow: const [
                                  BoxShadow(
                                      color: AppTheme.leaf,
                                      offset: Offset(3, 3),
                                      blurRadius: 0),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (message.senderName != null &&
                                      message.isMine != true) ...[
                                    Text(
                                      message.senderName!,
                                      style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w900),
                                    ),
                                    const SizedBox(height: 4),
                                  ],
                                  Text(
                                    message.message ?? '',
                                    style: TextStyle(
                                      color: message.isMine == true
                                          ? Colors.white
                                          : AppTheme.ink,
                                      fontSize: 14,
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            _Composer(
              controller: _messageController,
              onSend: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.onSend,
  });

  final TextEditingController controller;
  final Future<void> Function() onSend;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppTheme.ink, width: 2)),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Write a message',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: onSend,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.ink,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              child: const Text('SEND'),
            ),
          ],
        ),
      ),
    );
  }
}

extension _FirstOrNull<E> on List<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
