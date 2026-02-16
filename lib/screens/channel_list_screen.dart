import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/auth_controller.dart';
import '../chat/channel_list_controller.dart';
import '../models/chat_channel.dart';
import '../services/discourse_chat_api_service.dart';
import 'chat_screen.dart';

class ChannelListScreen extends StatefulWidget {
  const ChannelListScreen({super.key});

  @override
  State<ChannelListScreen> createState() => _ChannelListScreenState();
}

class _ChannelListScreenState extends State<ChannelListScreen> {
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final token = auth.token;

    if (token == null) {
      return const SizedBox.shrink();
    }

    return ChangeNotifierProvider(
      create: (_) => ChannelListController(
        api: DiscourseChatApiService(accessToken: token.accessToken),
      )..loadChannels(),
      child: const _ChannelListView(),
    );
  }
}

class _ChannelListView extends StatelessWidget {
  const _ChannelListView();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ChannelListController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Channels'),
        actions: [
          IconButton(
            tooltip: 'Refresh channels',
            onPressed: controller.loading ? null : controller.loadChannels,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: () => context.read<AuthController>().logout(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _promptCreateChannel(context),
        icon: const Icon(Icons.add),
        label: const Text('Create channel'),
      ),
      body: Builder(
        builder: (_) {
          if (controller.loading && controller.channels.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.error != null && controller.channels.isEmpty) {
            return Center(child: Text(controller.error!));
          }

          if (controller.channels.isEmpty) {
            return const Center(child: Text('No channels available for this user.'));
          }

          return ListView.separated(
            itemCount: controller.channels.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final channel = controller.channels[index];
              return ListTile(
                title: Text(channel.name),
                subtitle: Text('#${channel.slug}'),
                trailing: channel.canDelete
                    ? IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _confirmDelete(context, channel),
                      )
                    : null,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(channel: channel),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _promptCreateChannel(BuildContext context) async {
    final controller = context.read<ChannelListController>();
    final nameController = TextEditingController();

    final created = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create channel'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Channel name',
              hintText: 'team-chat',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Create'),
            ),
          ],
        );
      },
    );

    if (created == true && nameController.text.trim().isNotEmpty) {
      try {
        await controller.createChannel(nameController.text.trim());
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to create channel: $e')),
          );
        }
      }
    }
  }

  Future<void> _confirmDelete(BuildContext context, ChatChannel channel) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete channel?'),
          content: Text('Delete "${channel.name}"? This cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      try {
        await context.read<ChannelListController>().deleteChannel(channel.id);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete channel: $e')),
          );
        }
      }
    }
  }
}
