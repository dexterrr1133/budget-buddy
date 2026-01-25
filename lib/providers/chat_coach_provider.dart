import 'package:flutter/foundation.dart';

import '../models/transaction.dart';
import '../services/groq.dart';

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

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _loading;
  String? get error => _error;

  Future<void> sendMessage({
    required String userMessage,
    required List<TransactionModel> transactions,
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
      );
      _messages.add(ChatMessage(role: 'assistant', text: reply));
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
    notifyListeners();
  }
}
