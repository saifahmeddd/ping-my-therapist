import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ping_my_therapist/services/chatbot.dart';
import 'package:ping_my_therapist/services/moody_chatbot_service.dart';
import 'package:ping_my_therapist/services/chat_session_service.dart';
import 'package:ping_my_therapist/screens/chat_sidebar.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen>
    with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  final List<ChatMessage> _chatHistory = [];
  bool _isLoading = false;

  final ChatSessionService _chatSessionService = ChatSessionService();
  final MoodyChatbotService _moodyService = MoodyChatbotService();
  String? _currentSessionId;

  late AnimationController _sidebarController;
  late Animation<double> _sidebarAnimation;
  late Animation<double> _overlayAnimation;
  bool _isSidebarOpen = false;
  List<ChatSession> _chatSessions = [];

  @override
  void initState() {
    super.initState();
    _initializeSidebar();
    _initializeChatSession();
    _loadChatSessions();
  }

  void _initializeSidebar() {
    _sidebarController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _sidebarAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _sidebarController, curve: Curves.easeInOut),
    );
    _overlayAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _sidebarController, curve: Curves.easeInOut),
    );
  }

  Future<void> _loadChatSessions() async {
    try {
      final sessions = await _chatSessionService.getUserChatSessions();
      if (mounted) setState(() => _chatSessions = sessions);
    } catch (_) {}
  }

  void _toggleSidebar() {
    setState(() => _isSidebarOpen = !_isSidebarOpen);
    if (_isSidebarOpen) {
      _sidebarController.forward();
      _loadChatSessions();
    } else {
      _sidebarController.reverse();
    }
  }

  void _closeSidebar() {
    setState(() => _isSidebarOpen = false);
    _sidebarController.reverse();
  }

  Future<void> _initializeChatSession() async {
    final userData = await getUserData();
    final userName = userData['name'] ?? 'there';
    final welcome =
        "Hi $userName! I'm here to listen and support you. Feel free to share what's on your mind.";
    if (!mounted) return;
    setState(() {
      _messages.add(_ChatMessage(text: welcome, isUser: false));
      _chatHistory.add(ChatMessage(role: 'assistant', content: welcome));
    });
  }

  void _startNewChat() {
    _closeSidebar();
    setState(() {
      _messages.clear();
      _chatHistory.clear();
      _currentSessionId = null;
      _isLoading = false;
      _controller.clear();
    });
    _initializeChatSession();
  }

  Future<void> _loadConversation(String sessionId) async {
    _closeSidebar();
    setState(() {
      _isLoading = true;
      _messages.clear();
      _chatHistory.clear();
    });
    try {
      final session = await _chatSessionService.getChatSession(sessionId);
      if (session != null && mounted) {
        _currentSessionId = session.sessionId;
        setState(() {
          _messages.addAll(
            session.messages.map(
              (msg) =>
                  _ChatMessage(text: msg.content, isUser: msg.role == 'user'),
            ),
          );
          _chatHistory.addAll(session.toChatMessages());
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteConversation(String sessionId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text(
              'Delete Conversation',
              style: TextStyle(fontFamily: 'General Sans', fontWeight: FontWeight.w600),
            ),
            content: const Text(
              'Are you sure you want to delete this conversation?',
              style: TextStyle(fontFamily: 'General Sans'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Delete', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
    );
    if (shouldDelete == true) {
      await _chatSessionService.deleteChatSession(sessionId);
      if (_currentSessionId == sessionId) _currentSessionId = null;
      await _loadChatSessions();
    }
  }

  void _sendMessage() async {
    final userMessage = _controller.text.trim();
    if (userMessage.isEmpty || _isLoading) return;

    setState(() {
      _messages.add(_ChatMessage(text: userMessage, isUser: true));
      _controller.clear();
      _isLoading = true;
      _messages.add(_ChatMessage(text: '', isUser: false, isTyping: true));
    });
    _scrollToBottom();

    final userChatMsg = ChatMessage(role: 'user', content: userMessage);
    _chatHistory.add(userChatMsg);
    _trimHistory();

    if (_currentSessionId == null && _chatHistory.length > 1) {
      try {
        _currentSessionId = await _chatSessionService.createChatSession();
      } catch (_) {}
    }

    if (_currentSessionId != null) {
      try {
        await _chatSessionService.addMessageToSession(
          _currentSessionId!,
          userChatMsg,
        );
      } catch (_) {}
    }

    try {
      final response = await _moodyService.sendMessage(
        message: userMessage,
        history: List.unmodifiable(_chatHistory),
      );
      if (!mounted) return;
      setState(() => _messages.removeLast());

      final reply = response.reply;
      setState(() => _messages.add(_ChatMessage(text: reply, isUser: false)));
      final aiMsg = ChatMessage(role: 'assistant', content: reply);
      _chatHistory.add(aiMsg);
      _trimHistory();
      if (_currentSessionId != null) {
        try {
          await _chatSessionService.addMessageToSession(_currentSessionId!, aiMsg);
        } catch (_) {}
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _messages.removeLast());
      _addErrorMessage(MoodyChatbotService.friendlyError(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
    _scrollToBottom();
  }

  void _addErrorMessage([String? custom]) {
    final msg = custom ?? "I'm sorry, there was a connection issue. Please try again.";
    setState(() => _messages.add(_ChatMessage(text: msg, isUser: false)));
    _chatHistory.add(ChatMessage(role: 'assistant', content: msg));
  }

  void _trimHistory() {
    const max = 20;
    if (_chatHistory.length > max) {
      _chatHistory.removeRange(0, _chatHistory.length - max);
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _sidebarController.dispose();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF3A3075)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Safe Space',
          style: TextStyle(
            color: Color(0xFF3A3075),
            fontFamily: 'quicksand',
            fontWeight: FontWeight.w700,
            fontSize: 22,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: _toggleSidebar,
              child: SvgPicture.asset(
                'assets/icons/chatbubble.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  Color(0xFF3A3075),
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      return Align(
                        alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: EdgeInsets.only(
                            top: index == 0 ? 0 : 12,
                            left: msg.isUser ? 60 : 0,
                            right: msg.isUser ? 0 : 60,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          decoration: BoxDecoration(
                            color: msg.isUser ? const Color(0xFF6868B9) : const Color(0xFFF6F5FB),
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(20),
                              topRight: const Radius.circular(20),
                              bottomLeft: Radius.circular(msg.isUser ? 20 : 4),
                              bottomRight: Radius.circular(msg.isUser ? 4 : 20),
                            ),
                          ),
                          child: msg.isTyping
                              ? const _TypingIndicator()
                              : Text(
                                  msg.text,
                                  style: TextStyle(
                                    color: msg.isUser ? Colors.white : const Color(0xFF3A3075),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: Colors.white,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          onSubmitted: (_) => _sendMessage(),
                          enabled: !_isSidebarOpen,
                          decoration: InputDecoration(
                            hintText: "Share what's on your mind...",
                            hintStyle: const TextStyle(color: Colors.grey),
                            filled: true,
                            fillColor: const Color(0xFFF5F5FA),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        backgroundColor: _isLoading ? Colors.grey : const Color(0xFF6868B9),
                        radius: 26,
                        child: IconButton(
                          icon: Icon(
                            _isLoading ? Icons.hourglass_empty : Icons.send,
                            color: Colors.white,
                          ),
                          onPressed: (_isLoading || _isSidebarOpen) ? null : _sendMessage,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (_isSidebarOpen)
            AnimatedBuilder(
              animation: _overlayAnimation,
              builder: (context, _) => Positioned.fill(
                child: GestureDetector(
                  onTap: _closeSidebar,
                  child: Container(
                    color: Colors.black.withValues(alpha: _overlayAnimation.value),
                  ),
                ),
              ),
            ),

          AnimatedBuilder(
            animation: _sidebarAnimation,
            builder: (context, _) => Positioned(
              top: 0,
              right: MediaQuery.of(context).size.width * _sidebarAnimation.value * -1,
              bottom: 0,
              child: ChatSidebar(
                onClose: _closeSidebar,
                onNewChat: _startNewChat,
                onConversationTap: _loadConversation,
                onConversationDelete: _deleteConversation,
                chatSessions: _chatSessions,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;
  final bool isTyping;
  _ChatMessage({required this.text, required this.isUser, this.isTyping = false});
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();
  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final delay = i / 3;
            final value = ((_controller.value - delay) % 1.0).clamp(0.0, 1.0);
            final opacity = (value < 0.5 ? value * 2 : (1 - value) * 2).clamp(0.3, 1.0);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Opacity(
                opacity: opacity,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF6868B9),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
