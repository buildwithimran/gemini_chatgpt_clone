import 'package:chat_gpt_sdk/src/model/chat_complete/response/chat_choice.dart';
import 'package:chatgpt_clone/utils/consts.dart';
import 'package:chatgpt_clone/utils/theme.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter/material.dart';

class ChatUser {
  String id;
  String firstName;
  String? lastName;
  String? profileImage;

  ChatUser({
    required this.id,
    required this.firstName,
    this.lastName,
    this.profileImage,
  });
}

class ChatMessage {
  final ChatUser user;
  final DateTime createdAt;
  String text;

  ChatMessage({
    required this.user,
    required this.createdAt,
    required this.text,
  });
}

class ChatGptPage extends StatefulWidget {
  const ChatGptPage({super.key});

  @override
  State<ChatGptPage> createState() => _ChatGptPageState();
}

class _ChatGptPageState extends State<ChatGptPage> {
  final _openAI = OpenAI.instance.build(
    token: OPENAI_API_KEY,
    baseOption: HttpSetup(
      receiveTimeout: const Duration(seconds: 30),
    ),
    enableLog: true,
  );

  final TextEditingController _controller = TextEditingController();

  final ChatUser _user = ChatUser(
    id: '1',
    firstName: 'pk',
    lastName: 'khan',
  );

  final ChatUser _gptChatUser = ChatUser(
    id: '2',
    firstName: 'Chat',
    lastName: 'GPT',
  );

  final List<ChatMessage> _messages = [];
  List<ChatUser> _typingUsers = <ChatUser>[];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text(
          'Chat Gpt Demo',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessage(message);
              },
            ),
          ),
          if (_typingUsers.isNotEmpty) _buildTypingIndicator(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(ChatMessage message) {
    final isUserMessage = message.user.id == _user.id;
    return Align(
      alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: isUserMessage ? Colors.blueAccent : Colors.grey[300],
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: isUserMessage ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(width: 8.0),
          Text('${_typingUsers.length} user(s) typing...'),
        ],
      ),
    );
  }

  Future<void> _sendMessage() async {
    if (_controller.text.isEmpty) return;

    dynamic userMessage = ChatMessage(
      user: _user,
      createdAt: DateTime.now(),
      text: _controller.text,
    );

    setState(() {
      _messages.insert(0, userMessage);
      _controller.clear(); // Clear input field after sending the message
    });

    // Send the user message to GPT and get the response
    await getChatResponse(userMessage);
  }

  Future<void> getChatResponse(ChatMessage m) async {
    setState(() {
      _typingUsers.add(_gptChatUser);
    });

    List<Map<String, dynamic>> messageMaps =
        _messages.map((message) => _chatMessageToMap(message)).toList();

    final request = ChatCompleteText(
      messages: messageMaps,
      maxToken: 200,
      model: GptTurboChatModel(),
    );

    final response = await _openAI.onChatCompletion(request: request);
    for (var element in response!.choices) {
      // Assuming the response contains a 'choices' field
      setState(() {
        _typingUsers.remove(_gptChatUser);
        _messages.insert(
          0,
          ChatMessage(
            user: _gptChatUser,
            createdAt: DateTime.now(),
            text: element.message!.content.toString(),
          ),
        );
      });
    }
  }

  Map<String, dynamic> _chatMessageToMap(ChatMessage message) {
    return {
      'role': message.user.id == _user.id ? 'user' : 'assistant',
      'content': message.text,
    };
  }
}

extension on ChatChoice {
  get content => null;
}
