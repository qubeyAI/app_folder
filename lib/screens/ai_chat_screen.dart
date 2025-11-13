import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
}

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  _AIChatScreenState createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final List<ChatMessage> messages = [];
  final TextEditingController controller = TextEditingController();
  final ScrollController scrollController = ScrollController();

  final String sheetBotUrl =
      'https://script.google.com/macros/s/AKfycbxR-gTfWZbM2l52uzvkWk6xDgraBXqA3yZepPFKX7kIvThk95foOV0EU4nI-wV3nQXJ/exec';

  Future<String> getHuggingFaceReply(String userMessage) async {
    try {
      final response = await http.post(
        Uri.parse(
            'hf_FAKE_000000000000000000000001'),
        headers: {
          // Optional: add token if you have one
           'Authorization': 'Bearer Yhf_FAKE_000000000000000000000001',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'inputs': userMessage}),
      );

      final data = jsonDecode(response.body);
      if (data is List &&
          data.isNotEmpty &&
          data[0]['generated_text'] != null) {
        return data[0]['generated_text'];
      } else {
        return "Sorry, I couldn't understand that.";
      }
    } catch (e) {
      return "Error";
    }
  }

  Future<void> sendMessage(String text) async {
    setState(() {
      messages.add(ChatMessage(text: text, isUser: true));
    });
    controller.clear();
    _scrollToBottom();

    // 1️⃣ Call existing Sheet bot
    try {
      final response = await http.post(
        Uri.parse(sheetBotUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "category": "Food",
          "amount": 100,
          "type": "Cash",
          "notes": "Test",
          "user": "demo@gmail.com",
        }),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        String sheetReply = body['aiReply'] ?? "No reply";

        setState(() {
          messages.add(ChatMessage(text: sheetReply, isUser: false));
        });
        _scrollToBottom();

        // 2️⃣ Call Hugging Face AI
        String huggingReply = await getHuggingFaceReply(text);
        setState(() {
          messages.add(ChatMessage(text: huggingReply, isUser: false));
        });
        _scrollToBottom();
      } else {
        setState(() {
          messages.add(ChatMessage(
              text: "Error: ${response.statusCode}", isUser: false));
        });
      }
    } catch (e) {
      setState(() {
        messages.add(ChatMessage(text: "Something went wrong, please try again later...", isUser: false));
      });
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "AI Chat",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                return Align(
                  alignment:
                  msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: msg.isUser ? Colors.blue : Colors.grey[850],
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(12),
                        topRight: const Radius.circular(12),
                        bottomLeft: Radius.circular(msg.isUser ? 12 : 0),
                        bottomRight: Radius.circular(msg.isUser ? 0 : 12),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!msg.isUser)
                          const Padding(
                            padding: EdgeInsets.only(right: 6),
                            child: Icon(Icons.smart_toy,
                                color: Colors.lightBlueAccent, size: 20),
                          ),
                        Flexible(
                          child: Text(
                            msg.text,
                            style: TextStyle(
                              color:
                              msg.isUser ? Colors.white : Colors.lightBlueAccent,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            color: Colors.grey[900],
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: "Type your message...",
                      hintStyle: TextStyle(color: Colors.white54),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: () {
                    if (controller.text.trim().isNotEmpty) {
                      sendMessage(controller.text.trim());
                    }
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}