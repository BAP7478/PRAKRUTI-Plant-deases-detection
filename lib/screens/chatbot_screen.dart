import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/chat_service.dart';
import '../providers/language_provider.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final _messages = <ChatMessage>[];
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isTyping = false;
  bool _isError = false;
  String _errorMessage = '';
  late ChatService _chatService;
  // Temporarily disabled language controller
  // final _languageController = LanguageController();

  @override
  void initState() {
    super.initState();
    _initChatService();
  }

  Future<void> _initChatService() async {
    try {
      _chatService = await ChatService.create();
      final savedMessages = await _chatService.loadMessages();

      setState(() {
        _messages.addAll(savedMessages);
      });

      if (_messages.isEmpty) {
        // Set initial message based on current language
        // Note: We can't access LanguageProvider here, so we use English as default
        // Users can refresh to get the correct language
        _addBotMessage(
          'Hello! I am your farming assistant. How can I help you today?\n\n'
          'I can help you with:\n'
          '• Plant disease identification\n'
          '• Crop management advice\n'
          '• Weather-based recommendations\n'
          '• Pest control suggestions\n'
          '• Soil health tips',
        );
      }
    } catch (e) {
      _showError('Failed to initialize chat service');
    }
  }

  void _showError(String message) {
    setState(() {
      _isError = true;
      _errorMessage = message;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isError = false;
          _errorMessage = '';
        });
      }
    });
  }

  void _addBotMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
    _scrollToBottom();
  }

  void _handleSubmitted(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = ChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _isTyping = true;
      _isError = false;
    });
    _textController.clear();
    _scrollToBottom();

    try {
      String response;
      try {
        response = await _chatService.getAIResponse(text);
      } catch (e) {
        // If AI service fails, use fallback response
        response = _chatService.getFallbackResponse(text);
      }

      final botMessage = ChatMessage(
        text: response,
        isUser: false,
        timestamp: DateTime.now(),
      );

      setState(() {
        _messages.add(botMessage);
        _isTyping = false;
      });

      // Save messages to local storage
      await _chatService.saveMessages(_messages);
    } catch (e) {
      _showError('Failed to process message: ${e.toString()}');
      setState(() {
        _isTyping = false;
      });
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        final isGujarati = languageProvider.isGujarati;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              isGujarati ? 'AI સહાયક' : 'AI Assistant',
              style: TextStyle(
                fontFamily: isGujarati ? 'NotoSansGujarati' : null,
              ),
            ),
            backgroundColor: Colors.green,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  setState(() {
                    _messages.clear();
                    _addBotMessage(
                      isGujarati
                          ? 'નમસ્તે! હું તમારો કૃષિ સહાયક છું. આજે હું તમને કેવી રીતે મદદ કરી શકું?\n\n'
                              'હું તમને મદદ કરી શકું છું:\n'
                              '• પાકના રોગની ઓળખ\n'
                              '• પાક વ્યવસ્થાપન સલાહ\n'
                              '• હવામાન આધારિત ભલામણો\n'
                              '• જંતુ નિયંત્રણ સૂચનો\n'
                              '• માટીના સ્વાસ્થ્ય ટિપ્સ'
                          : 'Hello! I am your farming assistant. How can I help you today?\n\n'
                              'I can help you with:\n'
                              '• Plant disease identification\n'
                              '• Crop management advice\n'
                              '• Weather-based recommendations\n'
                              '• Pest control suggestions\n'
                              '• Soil health tips',
                    );
                  });
                },
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    return _buildMessage(message, isGujarati);
                  },
                ),
              ),
              if (_isTyping)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        isGujarati
                            ? 'AI ટાઈપ કરી રહ્યું છે...'
                            : 'AI is typing...',
                        style: TextStyle(
                          fontFamily: isGujarati ? 'NotoSansGujarati' : null,
                        ),
                      ),
                    ],
                  ),
                ),
              _buildInputArea(isGujarati),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessage(ChatMessage message, bool isGujarati) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            const CircleAvatar(
              backgroundColor: Colors.green,
              child: Icon(
                Icons.smart_toy,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser ? Colors.green : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isUser ? Colors.white : Colors.black87,
                  fontFamily: isGujarati ? 'NotoSansGujarati' : null,
                ),
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            const CircleAvatar(
              backgroundColor: Colors.blue,
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputArea(bool isGujarati) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -2),
            blurRadius: 4,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText:
                    isGujarati ? 'તમારો સંદેશ લખો...' : 'Type your message...',
                hintStyle: TextStyle(
                  fontFamily: isGujarati ? 'NotoSansGujarati' : null,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              style: TextStyle(
                fontFamily: isGujarati ? 'NotoSansGujarati' : null,
              ),
              onSubmitted: _handleSubmitted,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send),
            color: Colors.green,
            onPressed: () => _handleSubmitted(_textController.text),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _chatService.dispose();
    super.dispose();
  }
}
