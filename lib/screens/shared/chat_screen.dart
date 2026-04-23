import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/app_providers.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({
    super.key,
    required this.otherUserId,
    required this.otherUserLabel,
  });

  final String otherUserId;
  final String otherUserLabel;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _textCtrl = TextEditingController();

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final me = ref.read(authServiceProvider).currentUser;
    if (me == null) return const Scaffold(body: Center(child: Text('Not logged in')));
    final roomId = ref.read(firestoreServiceProvider).getChatRoomId(me.uid, widget.otherUserId);
    final chatProvider = StreamProvider((ref) {
      return ref.read(firestoreServiceProvider).watchChat(roomId);
    });
    final messagesAsync = ref.watch(chatProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Chat: ${widget.otherUserLabel}')),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              data: (messages) => ListView.builder(
                reverse: true,
                itemCount: messages.length,
                itemBuilder: (context, i) {
                  final msg = messages[i];
                  final mine = msg.senderId == me.uid;
                  return Align(
                    alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: mine ? Colors.green.shade100 : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(msg.text),
                    ),
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
          SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: TextField(
                      controller: _textCtrl,
                      decoration: const InputDecoration(hintText: 'Type message'),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    final text = _textCtrl.text.trim();
                    if (text.isEmpty) return;
                    await ref.read(firestoreServiceProvider).sendMessage(
                          roomId: roomId,
                          senderId: me.uid,
                          text: text,
                        );
                    _textCtrl.clear();
                  },
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
