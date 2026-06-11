import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:ping_my_therapist/services/chatbot.dart';

class ChatSessionService {
  static const String _collectionName = 'chat_sessions';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Uuid _uuid = const Uuid();

  Future<String> createChatSession() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final sessionId = _uuid.v4();
    final now = FieldValue.serverTimestamp();

    await _firestore.collection(_collectionName).doc(sessionId).set({
      'userId': user.uid,
      'sessionId': sessionId,
      'createdAt': now,
      'updatedAt': now,
      'messages': <Map<String, dynamic>>[],
    });

    return sessionId;
  }

  Future<void> addMessageToSession(
    String sessionId,
    ChatMessage message,
  ) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final messageData = {
      'role': message.role,
      'content': message.content,
      'timestamp': Timestamp.now(),
      'messageId': _uuid.v4(),
    };

    await _firestore.collection(_collectionName).doc(sessionId).update({
      'messages': FieldValue.arrayUnion([messageData]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<ChatSession?> getChatSession(String sessionId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final doc =
        await _firestore.collection(_collectionName).doc(sessionId).get();
    if (!doc.exists) return null;
    return ChatSession.fromFirestore(doc);
  }

  Future<List<ChatSession>> getUserChatSessions() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final querySnapshot =
        await _firestore
            .collection(_collectionName)
            .where('userId', isEqualTo: user.uid)
            .get();

    final sessions =
        querySnapshot.docs.map((doc) => ChatSession.fromFirestore(doc)).toList();

    sessions.sort((a, b) {
      final aTime = a.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = b.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime);
    });

    return sessions;
  }

  Future<void> deleteChatSession(String sessionId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');
    await _firestore.collection(_collectionName).doc(sessionId).delete();
  }
}

class ChatSession {
  final String userId;
  final String sessionId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<ChatSessionMessage> messages;

  ChatSession({
    required this.userId,
    required this.sessionId,
    this.createdAt,
    this.updatedAt,
    required this.messages,
  });

  factory ChatSession.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatSession(
      userId: data['userId'] ?? '',
      sessionId: data['sessionId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      messages:
          (data['messages'] as List<dynamic>? ?? [])
              .map(
                (msg) =>
                    ChatSessionMessage.fromMap(msg as Map<String, dynamic>),
              )
              .toList(),
    );
  }

  List<ChatMessage> toChatMessages() {
    return messages
        .map((msg) => ChatMessage(role: msg.role, content: msg.content))
        .toList();
  }
}

class ChatSessionMessage {
  final String role;
  final String content;
  final DateTime? timestamp;
  final String? messageId;

  ChatSessionMessage({
    required this.role,
    required this.content,
    this.timestamp,
    this.messageId,
  });

  factory ChatSessionMessage.fromMap(Map<String, dynamic> map) =>
      ChatSessionMessage(
        role: map['role'] ?? '',
        content: map['content'] ?? '',
        timestamp: (map['timestamp'] as Timestamp?)?.toDate(),
        messageId: map['messageId'],
      );

  Map<String, dynamic> toMap() => {
    'role': role,
    'content': content,
    'timestamp': timestamp != null ? Timestamp.fromDate(timestamp!) : null,
    'messageId': messageId,
  };
}
