import 'package:flutter_test/flutter_test.dart';
import 'package:ping_my_therapist/services/chat_session_service.dart';

void main() {
  test('chat message survives Firestore serialization with its identity', () {
    final timestamp = DateTime.utc(2026, 10, 8, 12, 30);
    final original = ChatSessionMessage(
      role: 'user',
      content: 'I felt calmer after breathing.',
      timestamp: timestamp,
      messageId: 'message-1',
    );

    final restored = ChatSessionMessage.fromMap(original.toMap());
    expect(restored.role, original.role);
    expect(restored.content, original.content);
    expect(restored.timestamp?.toUtc(), timestamp);
    expect(restored.messageId, original.messageId);
  });

  test('restored session preserves conversation order for the chatbot', () {
    final session = ChatSession(
      userId: 'patient-1',
      sessionId: 'session-1',
      messages: [
        ChatSessionMessage(role: 'user', content: 'I feel anxious.'),
        ChatSessionMessage(role: 'assistant', content: 'Take one slow breath.'),
      ],
    );

    final history = session.toChatMessages();
    expect(history.map((message) => message.role), ['user', 'assistant']);
    expect(history.map((message) => message.content), [
      'I feel anxious.',
      'Take one slow breath.',
    ]);
  });
}
