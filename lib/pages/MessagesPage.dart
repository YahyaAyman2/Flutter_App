import 'package:flutter/material.dart';
class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  int currentIndex = 2; // Messages tab

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // App Bar
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: const [
            Text(
              "Messages",
              style: TextStyle(color: Colors.black, fontSize: 35),
            ),
            SizedBox(width: 8),
            CircleAvatar(
              radius: 10,
              backgroundColor: Colors.black,
              child: Text(
                "1",
                style: TextStyle(fontSize: 12, color: Colors.white),
              ),
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          // search
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "search",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(
                    color: Color(0xFF276152),
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(
                    color: Color(0xFF276152),
                    width: 2,
                  ),
                ),
              ),
            ),
          ),

          Expanded(
            child: ListView(
              children: const [
                // Message 1
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(0xFF276152),
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text("Sara Ahmed"),
                  subtitle: Text("Hello! I’m interested in the apartment."),
                  trailing: Text("10:30 AM"),
                ),
              ],
            ),
          ),
        ],
      ),

      
    );
  }
}