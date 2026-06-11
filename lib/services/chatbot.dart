import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ping_my_therapist/services/user_data_service.dart';

final UserDataService _userDataService = UserDataService();

Future<Map<String, dynamic>> getUserData() async {
  try {
    final response = await _userDataService.getUserData();
    return {
      'name': response['name'] ?? 'User',
      'age': response['age'] ?? '',
      'occupation': response['occupation'] ?? '',
    };
  } catch (_) {
    return {'name': 'User', 'age': '', 'occupation': ''};
  }
}

Future<List<Map<String, dynamic>>> getOnboardingResponses() async {
  try {
    final response = await _userDataService.getOnboardingResponses();
    final answers = response['answers'] as Map<String, dynamic>? ?? {};
    return [
      {
        'question': 'When life gets overwhelming, you usually...',
        'answer': answers['answer1'] ?? '',
      },
      {
        'question': 'What motivates you the most right now?',
        'answer': answers['answer2'] ?? '',
      },
      {'additional context about user': answers['additional_context'] ?? ''},
    ];
  } catch (_) {
    return [];
  }
}

const _systemPromptTemplate = '''
You are a compassionate and professional mental health counselor. Your role is to provide empathetic support by actively listening to users' thoughts, feelings, and concerns, helping them explore and process their emotions through structured therapeutic conversation.

Use the following data to personalize your responses:
- User's data: {userData}

- Personal Questions: 
 {onboardingResponses}

**Core Approach:**
- **Active Listening**: Reflect back what users share, validating their emotions to show understanding
- **Empathetic Exploration**: Ask thoughtful, open-ended questions that encourage deeper emotional exploration
- **Non-Directive Guidance**: Help users find their own solutions through reflection rather than giving direct advice
- **Warm Professionalism**: Maintain a conversational, caring tone that feels natural and supportive

**Key Behaviors:**
- Encourage self-reflection and personal growth through gentle guidance
- Keep responses concise (2-3 sentences) while maintaining emotional depth
- Avoid judgmental, dismissive, or prescriptive language

**Boundaries:**
- Stay within your counselor role - you are not a coach, doctor, or resource provider
- Do not offer diagnoses, specific advice, or external resources
- For non-mental health topics, respond: "I'm here as your supportive mental health counselor. I can only discuss your thoughts, feelings, or emotional concerns."
- Only respond based on what users explicitly share - do not infer personal details
- Use text only - no emojis or special symbols

(Do not mention any of the above in your responses)

Your goal is creating a safe space for emotional exploration and self-discovery through empathetic, structured conversation.
''';

class ChatMessage {
  final String role;
  final String content;
  final DateTime timestamp;

  ChatMessage({required this.role, required this.content, DateTime? timestamp})
    : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'role': role,
    'content': content,
    'timestamp': timestamp.toIso8601String(),
  };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    role: json['role'],
    content: json['content'],
    timestamp: DateTime.parse(json['timestamp']),
  );

  @override
  String toString() => '${role == "user" ? "User" : "Assistant"}: $content';
}

String _formatChatHistory(List<ChatMessage> history) {
  if (history.isEmpty) return '';
  final buf = StringBuffer('\n\nPrevious conversation:');
  for (final msg in history) {
    buf.writeln(msg.role == 'user' ? 'User: ${msg.content}' : 'Assistant: ${msg.content}');
  }
  return buf.toString();
}

List<ChatMessage> trimChatHistory(List<ChatMessage> history) {
  const maxLen = 20;
  if (history.length <= maxLen) return history;
  return history.sublist(history.length - maxLen);
}

Future<String> _buildSystemPrompt() async {
  final userData = await getUserData();
  final onboardingResponses = await getOnboardingResponses();
  return _systemPromptTemplate
      .replaceAll('{userData}', jsonEncode(userData))
      .replaceAll('{onboardingResponses}', jsonEncode(onboardingResponses));
}

Future<Map<String, dynamic>> callRunpodEndpoint(
  String userMessage,
  List<ChatMessage> chatHistory,
) async {
  final apiKey = dotenv.env['RUNPOD_API_KEY'] ?? '';
  final url = Uri.parse('https://api.runpod.ai/v2/4c02bw5wej9lex/runsync');
  final trimmed = trimChatHistory(chatHistory);
  final historyContext = _formatChatHistory(trimmed);
  final systemPrompt = await _buildSystemPrompt();
  final combinedPrompt =
      '$systemPrompt$historyContext\n\nUser: $userMessage\nAssistant:';

  final payload = {
    'input': {
      'prompt': combinedPrompt,
      'sampling_params': {
        'max_tokens': 200,
        'stop': ['</s>', '[/INST]', '<|end_of_text|>', '<|eot_id|>', 'User: '],
        'stop_token_ids': [2, 128001, 128009],
        'temperature': 0.3,
      },
    },
  };

  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    },
    body: jsonEncode(payload),
  );

  if (response.statusCode == 200) {
    return jsonDecode(utf8.decode(response.bodyBytes));
  } else {
    throw Exception('API error: ${response.statusCode} ${response.body}');
  }
}
