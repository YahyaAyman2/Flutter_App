import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }
  runApp(const MyApp());
}

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

// ==========================================
// MESSAGES PAGE (List of Chats)
// ==========================================

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final TextEditingController _searchController = TextEditingController();

  String get currentUserId => auth.currentUser?.uid ?? "";
  String _searchQuery = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Messages",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        automaticallyImplyLeading: false, // Hide back button on main tab
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF276152), width: 2),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.trim();
                  });
                },
                decoration: const InputDecoration(
                  icon: Icon(Icons.search, color: Color(0xFF276152)),
                  border: InputBorder.none,
                  hintText: "Search owners...",
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Content: Search Results OR Active Chats
            Expanded(
              child: _searchQuery.isNotEmpty
                  ? _buildSearchResults()
                  : _buildActiveChats(),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Build Active Chats List (Stream)
  Widget _buildActiveChats() {
    if (currentUserId.isEmpty) {
      return const Center(child: Text("Please log in to view messages"));
    }

    return StreamBuilder<QuerySnapshot>(
      // Listen to chats where I am a participant
      stream: firestore
          .collection('chats')
          .where('participants', arrayContains: currentUserId)
          .orderBy('lastMessageTime', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text("No messages yet", style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.separated(
          itemCount: snapshot.data!.docs.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            var doc = snapshot.data!.docs[index];
            var data = doc.data() as Map<String, dynamic>;

            // Identify the other user
            List<dynamic> participants = data['participants'] ?? [];
            String otherUserId = participants.firstWhere(
              (id) => id != currentUserId,
              orElse: () => "",
            );

            // Get name/image from stored map if available
            Map<String, dynamic> names = data['participantNames'] ?? {};
            String displayName = names[otherUserId] ?? "User"; // Fallback name

            // Safe access to other fields
            String lastMessage = data['lastMessage'] ?? "Photo";

            return ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF276152),
                child: Text(
                  displayName.isNotEmpty ? displayName[0].toUpperCase() : "?",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(
                displayName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                lastMessage,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[600]),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatPage(
                      userId: otherUserId,
                      name: displayName,
                      lastMessage: "", // Not sending a new init message
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // ✅ Build Global Search Results (Owners)
  Widget _buildSearchResults() {
    return FutureBuilder<List<Map<String, String>>>(
      future: _searchOwners(_searchQuery),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        List<Map<String, String>> owners = snapshot.data ?? [];

        if (owners.isEmpty) {
          return const Center(child: Text("No owners found"));
        }

        return ListView.separated(
          itemCount: owners.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            final owner = owners[index];
            return ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: Text(owner['name'] ?? "Unknown"),
              subtitle: const Text("Property Owner"),
              trailing: const Icon(Icons.message, color: Color(0xFF276152)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatPage(
                      userId: owner['id']!,
                      name: owner['name']!,
                      lastMessage: "Hello!", // Default greeting for new chat
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // Search Logic: Find owners in 'properties' collection
  Future<List<Map<String, String>>> _searchOwners(String query) async {
    if (query.isEmpty) return [];

    try {
      // Note: Full text search is not natively supported by Firestore client-side easily.
      // We will fetch properties where userName likely matches.

      QuerySnapshot snapshot = await firestore
          .collection('properties')
          .where('userName', isGreaterThanOrEqualTo: query)
          .where('userName', isLessThan: '$query\uf8ff')
          .get();

      // Deduplicate owners
      Set<String> processedIds = {};
      List<Map<String, String>> results = [];

      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        String uid = data['userId'] ?? "";
        String name = data['userName'] ?? "Unknown";

        if (uid.isNotEmpty &&
            uid != currentUserId &&
            !processedIds.contains(uid)) {
          processedIds.add(uid);
          results.add({'id': uid, 'name': name});
        }
      }
      return results;
    } catch (e) {
      debugPrint("Search error: $e");
      return [];
    }
  }
}

// ==========================================
// CHAT PAGE (Conversation)
// ==========================================

class ChatPage extends StatefulWidget {
  final String userId; // The OTHER user's ID
  final String name; // The OTHER user's Name
  final String lastMessage; // Optional initial message string (for context)

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
  final ScrollController _scrollController = ScrollController();

  String get currentUserId => auth.currentUser?.uid ?? "";

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    if (currentUserId.isEmpty) return;

    try {
      String chatId = _getChatId();
      DocumentReference chatRef = firestore.collection('chats').doc(chatId);
      DocumentSnapshot chatDoc = await chatRef.get();

      // 1. Get MY Name (Sender) logic - More Robust
      String myName = "User";
      try {
        DocumentSnapshot myProfile = await firestore
            .collection('users')
            .doc(currentUserId)
            .get();
        if (myProfile.exists) {
          final data = myProfile.data() as Map<String, dynamic>;
          // Try multiple fields to find a valid name
          if (data['first name'] != null &&
              data['first name'].toString().isNotEmpty) {
            myName = data['first name'];
            if (data['last name'] != null) {
              myName += " ${data['last name']}";
            }
          } else if (data['firstName'] != null) {
            myName = data['firstName'];
          } else if (data['name'] != null) {
            myName = data['name'];
          } else if (data['username'] != null) {
            myName = data['username'];
          }
        }
      } catch (e) {
        debugPrint("Could not fetch my profile: $e");
      }

      // 2. Prepare Updates
      // We want to ensure both partipants have names stored.
      // Use proper Firestore dot notation for updating map fields without overwriting
      Map<String, dynamic> updates = {
        'participants': FieldValue.arrayUnion([currentUserId, widget.userId]),
        'participantNames.$currentUserId': myName,
        'participantNames.${widget.userId}': widget.name,
      };

      if (!chatDoc.exists) {
        // Initial creation attributes
        updates['createdAt'] = FieldValue.serverTimestamp();
        updates['lastMessage'] = widget.lastMessage.isNotEmpty
            ? widget.lastMessage
            : 'Chat started';
        updates['lastMessageTime'] = FieldValue.serverTimestamp();

        // Creating with set - but we can construct the object cleanly first
        await chatRef.set({
          'participants': [currentUserId, widget.userId],
          'participantNames': {
            currentUserId: myName,
            widget.userId: widget.name,
          },
          'lastMessage': updates['lastMessage'],
          'lastMessageTime': updates['lastMessageTime'],
          'createdAt': updates['createdAt'],
        });

        // Add initial message if provided
        if (widget.lastMessage.isNotEmpty) {
          await chatRef.collection('messages').add({
            'text': widget.lastMessage,
            'senderId': currentUserId,
            'timestamp': FieldValue.serverTimestamp(),
          });
        }
      } else {
        // Just update the names and ensure participants array is correct
        await chatRef.update(updates);
      }
    } catch (e) {
      debugPrint('Error initializing chat: $e');
    }
  }

  String _getChatId() {
    List<String> ids = [currentUserId, widget.userId];
    ids.sort();
    return ids.join('_');
  }

  Future<void> sendMessage() async {
    String text = messageController.text.trim();
    if (text.isEmpty || currentUserId.isEmpty) return;

    messageController.clear();
    String chatId = _getChatId();

    try {
      // 1. Add message to subcollection
      await firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add({
            'text': text,
            'senderId': currentUserId,
            'timestamp': FieldValue.serverTimestamp(),
          });

      // 2. Update parent chat document (Critical for MessagesPage list)
      await firestore.collection('chats').doc(chatId).update({
        'lastMessage': text,
        'lastMessageTime': FieldValue.serverTimestamp(),
      });

      // Scroll to bottom
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } catch (e) {
      debugPrint('Error sending message: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String chatId = _getChatId();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF276152),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: firestore
                  .collection('chats')
                  .doc(chatId)
                  .collection('messages')
                  .orderBy(
                    'timestamp',
                    descending: true,
                  ) // Newest at bottom if reversed
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError)
                  return Center(child: Text('Error: ${snapshot.error}'));
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Say Hello! 👋'));
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true, // Start from bottom
                  padding: const EdgeInsets.all(16),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var doc = snapshot.data!.docs[index];
                    var data = doc.data() as Map<String, dynamic>;
                    bool isMe = data['senderId'] == currentUserId;

                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: ChatBubble(
                        text: data['text'] ?? '',
                        isMe: isMe,
                        time: data['timestamp'] as Timestamp?,
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Input Area
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: sendMessage,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color(0xFF276152),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 20,
                    ),
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

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isMe;
  final Timestamp? time;

  const ChatBubble({
    super.key,
    required this.text,
    required this.isMe,
    this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isMe ? const Color(0xFF276152) : Colors.grey[200],
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: isMe
              ? const Radius.circular(16)
              : const Radius.circular(0),
          bottomRight: isMe
              ? const Radius.circular(0)
              : const Radius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: TextStyle(
              color: isMe ? Colors.white : Colors.black87,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
