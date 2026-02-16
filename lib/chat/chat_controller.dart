import 'dart:async';

import 'package:flutter/material.dart';

import '../config.dart';
import '../models/chat_message.dart';
import '../services/discourse_chat_api_service.dart';

class ChatController extends ChangeNotifier {
  ChatController({
    required DiscourseChatApiService api,
    required int channelId,
  })  : _api = api,
        _channelId = channelId;

  final DiscourseChatApiService _api;
  final int _channelId;

  final List<ChatMessage> _messages = <ChatMessage>[];
  bool _loading = false;
  bool _sending = false;
  String? _error;
  Timer? _pollTimer;

  List<ChatMessage> get messages => List<ChatMessage>.unmodifiable(_messages);
  bool get loading => _loading;
  bool get sending => _sending;
  String? get error => _error;

  Future<void> loadInitialMessages() async {
    _loading = true;
    _error = null;
    notifyListeners();

    await _refresh();
    _loading = false;
    notifyListeners();

    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(AppConfig.pollingInterval, (_) {
      _refresh(silent: true);
    });
  }

  Future<void> _refresh({bool silent = false}) async {
    try {
      final result = await _api.fetchMessages(_channelId);
      _messages
        ..clear()
        ..addAll(result.reversed);
      _error = null;
    } catch (e) {
      _error = 'Unable to refresh messages: $e';
    } finally {
      if (!silent) {
        notifyListeners();
      } else {
        notifyListeners();
      }
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    _sending = true;
    _error = null;
    notifyListeners();

    try {
      await _api.sendMessage(channelId: _channelId, message: text.trim());
      await _refresh();
    } catch (e) {
      _error = 'Unable to send message: $e';
    } finally {
      _sending = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }
}
