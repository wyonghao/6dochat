import 'package:dio/dio.dart';

import '../config.dart';
import '../models/chat_channel.dart';
import '../models/chat_message.dart';

class DiscourseChatApiService {
  DiscourseChatApiService({required String accessToken})
      : _dio = Dio(
          BaseOptions(
            baseUrl: AppConfig.discourseBaseUrl,
            headers: {
              'Authorization': 'Bearer $accessToken',
              'Accept': 'application/json',
            },
          ),
        );

  final Dio _dio;

  /// Calls Discourse chat channels endpoint and returns only the channels list.
  Future<List<ChatChannel>> fetchChannels() async {
    final response = await _dio.get<Map<String, dynamic>>('/chat/api/channels.json');
    final channels = (response.data?['channels'] as List<dynamic>? ?? <dynamic>[])
        .cast<Map<String, dynamic>>();
    return channels.map(ChatChannel.fromJson).toList();
  }

  /// Gets recent messages for a channel.
  Future<List<ChatMessage>> fetchMessages(int channelId) async {
    final response = await _dio.get<Map<String, dynamic>>('/chat/api/channels/$channelId/messages.json');
    final messages = (response.data?['messages'] as List<dynamic>? ?? <dynamic>[])
        .cast<Map<String, dynamic>>();
    return messages.map(ChatMessage.fromJson).toList();
  }

  /// Sends a new plain text message to the selected channel.
  Future<void> sendMessage({required int channelId, required String message}) async {
    await _dio.post('/chat/api/channels/$channelId/messages.json', data: {'message': message});
  }

  /// Attempts to create a new chat channel. Visibility rules are configured in Discourse.
  Future<void> createChannel(String name) async {
    await _dio.post('/chat/api/channels.json', data: {'name': name});
  }

  /// Attempts to delete a chat channel if user permissions allow it.
  Future<void> deleteChannel(int channelId) async {
    await _dio.delete('/chat/api/channels/$channelId.json');
  }
}
