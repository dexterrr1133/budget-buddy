import 'package:flutter/foundation.dart';

import '../models/transaction.dart';
import '../services/groq.dart';
import '../features/onboarding/models/user_profile_model.dart';

class ChatMessage {
  const ChatMessage({required this.role, required this.text});

  final String role; // 'user' or 'assistant'
  final String text;
}

class ChatCoachProvider extends ChangeNotifier {
  ChatCoachProvider({GeminiService? service})
    : _geminiService = service ?? GeminiService();

  final GeminiService _geminiService;

  final List<ChatMessage> _messages = [];
  bool _loading = false;
  String? _error;
  String? _latestAlert;
  String? _latestInsight;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _loading;
  String? get error => _error;
  String? get latestAlert => _latestAlert;
  String? get latestInsight => _latestInsight;

  Future<void> sendMessage({
    required String userMessage,
    required List<TransactionModel> transactions,
    UserProfileModel? profile,
  }) async {
    if (userMessage.trim().isEmpty) return;
    _messages.add(ChatMessage(role: 'user', text: userMessage.trim()));
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final reply = await _geminiService.getCoachReply(
        userMessage: userMessage,
        transactions: transactions,
        profile: profile,
      );
      final highlights = _extractHighlights(reply);
      if (highlights.alert != null) {
        _latestAlert = highlights.alert;
      }
      if (highlights.insight != null) {
        _latestInsight = highlights.insight;
      }
      final cleanedReply = highlights.cleanedReply.trim().isEmpty
          ? reply
          : highlights.cleanedReply;
      _messages.add(ChatMessage(role: 'assistant', text: cleanedReply));
    } catch (e) {
      _error = 'Coach error: $e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void clear() {
    _messages.clear();
    _error = null;
    _latestAlert = null;
    _latestInsight = null;
    notifyListeners();
  }

  _CoachHighlights _extractHighlights(String reply) {
    String? alert;
    String? insight;
    final cleanedLines = <String>[];

    for (final rawLine in reply.split('\n')) {
      final line = rawLine.trim();
      final upper = line.toUpperCase();
      if (upper.startsWith('ALERT:')) {
        final value = line.substring(line.indexOf(':') + 1).trim();
        if (value.isNotEmpty) alert = value;
        continue;
      }
      if (upper.startsWith('INSIGHT:')) {
        final value = line.substring(line.indexOf(':') + 1).trim();
        if (value.isNotEmpty) insight = value;
        continue;
      }
      cleanedLines.add(rawLine);
    }

    return _CoachHighlights(
      alert: alert,
      insight: insight,
      cleanedReply: cleanedLines.join('\n').trim(),
    );
  }
}

class _CoachHighlights {
  const _CoachHighlights({
    required this.alert,
    required this.insight,
    required this.cleanedReply,
  });

  final String? alert;
  final String? insight;
  final String cleanedReply;
}
