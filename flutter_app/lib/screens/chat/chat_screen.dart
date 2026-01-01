import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/theme.dart';
import '../../services/chat_service.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatService _chatService = ChatService();

  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      setState(() => _isTyping = true);
      final history = await _chatService.getHistory();
      if (mounted) {
        setState(() {
          _isTyping = false;
          if (history.isNotEmpty) {
            _messages.clear(); // Clear local state to prevent duplicates
            _messages.addAll(history);
          } else {
            _messages.add(ChatMessage(
              content:
                  "Hi! I'm your Gemini 2.0 flash coding assistant. How can I help you build today?",
              isUser: false,
              timestamp: DateTime.now(),
            ));
          }
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(ChatMessage(
            content:
                "Hi! I'm your Gemini 2.0 flash coding assistant. How can I help you build today?",
            isUser: false,
            timestamp: DateTime.now(),
          ));
        });
      }
    }
  }

  Map<String, List<ChatMessage>> _groupHistoryByDate() {
    final Map<String, List<ChatMessage>> groups = {
      'Today': [],
      'Yesterday': [],
      'Previous 7 Days': [],
      'Older': []
    };

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final lastWeek = today.subtract(const Duration(days: 7));

    for (var msg in _messages.where((m) => m.isUser).toList().reversed) {
      final msgDate =
          DateTime(msg.timestamp.year, msg.timestamp.month, msg.timestamp.day);

      if (msgDate.isAtSameMomentAs(today)) {
        groups['Today']!.add(msg);
      } else if (msgDate.isAtSameMomentAs(yesterday)) {
        groups['Yesterday']!.add(msg);
      } else if (msgDate.isAfter(lastWeek)) {
        groups['Previous 7 Days']!.add(msg);
      } else {
        groups['Older']!.add(msg);
      }
    }

    return groups;
  }

  final List<String> _quickPrompts = [
    '💡 What should I learn next?',
    '📊 Analyze my progress',
    '🛠️ Review my latest project',
    '📅 Plan my week',
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        content: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isTyping = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      final response = await _chatService.sendMessage(text);

      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(ChatMessage(
            content: response.message,
            isUser: false,
            timestamp: DateTime.now(),
          ));
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(ChatMessage(
            content:
                "Sorry, I couldn't process that request. Please try again.",
            isUser: false,
            timestamp: DateTime.now(),
          ));
        });
      }
    }
  }

  void _scrollToBottom() {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: AppColors.primary, size: 20),
            SizedBox(width: 8),
            Text('DevTrack AI', style: TextStyle(fontSize: 18)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment_outlined),
            onPressed: () {
              setState(() {
                _messages.clear();
                _messages.add(ChatMessage(
                  content:
                      "Hi! I'm your Gemini 2.0 flash assistant. How can I help you build today?",
                  isUser: false,
                  timestamp: DateTime.now(),
                ));
              });
            },
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: AppColors.surface,
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.auto_awesome,
                        color: Colors.white, size: 40),
                    const SizedBox(height: 12),
                    Text(
                      'DevTrack AI',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.add, color: AppColors.primary),
              title: const Text('New Chat'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _messages.clear();
                  _messages.add(ChatMessage(
                    content:
                        "Hi! I'm your Gemini 2.0 flash coding assistant. How can I help you build today?",
                    isUser: false,
                    timestamp: DateTime.now(),
                  ));
                });
              },
            ),
            const Divider(color: AppColors.border),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: _groupHistoryByDate()
                    .entries
                    .where((e) => e.value.isNotEmpty)
                    .map((entry) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Text(
                          entry.key.toUpperCase(),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                        ),
                      ),
                      ...entry.value.map((msg) => ListTile(
                            dense: true,
                            title: Text(
                              msg.content,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              _messageController.text = msg.content;
                            },
                          )),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isTyping) {
                  return _buildTypingIndicator();
                }
                return _MessageBubble(message: _messages[index])
                    .animate()
                    .fadeIn()
                    .slideY(begin: 0.1);
              },
            ),
          ),

          // Quick prompts
          if (_messages.length <= 1)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _quickPrompts
                    .map((prompt) => InkWell(
                          onTap: () => _sendMessage(prompt.substring(2)),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Text(prompt,
                                style: Theme.of(context).textTheme.bodyMedium),
                          ),
                        ))
                    .toList(),
              ),
            ).animate().fadeIn(delay: 300.ms),

          // Input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Ask me anything...',
                        filled: true,
                        fillColor: AppColors.surfaceLight,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: _sendMessage,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: _isTyping
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send, color: Colors.white),
                      onPressed: _isTyping
                          ? null
                          : () => _sendMessage(_messageController.text),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(right: 80, bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _TypingDot(delay: 0),
            _TypingDot(delay: 200),
            _TypingDot(delay: 400),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          left: message.isUser ? 80 : 0,
          right: message.isUser ? 0 : 80,
          bottom: 8,
        ),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: message.isUser ? AppColors.primaryGradient : null,
          color: message.isUser ? null : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: message.isUser ? null : Border.all(color: AppColors.border),
        ),
        child: Text(
          message.content,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: message.isUser ? Colors.white : AppColors.textPrimary,
              ),
        ),
      ),
    );
  }
}

class _TypingDot extends StatelessWidget {
  final int delay;

  const _TypingDot({required this.delay});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .fadeOut(delay: Duration(milliseconds: delay), duration: 600.ms)
        .then()
        .fadeIn(duration: 600.ms);
  }
}
