import 'package:chatgpt_clone/pages/chat_gpt.dart';
import 'package:chatgpt_clone/utils/consts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

class ChatGemini extends StatefulWidget {
  const ChatGemini({super.key});

  @override
  State<ChatGemini> createState() => _ChatGeminiState();
}

class _ChatGeminiState extends State<ChatGemini> {
  late Gemini gemini; // Declare gemini as a late variable

  List<ChatMessage> messages = [];
  List<ChatUser> _typingUsers = <ChatUser>[];

  ChatUser currentUser = ChatUser(id: "0", firstName: "User", lastName: '');
  ChatUser geminiUser = ChatUser(
    id: "1",
    firstName: "Gemini",
    profileImage:
        "https://seeklogo.com/images/G/google-gemini-logo-A5787B2669-seeklogo.com.png",
  );

  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Initialize the Gemini instance
    Gemini.init(apiKey: GEMINI_API_KEY, enableDebugging: true);
    gemini = Gemini.instance; // Now assign the instance after initialization
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Gemini Demo"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return _buildMessage(message);
              },
            ),
          ),
          _buildInputField(),
        ],
      ),
    );
  }

  Widget _buildMessage(ChatMessage message) {
    return ListTile(
      title: Row(
        children: [
          CircleAvatar(
            backgroundImage: message.user.profileImage != null
                ? NetworkImage(message.user.profileImage!)
                : null,
          ),
          SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message.user.firstName),
              SizedBox(height: 4),
              Text(message.text),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Type a message',
                border: OutlineInputBorder(),
              ),
              onSubmitted: _sendMessage,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () => _sendMessage(_controller.text),
          ),
        ],
      ),
    );
  }

  void _sendMessage(String text) {
    if (text.isEmpty) return;

    // Add the user message to the list
    setState(() {
      messages.insert(
        0,
        ChatMessage(
          user: currentUser,
          createdAt: DateTime.now(),
          text: text,
        ),
      );
    });

    try {
      Gemini.instance.prompt(parts: [
        Part.text(text),
      ]).then((value) {
        if (value?.output != null) {
          setState(() {
            _typingUsers.add(geminiUser);
          });

          ChatMessage geminiMessage = ChatMessage(
            user: geminiUser,
            createdAt: DateTime.now(),
            text: value!.output.toString(),
          );

          setState(() {
            messages.insert(0, geminiMessage);
          });
        }
      });
    } catch (e) {
      print("Error sending message: $e");
    }

    // Clear the input field after sending
    _controller.clear();
  }
}

extension on String? {}
