import 'package:google_generative_ai/google_generative_ai.dart';
import '../config/api_config.dart';

class GeminiService {
  late final GenerativeModel _model;
  
  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: ApiConfig.geminiApiKey,
    );
  }
  
  /// Generate AI credit insight for a customer
  Future<String> generateCreditInsight({
    required String customerId,
    required String customerName,
    required double orderValue,
    double? outstandingBalance,
    double? creditLimit,
  }) async {
    try {
      final prompt = '''
You are a credit risk analyst for a B2B distribution company. Analyze the following customer data and provide a brief credit risk assessment:

Customer ID: $customerId
Customer Name: $customerName
Current Order Value: ₹${orderValue.toStringAsFixed(2)}
${outstandingBalance != null ? 'Outstanding Balance: ₹${outstandingBalance.toStringAsFixed(2)}' : ''}
${creditLimit != null ? 'Credit Limit: ₹${creditLimit.toStringAsFixed(2)}' : ''}

Provide a concise 2-3 sentence risk assessment focusing on:
1. Credit exposure level
2. Recommendation (approve/review/reject)
3. Key risk factors if any

Keep it professional and actionable.
''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      
      return response.text ?? 'Unable to generate credit insight at this time.';
    } catch (e) {
      return 'Error generating AI insight: ${e.toString()}';
    }
  }
  
  /// Generate general AI response
  Future<String> generateResponse(String prompt) async {
    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      
      return response.text ?? 'Unable to generate response.';
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }
  
  /// Chat with Gemini (for conversational AI features)
  Future<String> chat(String message, {List<Content>? history}) async {
    try {
      final chat = _model.startChat(history: history ?? []);
      final response = await chat.sendMessage(Content.text(message));
      
      return response.text ?? 'No response generated.';
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }
}
