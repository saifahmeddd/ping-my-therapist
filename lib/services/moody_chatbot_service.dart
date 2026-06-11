import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:ping_my_therapist/services/chatbot.dart';

const _kGroqApiUrl = 'https://api.groq.com/openai/v1/chat/completions';
const _kGroqModel = 'llama-3.1-8b-instant';

const _kSystemPrompt = '''
You are Moody, a safe, warm, and supportive AI mental-health companion inside the "Ping My Therapist" app.

Your scope:
You ONLY help with mental health, emotional support, mood reflection, stress, anxiety, sadness, anger, loneliness, overthinking, journaling, coping skills, therapy preparation, and self-care between therapy sessions.

If the user asks about anything outside mental health or emotional well-being, politely refuse and redirect them back to mental-health support.

Examples of out-of-scope topics:
- Coding, homework, general knowledge, politics, news, sports, finance, business, shopping, travel, entertainment, recipes, or unrelated advice.
- Do not answer these topics even if the user insists.
- Instead say something like: "I’m here to support your mental and emotional well-being. I can help you talk through how this is affecting you emotionally, but I can’t help with that topic directly."

Your purpose:
You provide 24/7 emotional support to users between therapy sessions. You help users express their feelings, reflect on their thoughts, calm down during stress, and take small healthy steps forward. You are not a doctor, therapist, psychiatrist, emergency service, or replacement for professional mental-health care.

Core behavior:
- Always respond with empathy first.
- Validate the user's feelings before suggesting anything.
- Keep replies short, practical, and conversational.
- Prefer 2 to 5 sentences unless the user asks for detail.
- Use simple language. No medical jargon.
- Be calm, caring, non-judgmental, and grounded.
- Sound like a wise, supportive friend who listens carefully.
- Ask one gentle follow-up question when it helps the conversation.
- Do not use emojis.
- Do not over-explain.
- Do not lecture the user.

Allowed support:
- Stress
- Anxiety
- Sadness
- Loneliness
- Anger
- Overthinking
- Academic pressure
- Relationship worries
- Low motivation
- Emotional confusion
- Journaling and self-reflection
- Simple coping exercises
- Preparing what to discuss with a therapist
- Encouraging the user to book or speak with a therapist when needed

Helpful coping techniques you may suggest:
- Box breathing
- Slow breathing
- 5-4-3-2-1 grounding
- Journaling
- Naming emotions
- Breaking a problem into smaller steps
- Taking a short walk
- Drinking water
- Resting for a few minutes
- Talking to a trusted friend, family member, or therapist

Safety rules:
- Do NOT diagnose any mental-health condition.
- Do NOT say the user has depression, anxiety disorder, PTSD, bipolar disorder, or any clinical diagnosis.
- Do NOT prescribe, recommend, change, or discuss medication plans.
- Do NOT claim to be a therapist.
- Do NOT replace professional care.
- Do NOT make guarantees like "everything will be fine."
- Do NOT shame, blame, judge, or pressure the user.
- Do NOT encourage harmful behavior, revenge, isolation, substance abuse, self-harm, or violence.
- Do NOT give instructions for self-harm, suicide, violence, abuse, or dangerous actions.

Crisis behavior:
If the user mentions self-harm, suicide, wanting to die, abuse, violence, immediate danger, overdose, or being unsafe:
- Respond with calm urgency and compassion.
- Tell them their safety matters.
- Encourage them to contact emergency services, a crisis helpline, a trusted person, nearby family member, friend, therapist, or hospital immediately.
- Encourage them to move away from anything they could use to hurt themselves.
- Do not continue normal casual conversation.
- Do not ask many questions before giving safety guidance.
- If needed, ask only one simple safety question such as: "Are you in immediate danger right now?"

Normal response structure:
1. Acknowledge the feeling.
2. Offer one practical coping step.
3. Ask one gentle follow-up question if useful.

Out-of-scope response structure:
1. Politely say you can only help with mental-health and emotional well-being.
2. Redirect to the emotional side of the user's message.
3. Ask if they want to talk about how it is making them feel.

Example out-of-scope response:
"I’m here to support your mental and emotional well-being, so I can’t help with that topic directly. But if this situation is making you stressed, anxious, or overwhelmed, I can help you talk through that. How is it affecting you emotionally?"

Your goal:
Help the user feel heard, calmer, safer, and supported while staying strictly focused on mental health, emotional well-being, and therapy-adjacent support.
''';

const _kCrisisReply =
    '''I’m really sorry you’re feeling this way. Your safety matters right now, and you should not face this alone.

Please reach out for immediate support:
• Pakistan: Umang helpline 0317-4288665
• Emergency services: 1122 / 115
• International: Crisis Text Line — text HOME to 741741
• Worldwide directory: findahelpline.com

If you are in immediate danger, please call emergency services or go to the nearest hospital now. If possible, move away from anything that could hurt you and stay near someone you trust.''';

final _kCrisisPatterns = [
  RegExp(r'\bsuicid(e|al|ally)\b', caseSensitive: false),
  RegExp(r'\bkill\s+my\s*self\b', caseSensitive: false),
  RegExp(r'\bkill\s+myself\b', caseSensitive: false),
  RegExp(r'\bend\s+(my|this)\s+life\b', caseSensitive: false),
  RegExp(r'\bself[\s-]?harm\b', caseSensitive: false),
  RegExp(r'\bcut(ting)?\s+(my|myself)\b', caseSensitive: false),
  RegExp(r'\bwant\s+to\s+die\b', caseSensitive: false),
  RegExp(r'\bi\s+want\s+to\s+die\b', caseSensitive: false),
  RegExp(r"\bdon'?t\s+want\s+to\s+(live|be\s+alive)\b", caseSensitive: false),
  RegExp(r'\bhurt(ing)?\s+(my|myself)\b', caseSensitive: false),
  RegExp(r'\boverdos(e|ing)\b', caseSensitive: false),
  RegExp(r'\bno\s+reason\s+to\s+live\b', caseSensitive: false),
  RegExp(r'\bbetter\s+off\s+(dead|without\s+me)\b', caseSensitive: false),
  RegExp(r'\bi\s+am\s+unsafe\b', caseSensitive: false),
  RegExp(r'\bi\s+feel\s+unsafe\b', caseSensitive: false),
  RegExp(r'\bdomestic[\s-]?violence\b', caseSensitive: false),
  RegExp(r'\bsexual[\s-]?assault\b', caseSensitive: false),
  RegExp(r'\babuse(d|)\b', caseSensitive: false),
];

final _kModeratePatterns = [
  RegExp(r'\bhopeless\b', caseSensitive: false),
  RegExp(r'\bworthless\b', caseSensitive: false),
  RegExp(r"\bcan'?t\s+go\s+on\b", caseSensitive: false),
  RegExp(r'\btrapped\b', caseSensitive: false),
  RegExp(r'\bnumb\b', caseSensitive: false),
  RegExp(r'\bbreakdown\b', caseSensitive: false),
  RegExp(r'\bdepressed\b', caseSensitive: false),
  RegExp(r'\banxiet(y|ies)\b', caseSensitive: false),
  RegExp(r'\banxious\b', caseSensitive: false),
  RegExp(r'\bpanic\b', caseSensitive: false),
  RegExp(r'\boverwhelmed\b', caseSensitive: false),
  RegExp(r'\bexhausted\b', caseSensitive: false),
  RegExp(r'\bburnt\s*out\b', caseSensitive: false),
  RegExp(r'\bburnout\b', caseSensitive: false),
];

const _kFallbackReply =
    "I'm sorry, I had trouble responding right now. Please try again in a moment.";

const _kSafeFallbackReply =
    "I’m having trouble connecting right now, but I’m still here with you. Try taking a slow breath in for 4 seconds, hold for 2, and breathe out for 6. Then try sending your message again.";

class MoodyResponse {
  final String reply;
  final String riskLevel; // "low" | "moderate" | "crisis"
  final String timestamp;

  const MoodyResponse({
    required this.reply,
    required this.riskLevel,
    required this.timestamp,
  });
}

class MoodyChatbotService {
  final http.Client _client;

  MoodyChatbotService({http.Client? client})
    : _client = client ?? http.Client();

  Future<MoodyResponse> sendMessage({
    required String message,
    List<ChatMessage> history = const [],
  }) async {
    final trimmedMessage = message.trim();

    if (trimmedMessage.isEmpty) {
      throw const MoodyChatbotException(
        'invalid-argument',
        'Message cannot be empty.',
      );
    }

    final riskLevel = _assessRiskLevel(trimmedMessage);

    if (riskLevel == 'crisis') {
      return MoodyResponse(
        reply: _kCrisisReply,
        riskLevel: 'crisis',
        timestamp: DateTime.now().toIso8601String(),
      );
    }

    final apiKey = dotenv.env['GROQ_API_KEY']?.trim() ?? '';

    if (apiKey.isEmpty) {
      throw const MoodyChatbotException(
        'config',
        'Groq API key not configured. Add GROQ_API_KEY to your .env file.',
      );
    }

    final contextHistory = _contextHistory(history, trimmedMessage);

    final messages = <Map<String, String>>[
      {'role': 'system', 'content': _kSystemPrompt},
      ...contextHistory
          .map(
            (m) => {
              'role': _normalizeRole(m.role),
              'content': m.content.trim(),
            },
          )
          .where((m) => m['content']!.isNotEmpty),
      {'role': 'user', 'content': trimmedMessage},
    ];

    final http.Response response;

    try {
      response = await _client
          .post(
            Uri.parse(_kGroqApiUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $apiKey',
            },
            body: jsonEncode({
              'model': _kGroqModel,
              'messages': messages,
              'max_tokens': 320,
              'temperature': 0.65,
              'top_p': 0.9,
            }),
          )
          .timeout(const Duration(seconds: 30));
    } catch (e) {
      throw MoodyChatbotException('internal', 'Network error: $e');
    }

    if (response.statusCode != 200) {
      final errorMessage = _extractApiError(response);
      throw MoodyChatbotException(
        'internal',
        'Groq API error (${response.statusCode}): $errorMessage',
      );
    }

    final reply = _extractReply(response);

    return MoodyResponse(
      reply: reply,
      riskLevel: riskLevel,
      timestamp: DateTime.now().toIso8601String(),
    );
  }

  static String friendlyError(Object error) {
    if (error is MoodyChatbotException) {
      switch (error.code) {
        case 'config':
          return error.message;
        case 'invalid-argument':
          return 'Please type a message first.';
        case 'internal':
          return _kSafeFallbackReply;
        default:
          return _kFallbackReply;
      }
    }

    return _kFallbackReply;
  }

  static List<ChatMessage> _contextHistory(
    List<ChatMessage> history,
    String message,
  ) {
    var context = trimChatHistory(history);

    if (context.isNotEmpty &&
        context.last.role == 'user' &&
        context.last.content.trim() == message.trim()) {
      context = context.sublist(0, context.length - 1);
    }

    return context;
  }

  static String _assessRiskLevel(String message) {
    if (_kCrisisPatterns.any((re) => re.hasMatch(message))) {
      return 'crisis';
    }

    if (_kModeratePatterns.any((re) => re.hasMatch(message))) {
      return 'moderate';
    }

    return 'low';
  }

  static String _normalizeRole(String role) {
    final normalized = role.toLowerCase().trim();

    if (normalized == 'assistant') return 'assistant';
    if (normalized == 'system') return 'system';

    return 'user';
  }

  static String _extractReply(http.Response response) {
    try {
      final decodedBody = utf8.decode(response.bodyBytes);
      final data = jsonDecode(decodedBody) as Map<String, dynamic>;

      final choices = data['choices'] as List<dynamic>?;

      if (choices == null || choices.isEmpty) {
        return "I'm here with you. Could you tell me a little more about what's on your mind?";
      }

      final firstChoice = choices.first as Map<String, dynamic>;
      final message = firstChoice['message'] as Map<String, dynamic>?;
      final content = message?['content']?.toString().trim();

      if (content == null || content.isEmpty) {
        return "I'm here with you. Could you tell me a little more about what's on your mind?";
      }

      return content;
    } catch (_) {
      return "I'm here with you. Could you tell me a little more about what's on your mind?";
    }
  }

  static String _extractApiError(http.Response response) {
    try {
      final decodedBody = utf8.decode(response.bodyBytes);
      final data = jsonDecode(decodedBody) as Map<String, dynamic>;

      final error = data['error'];

      if (error is Map<String, dynamic>) {
        return error['message']?.toString() ?? 'Unknown API error.';
      }

      return error?.toString() ?? 'Unknown API error.';
    } catch (_) {
      return response.body.isNotEmpty ? response.body : 'Unknown API error.';
    }
  }
}

class MoodyChatbotException implements Exception {
  final String code;
  final String message;

  const MoodyChatbotException(this.code, this.message);

  @override
  String toString() => 'MoodyChatbotException($code): $message';
}
