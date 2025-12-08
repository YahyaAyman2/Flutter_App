import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// app setup
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MessagesPage(),
    );
  }
}

// messages page
class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  // users data
  List<Map<String, dynamic>> allUsers = [
    {
      "name": "Sara Ahmed",
      "message": "Hello! I'm interested in the apartment.",
      "time": "10:30 AM",
      "unread": 1,
    },
    {
      "name": "Mohamed Osama",
      "message": "Is the apartment still available?",
      "time": "Yesterday",
      "unread": 1,
    },
    {
      "name": "Ahmed Mostafa",
      "message": "Can you send more details?",
      "time": "10/11/2025",
      "unread": 1,
    },
  ];

  List<Map<String, dynamic>> filteredUsers = [];

  @override
  void initState() {
    super.initState();
    filteredUsers = allUsers;
  }

  // search
  void searchUser(String text) {
    setState(() {
      filteredUsers = allUsers
          .where(
            (user) => user["name"]!.toLowerCase().contains(text.toLowerCase()),
          )
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Messages ", style: TextStyle(fontSize: 28)),
        elevation: 0,

        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // search box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Color(0xFF276152), width: 2),
              ),
              child: TextField(
                onChanged: searchUser,
                decoration: const InputDecoration(
                  icon: Icon(Icons.search, color: Color(0xFF276152)),
                  border: InputBorder.none,
                  hintText: "Search",
                ),
              ),
            ),

            const SizedBox(height: 20),

            // list
            Expanded(
              child: ListView(
                children: [
                  for (var user in filteredUsers) ...[
                    ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFF276152),
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      title: Text(user["name"]!),
                      subtitle: Text(user["message"]!),
                      trailing: user["unread"] > 0
                          ? CircleAvatar(
                              radius: 12,
                              backgroundColor: const Color(0xFF276152),
                              child: Text(
                                user["unread"].toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : null,
                      onTap: () {
                        setState(() {
                          user["unread"] = 0;
                        });
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatPage(
                              name: user["name"]!,
                              lastMessage: user["message"]!,
                            ),
                          ),
                        );
                      },
                    ),
                    const Divider(),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// chat page
class ChatPage extends StatefulWidget {
  final String name;
  final String lastMessage;

  const ChatPage({super.key, required this.name, required this.lastMessage});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController messageController = TextEditingController();

  // chat messages
  List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    super.initState();
    messages = [
      {"text": widget.lastMessage, "isMe": false},
    ];
  }

  // send
  void sendMessage() {
    if (messageController.text.trim().isEmpty) return;

    setState(() {
      messages.add({"text": messageController.text.trim(), "isMe": true});
    });

    messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      body: Column(
        children: [
          // messages
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: messages.map((msg) {
                return Align(
                  alignment: msg["isMe"]
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: ChatBubble(text: msg["text"], isMe: msg["isMe"]),
                );
              }).toList(),
            ),
          ),

          // input
          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.grey[200],
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: "Write a message...",
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                GestureDetector(
                  onTap: sendMessage,
                  child: const CircleAvatar(
                    radius: 22,
                    backgroundColor: Color(0xFF276152),
                    child: Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// chat bubble
class ChatBubble extends StatelessWidget {
  final String text;
  final bool isMe;

  const ChatBubble({super.key, required this.text, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: isMe ? const Color(0xFF276152) : Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text),
    );
  }
}