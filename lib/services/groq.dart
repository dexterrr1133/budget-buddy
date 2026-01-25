import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

import '../models/transaction.dart';

class GeminiService {
  GeminiService({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  Future<String> getCoachReply({
    required String userMessage,
    required List<TransactionModel> transactions,
  }) async {
    final apiKey = const String.fromEnvironment('GROQ_API_KEY');
    if (apiKey.isEmpty) {
      throw StateError('GROQ_API_KEY is missing. Pass via --dart-define.');
    }

    print('DEBUG: Using API key: ${apiKey.substring(0, 10)}...');
    print('DEBUG: Model: llama-3.3-70b-versatile');

    final recent = _recentTransactions(transactions);
    final contextText = _buildContext(recent);

    final systemPrompt = '''
You are BudgetBuddy's concise financial coach for students. Provide clear, actionable advice in under 120 words. Be supportive and specific. If data is missing, say so briefly.

Context (most recent ${recent.length} transactions):
$contextText
''';

    final requestBody = {
      'model': 'llama-3.3-70b-versatile',
      'messages': [
        {'role': 'system', 'content': systemPrompt},
        {'role': 'user', 'content': userMessage},
      ],
      'temperature': 0.7,
      'max_tokens': 300,
    };

    try {
      print('DEBUG: Sending request to Groq API...');
      final response = await _client.post(
        Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      print('DEBUG: Response status: ${response.statusCode}');

      if (response.statusCode != 200) {
        throw Exception('Groq API error: ${response.statusCode} - ${response.body}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final content = data['choices']?[0]?['message']?['content'] as String?;
      
      print('DEBUG: Response received successfully');
      return content?.trim() ?? 'No response generated.';
    } catch (e, stack) {
      print('DEBUG: API Error: $e');
      print('DEBUG: Stack trace: $stack');
      rethrow;
    }
  }

  List<TransactionModel> _recentTransactions(List<TransactionModel> all) {
    final sorted = [...all]
      ..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(min(20, sorted.length)).toList();
  }

  String _buildContext(List<TransactionModel> txs) {
    if (txs.isEmpty) return 'No transactions available.';
    final buffer = StringBuffer();
    for (final tx in txs) {
      buffer.writeln(
        '- ${tx.date.toIso8601String().split('T').first} | ${tx.type} | ${tx.category} | amount: ${tx.amount.toStringAsFixed(2)}${tx.note != null ? ' | note: ${tx.note}' : ''}',
      );
    }
    return buffer.toString();
  }
}
