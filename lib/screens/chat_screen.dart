import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/auth_controller.dart';
import '../chat/chat_controller.dart';
import '../models/chat_channel.dart';
import '../services/discourse_chat_api_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.channel});

  final ChatChannel channel;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final TextEditingController _messageController;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final token = context.read<AuthController>().token;
    if (token == null) return const SizedBox.shrink();

    return ChangeNotifierProvider(
      create: (_) => ChatController(
        api: DiscourseChatApiService(accessToken: token.accessToken),
        channelId: widget.channel.id,
      )..loadInitialMessages(),
      child: Consumer<ChatController>(
        builder: (context, controller, _) {
          return Scaffold(
            appBar: AppBar(
              title: Text(widget.channel.name),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: controller.loading ? null : controller.loadInitialMessages,
                ),
              ],
            ),
            body: Column(
              children: [
                Expanded(
                  child: controller.loading && controller.messages.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          reverse: true,
                          padding: const EdgeInsets.all(12),
                          itemCount: controller.messages.length,
                          itemBuilder: (context, index) {
                            final message = controller.messages[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              child: ListTile(
                                title: Text(message.username),
                                subtitle: Text(message.message),
                                trailing: Text(
                                  '${message.createdAt.hour.toString().padLeft(2, '0')}:${message.createdAt.minute.toString().padLeft(2, '0')}',
                                ),
                              ),
                            );
                          },
                        ),
                ),
                if (controller.error != null)
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      controller.error!,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _send(context),
                            decoration: const InputDecoration(
                              hintText: 'Type a message',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: controller.sending ? null : () => _send(context),
                          child: controller.sending
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Send'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _send(BuildContext context) async {
    final text = _messageController.text;
    if (text.trim().isEmpty) return;

    await context.read<ChatController>().sendMessage(text);
    _messageController.clear();
  }
}
