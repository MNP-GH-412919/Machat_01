import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String userId; // User ID of the chat partner

  const ChatScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      // Get current user's ID
      String currentUserId = _auth.currentUser!.uid;

      // Add message to Firestore
      await _firestore.collection('chats').add({
        'text': _messageController.text,
        'sender': currentUserId,
        'recipientId': widget.userId,
        'timestamp': FieldValue.serverTimestamp(),
        'users': [currentUserId, widget.userId], // Store both user IDs
      });

      // Clear the input field after sending the message
      _messageController.clear();

      // Scroll to the bottom
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat with User ID: ${widget.userId}"),
      ),
      body: Column(
        children: <Widget>[
          // Display the list of messages
          Expanded(
            child: StreamBuilder(
              stream: _firestore
                  .collection('chats')
                  .where('users', arrayContains: widget.userId)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true, // New messages appear at the bottom
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var message = messages[index];
                    return ListTile(
                      title: Text(
                        message['text'],
                        style: TextStyle(
                          color: _auth.currentUser?.uid == message['sender']
                              ? Colors.green
                              : Colors.blue,
                        ),
                      ),
                      subtitle: Text(message['sender'] ?? 'Anonymous'),
                    );
                  },
                );
              },
            ),
          ),
          // Text input field and send button
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Enter your message...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                  color: Colors.blue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
