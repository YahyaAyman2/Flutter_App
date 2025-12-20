import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
  } catch (e) {
    print('Firebase initialization error: $e');
  }

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
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  String get currentUserId => auth.currentUser?.uid ?? "";

  // users data

  List<Map<String, dynamic>> allUsers = [
    {
      "id": "user1",
      "name": "Sara Ahmed",
      "message": "Hello! I'm interested in the apartment.",
      "time": "10:30 AM",
      "unread": 1,
    },
    {
      "id": "user2",
      "name": "Mohamed Osama",
      "message": "Is the apartment still available?",
      "time": "Yesterday",
      "unread": 1,
    },
    {
      "id": "user3",
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
    _loadLastMessages();
  }

  // Load last messages from Firebase

  Future<void> _loadLastMessages() async {
    if (currentUserId.isEmpty) return;

    for (var user in allUsers) {
      String chatId = _getChatId(user["id"]!);

      firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .snapshots()
          .listen((snapshot) {
            if (snapshot.docs.isNotEmpty) {
              var lastMessage = snapshot.docs.first.data();

              setState(() {
                user["message"] = lastMessage['text'] ?? user["message"];
              });
            }
          });
    }
  }

  // Generate chat ID

  String _getChatId(String otherUserId) {
    List<String> ids = [currentUserId, otherUserId];
    ids.sort();
    return ids.join('_');
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
      backgroundColor: Colors.white,
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
                              userId: user["id"]!,
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
  final String userId;
  final String name;
  final String lastMessage;

  const ChatPage({
    super.key,
    required this.userId,
    required this.name,
    required this.lastMessage,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController messageController = TextEditingController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  String get currentUserId => auth.currentUser?.uid ?? "";

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  // Initialize chat with pre-designed message

  Future<void> _initializeChat() async {
    if (currentUserId.isEmpty) return;

    try {
      String chatId = _getChatId();

      DocumentSnapshot chatDoc = await firestore
          .collection('chats')
          .doc(chatId)
          .get();

      if (!chatDoc.exists) {
        // Create chat document

        await firestore.collection('chats').doc(chatId).set({
          'participants': [currentUserId, widget.userId],
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Add the pre-designed message as first message

        await firestore
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .add({
              'text': widget.lastMessage,
              'senderId': widget.userId,
              'timestamp': FieldValue.serverTimestamp(),
            });
      }
    } catch (e) {
      print('Error initializing chat: $e');
    }
  }

  // Generate chat ID

  String _getChatId() {
    List<String> ids = [currentUserId, widget.userId];
    ids.sort();
    return ids.join('_');
  }

  // Send message

  Future<void> sendMessage() async {
    if (messageController.text.trim().isEmpty || currentUserId.isEmpty) return;

    String chatId = _getChatId();
    String messageText = messageController.text.trim();

    try {
      await firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add({
            'text': messageText,
            'senderId': currentUserId,
            'timestamp': FieldValue.serverTimestamp(),
          });

      messageController.clear();
    } catch (e) {
      print('Error sending message: $e');

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error sending message: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    String chatId = _getChatId();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.name),
        backgroundColor: Color(0xFF276152),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // messages
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: firestore
                  .collection('chats')
                  .doc(chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: false)
                  .snapshots(),

              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No messages yet'));
                }

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: snapshot.data!.docs.map((doc) {
                    Map<String, dynamic> data =
                        doc.data() as Map<String, dynamic>;

                    bool isMe = data['senderId'] == currentUserId;

                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: ChatBubble(text: data['text'] ?? '', isMe: isMe),
                    );
                  }).toList(),
                );
              },
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
      child: Text(
        text,
        style: TextStyle(color: isMe ? Colors.white : Colors.black),
      ),
    );
  }
}