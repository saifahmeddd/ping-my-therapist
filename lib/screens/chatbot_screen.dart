import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ping_my_therapist/widgets/stretchy_section_page.dart';
import 'package:ping_my_therapist/widgets/pullable_section_header.dart';
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
    } catch (_) {
      _showPersistenceError('Could not load past conversations. Please retry.');
    }
  }

  void _showPersistenceError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _offerReplySaveRetry(String sessionId, ChatMessage reply) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('The reply was not saved to chat history.'),
        action: SnackBarAction(
          label: 'Retry',
          onPressed: () async {
            try {
              await _chatSessionService.addMessageToSession(sessionId, reply);
              _showPersistenceError('Reply saved to chat history.');
            } catch (_) {
              _offerReplySaveRetry(sessionId, reply);
            }
          },
        ),
      ),
    );
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
      } else if (mounted) {
        setState(() => _isLoading = false);
        _showPersistenceError('This conversation could not be found.');
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showPersistenceError(
          'Could not load this conversation. Please retry.',
        );
      }
    }
  }

  Future<void> _deleteConversation(String sessionId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text(
              'Delete Conversation',
              style: TextStyle(
                fontFamily: 'General Sans',
                fontWeight: FontWeight.w600,
              ),
            ),
            content: const Text(
              'Are you sure you want to delete this conversation?',
              style: TextStyle(fontFamily: 'General Sans'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
    );
    if (shouldDelete == true) {
      try {
        await _chatSessionService.deleteChatSession(sessionId);
        if (_currentSessionId == sessionId) {
          _startNewChat();
        }
        await _loadChatSessions();
      } catch (_) {
        _showPersistenceError(
          'Could not delete this conversation. Please retry.',
        );
      }
    }
  }

  void _restoreUnstoredMessage(String message, ChatMessage chatMessage) {
    if (!mounted) return;
    setState(() {
      _messages.removeLast(); // Typing indicator.
      _messages.removeLast(); // Unstored user message.
      _controller.text = message;
      _isLoading = false;
    });
    _chatHistory.remove(chatMessage);
    _showPersistenceError(
      'Could not save your message. Please try sending it again.',
    );
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

    if (_currentSessionId == null) {
      try {
        _currentSessionId = await _chatSessionService.createChatSession();
      } catch (_) {
        _restoreUnstoredMessage(userMessage, userChatMsg);
        return;
      }
    }

    if (_currentSessionId != null) {
      try {
        await _chatSessionService.addMessageToSession(
          _currentSessionId!,
          userChatMsg,
        );
      } catch (_) {
        _restoreUnstoredMessage(userMessage, userChatMsg);
        return;
      }
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
        final sessionId = _currentSessionId!;
        try {
          await _chatSessionService.addMessageToSession(sessionId, aiMsg);
        } catch (_) {
          _offerReplySaveRetry(sessionId, aiMsg);
        }
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
    final msg =
        custom ?? "I'm sorry, there was a connection issue. Please try again.";
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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: sectionPurple,
        body: SafeArea(
          child: Column(
            children: [
              AnimatedSize(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeInOutCubic,
                child: PullableSectionHeader(
                  title: 'Safe Space',
                  subtitle: 'A quiet place to talk things through.',
                  compact: _messages.any((message) => message.isUser),
                  leading: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  trailing: IconButton(
                    tooltip: 'Chat history',
                    onPressed: _toggleSidebar,
                    icon: SvgPicture.asset(
                      'assets/icons/chatbubble.svg',
                      width: 24,
                      height: 24,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                  child: ColoredBox(
                    color: const Color(0xFFF7F6FF),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Column(
                            children: [
                              Expanded(
                                child: ListView.builder(
                                  controller: _scrollController,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 24,
                                    horizontal: 16,
                                  ),
                                  itemCount: _messages.length,
                                  itemBuilder: (context, index) {
                                    final msg = _messages[index];
                                    return Align(
                                      alignment:
                                          msg.isUser
                                              ? Alignment.centerRight
                                              : Alignment.centerLeft,
                                      child: Container(
                                        margin: EdgeInsets.only(
                                          top: index == 0 ? 0 : 12,
                                          left: msg.isUser ? 36 : 0,
                                          right: msg.isUser ? 0 : 36,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              msg.isUser
                                                  ? sectionPurple
                                                  : Colors.white,
                                          borderRadius: BorderRadius.only(
                                            topLeft: const Radius.circular(20),
                                            topRight: const Radius.circular(20),
                                            bottomLeft: Radius.circular(
                                              msg.isUser ? 20 : 4,
                                            ),
                                            bottomRight: Radius.circular(
                                              msg.isUser ? 4 : 20,
                                            ),
                                          ),
                                        ),
                                        child:
                                            msg.isTyping
                                                ? const _TypingIndicator()
                                                : Text(
                                                  msg.text,
                                                  style: TextStyle(
                                                    color:
                                                        msg.isUser
                                                            ? Colors.white
                                                            : const Color(
                                                              0xFF3A3075,
                                                            ),
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                color: Colors.white,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _controller,
                                        onSubmitted: (_) => _sendMessage(),
                                        enabled: !_isSidebarOpen,
                                        maxLines: 1,
                                        textInputAction: TextInputAction.send,
                                        decoration: InputDecoration(
                                          hintText:
                                              "Share what's on your mind...",
                                          hintStyle: const TextStyle(
                                            color: Colors.grey,
                                          ),
                                          filled: true,
                                          fillColor: const Color(0xFFF5F5FA),
                                          isDense: true,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 10,
                                              ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                            borderSide: BorderSide.none,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      tooltip: 'Send message',
                                      icon: Icon(
                                        _isLoading
                                            ? Icons.hourglass_empty
                                            : Icons.send_rounded,
                                        color: Colors.white,
                                      ),
                                      iconSize: 20,
                                      constraints:
                                          const BoxConstraints.tightFor(
                                            width: 44,
                                            height: 42,
                                          ),
                                      padding: EdgeInsets.zero,
                                      style: IconButton.styleFrom(
                                        backgroundColor:
                                            _isLoading
                                                ? Colors.grey
                                                : sectionPurple,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                      ),
                                      onPressed:
                                          (_isLoading || _isSidebarOpen)
                                              ? null
                                              : _sendMessage,
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
                            builder:
                                (context, _) => Positioned.fill(
                                  child: GestureDetector(
                                    onTap: _closeSidebar,
                                    child: Container(
                                      color: Colors.black.withValues(
                                        alpha: _overlayAnimation.value,
                                      ),
                                    ),
                                  ),
                                ),
                          ),

                        AnimatedBuilder(
                          animation: _sidebarAnimation,
                          builder:
                              (context, _) => Positioned(
                                top: 0,
                                right:
                                    MediaQuery.of(context).size.width *
                                    _sidebarAnimation.value *
                                    -1,
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
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;
  final bool isTyping;
  _ChatMessage({
    required this.text,
    required this.isUser,
    this.isTyping = false,
  });
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
            final opacity = (value < 0.5 ? value * 2 : (1 - value) * 2).clamp(
              0.3,
              1.0,
            );
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
