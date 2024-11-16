import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:machat/screens/auth/login_screen.dart';
import 'package:machat/screens/chat/chat.dart';
import 'package:machat/screens/groupContact.dart';
import 'package:machat/screens/profilepage.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  List<Map<String, dynamic>> chats = [];
  List<Map<String, dynamic>> filteredChats = [];
  TextEditingController searchController = TextEditingController();
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    _fetchChats();
  }

  void _fetchChats() {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      FirebaseFirestore.instance
          .collection('chat')
          .where('participants', arrayContains: currentUser.uid)
          .snapshots()
          .listen((snapshot) async {
        List<Map<String, dynamic>> tempChats = [];

        for (var doc in snapshot.docs) {
          List<String> participants = List<String>.from(doc['participants']);
          participants.remove(currentUser.uid);

          if (participants.isNotEmpty) {
            DocumentSnapshot userDoc = await FirebaseFirestore.instance
                .collection('Users')
                .doc(participants.first)
                .get();

            if (userDoc.exists) {
              Map<String, dynamic> userData =
                  userDoc.data() as Map<String, dynamic>;
              String participantName = userData['empname'] ?? 'Unknown User';

              // Fetch unread messages for this chat
              QuerySnapshot messageSnapshot = await doc.reference
                  .collection('messages')
                  .where('isRead', isEqualTo: false)
                  .where('receiver', isEqualTo: currentUser.uid)
                  .get();

              bool hasUnreadMessages = messageSnapshot.docs.isNotEmpty;

              tempChats.add({
                'chatID': doc.id,
                'participantID': participants.first,
                'participantName': participantName,
                'hasUnreadMessages': hasUnreadMessages, // Add unread status
              });
            }
          }
        }

        // Update the UI with the fetched chat data
        if (mounted) {
          setState(() {
            chats = tempChats;
            filteredChats = tempChats;
          });
        }
      });
    }
  }

  // Mark messages as read in Firestore when the user opens the chat
  Future<void> _markMessagesAsRead(String chatID) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    QuerySnapshot messageSnapshot = await FirebaseFirestore.instance
        .collection('chat')
        .doc(chatID)
        .collection('message')
        .where('isRead', isEqualTo: false)
        .where('receiver', isEqualTo: currentUser.uid)
        .get();

    for (var message in messageSnapshot.docs) {
      await message.reference.update({
        'isRead': true,
      });
    }

    // Update `hasUnreadMessages` to false in chat document
    await FirebaseFirestore.instance
        .collection('chat')
        .doc(chatID)
        .update({'hasUnreadMessages': false});
  }

  // Filter chats based on search query
  void _filterChats(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredChats = chats;
      });
    } else {
      setState(() {
        filteredChats = chats
            .where((chat) => chat['participantName']
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  Future<int> getUnreadMessageCount(String chatId, String currentUserId) async {
    // Get the messages collection for the specific chat
    QuerySnapshot messagesSnapshot = await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('receiver',
            isEqualTo:
                currentUserId) // Check for messages directed to the current user
        .where('isRead', isEqualTo: false) // Only fetch unread messages
        .get();

    return messagesSnapshot.docs.length; // Return the number of unread messages
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: isSearching
            ? TextField(
                controller: searchController,
                autofocus: true,
                cursorColor: Colors.white,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Search...",
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                onChanged: (query) => _filterChats(query),
              )
            : const Text("Chats"),
        actions: [
          IconButton(
            icon: Icon(isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                isSearching = !isSearching;
                if (!isSearching) {
                  searchController.clear();
                  filteredChats = chats;
                }
              });
            },
          ),
          PopupMenuButton<String>(
            onSelected: (String result) async {
              if (result == 'Profile') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Profilepage()),
                );
              } else if (result == 'Sign Out') {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              } else if (result == 'Group chat') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserListScreen()),
                );
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'Profile',
                child: Text('Profile'),
              ),
              const PopupMenuItem<String>(
                value: 'Sign Out',
                child: Text('Sign Out'),
              ),
              const PopupMenuItem<String>(
                value: 'Group chat',
                child: Text('Group chat'),
              ),
            ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
          )
        ],
      ),
      body: ListView.builder(
        itemCount: filteredChats.length,
        itemBuilder: (context, index) {
          var chat = filteredChats[index];
          return Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 25.0),
                title: Text(
                  chat['participantName'],
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                //
                trailing: chat['hasUnreadMessages']
                    ? Icon(Icons.circle, color: Colors.red, size: 12)
                    : null,

                onTap: () {
                  _markMessagesAsRead(chat['chatID']);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatPage(
                        chatID: chat['chatID'],
                        empName: chat['participantName'],
                        empCode: 'Employee Code',
                      ),
                    ),
                  );
                },
              ),
              Divider(
                height: 1,
                thickness: 1,
                color: Colors.grey.withOpacity(0.5),
                indent: 16,
                endIndent: 16,
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          User? currentUser = FirebaseAuth.instance.currentUser;
          if (currentUser == null) {
            return;
          }

          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(25.0),
              ),
            ),
            builder: (BuildContext context) {
              return _buildUserList(currentUser);
            },
          );
        },
        backgroundColor: Colors.amber,
        child: const Icon(Icons.people_alt),
      ),
    );
  }

  Widget _buildUserList(User currentUser) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('Users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error fetching data'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No data available'));
        }

        var filteredDocs = snapshot.data!.docs.where((doc) {
          return doc.id != currentUser.uid;
        }).toList();

        filteredDocs.sort((a, b) {
          return a['empname'].toString().compareTo(b['empname'].toString());
        });

        return ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(25.0),
          ),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.8,
            child: ListView.builder(
              itemCount: filteredDocs.length,
              itemBuilder: (context, index) {
                var doc = filteredDocs[index];
                var empCode = doc['empcode'] ?? '';
                var empName = doc['empname'] ?? '';

                return Column(
                  children: [
                    ListTile(
                      title: Text(
                        empName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      subtitle: Text(
                        empCode,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                      onTap: () async {
                        final chatRef =
                            FirebaseFirestore.instance.collection('chat');
                        final userID = currentUser.uid;
                        final userName = currentUser.displayName ?? '';

                        final otherUserID = doc.id;
                        final otherUserName = doc['empname'] ?? '';

                        QuerySnapshot existingChat = await chatRef
                            .where('participants', arrayContains: userID)
                            .get();

                        String chatID = '';
                        bool chatExists = false;

                        for (var chatDoc in existingChat.docs) {
                          var participants =
                              List<String>.from(chatDoc['participants']);
                          if (participants.contains(otherUserID)) {
                            chatID = chatDoc.id;
                            chatExists = true;
                            break;
                          }
                        }

                        if (!chatExists) {
                          DocumentReference newChatDoc = await chatRef.add({
                            'participants': [userID, otherUserID],
                            'lastMessage': '',
                            'lastMessageTime': FieldValue.serverTimestamp(),
                          });
                          chatID = newChatDoc.id;
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatPage(
                              chatID: chatID,
                              empName: otherUserName,
                              empCode: empCode,
                            ),
                          ),
                        );
                      },
                    ),
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: Colors.grey.withOpacity(0.5),
                      indent: 16,
                      endIndent: 16,
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
