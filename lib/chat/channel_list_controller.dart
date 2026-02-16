import 'package:flutter/material.dart';

import '../models/chat_channel.dart';
import '../services/discourse_chat_api_service.dart';

class ChannelListController extends ChangeNotifier {
  ChannelListController({required DiscourseChatApiService api}) : _api = api;

  final DiscourseChatApiService _api;

  final List<ChatChannel> _channels = <ChatChannel>[];
  bool _loading = false;
  String? _error;

  List<ChatChannel> get channels => List<ChatChannel>.unmodifiable(_channels);
  bool get loading => _loading;
  String? get error => _error;

  Future<void> loadChannels() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _api.fetchChannels();
      _channels
        ..clear()
        ..addAll(result);
    } catch (e) {
      _error = 'Unable to load channels: $e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> createChannel(String name) async {
    await _api.createChannel(name);
    await loadChannels();
  }

  Future<void> deleteChannel(int channelId) async {
    await _api.deleteChannel(channelId);
    await loadChannels();
  }
}
