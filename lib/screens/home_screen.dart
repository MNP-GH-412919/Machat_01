// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:contacts_service/contacts_service.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'chat_screen.dart'; // Import the ChatScreen class

// class HomePage extends StatefulWidget {
//   @override
//   _HomePageState createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   @override
//   Widget build(BuildContext context) {
//     final String currentUserId = _auth.currentUser!.uid;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Chats'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.search),
//             onPressed: () {
//               showSearch(
//                 context: context,
//                 delegate: UserSearchDelegate(),
//               );
//             },
//           ),
//         ],
//       ),
//       body: StreamBuilder(
//         stream: _firestore
//             .collection('chats')
//             .where('users', arrayContains: currentUserId)
//             .snapshots(),
//         builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
//           if (!snapshot.hasData) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (snapshot.data!.docs.isEmpty) {
//             return const Center(child: Text('No chats available'));
//           }

//           var chatList = snapshot.data!.docs;

//           return ListView.builder(
//             itemCount: chatList.length,
//             itemBuilder: (context, index) {
//               var chat = chatList[index];
//               var users = chat['users'];
//               String otherUserId =
//                   users.firstWhere((uid) => uid != currentUserId);

//               return ListTile(
//                 title: Text("Chat with User ID: $otherUserId"),
//                 subtitle: Text("Last message: ${chat['lastMessage'] ?? ''}"),
//                 onTap: () {
//                   // Navigate to the chat screen
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => ChatScreen(userId: otherUserId),
//                     ),
//                   );
//                 },
//               );
//             },
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _addNewUserFromContacts,
//         child: const Icon(Icons.person_add),
//       ),
//     );
//   }

//   void _addNewUserFromContacts() async {
//     var status = await Permission.contacts.request();
//     if (status.isGranted) {
//       Iterable<Contact> contacts = await ContactsService.getContacts();
//       List<Contact> contactList = contacts.toList();

//       showDialog(
//         context: context,
//         builder: (context) {
//           return AlertDialog(
//             title: Text('Select a Contact'),
//             content: Container(
//               width: 300,
//               height: 400,
//               child: ListView.builder(
//                 itemCount: contactList.length,
//                 itemBuilder: (context, index) {
//                   var contact = contactList.elementAt(index);
//                   String contactName = contact.displayName ?? "No Name";
//                   String? contactPhoneNumber =
//                       contact.phones?.isNotEmpty == true
//                           ? contact.phones!.first.value
//                           : null;

//                   return ListTile(
//                     title: Text(contactName),
//                     subtitle: contactPhoneNumber != null
//                         ? Text(contactPhoneNumber)
//                         : null,
//                     onTap: () {
//                       if (contactPhoneNumber != null) {
//                         // Navigate to chat with this user
//                         Navigator.pop(context); // Close dialog
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) =>
//                                 ChatScreen(userId: contactPhoneNumber),
//                           ),
//                         );
//                       } else {
//                         // Handle the case where the contact does not have a phone number
//                         Navigator.pop(context);
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                               content: Text(
//                                   "Selected contact does not have a phone number.")),
//                         );
//                       }
//                     },
//                   );
//                 },
//               ),
//             ),
//           );
//         },
//       );
//     } else {
//       print('Contact permission denied');
//     }
//   }
// }

// // UserSearchDelegate for searching users
// class UserSearchDelegate extends SearchDelegate {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   @override
//   List<Widget>? buildActions(BuildContext context) {
//     return [
//       IconButton(
//         icon: const Icon(Icons.clear),
//         onPressed: () {
//           query = '';
//         },
//       ),
//     ];
//   }

//   @override
//   Widget? buildLeading(BuildContext context) {
//     return IconButton(
//       icon: const Icon(Icons.arrow_back),
//       onPressed: () {
//         close(context, null);
//       },
//     );
//   }

//   @override
//   Widget buildResults(BuildContext context) {
//     return StreamBuilder(
//       stream: _firestore
//           .collection('users')
//           .where('username', isGreaterThanOrEqualTo: query)
//           .snapshots(),
//       builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
//         if (!snapshot.hasData) {
//           return const Center(child: CircularProgressIndicator());
//         }
//         var results = snapshot.data!.docs;
//         return ListView.builder(
//           itemCount: results.length,
//           itemBuilder: (context, index) {
//             var user = results[index];
//             return ListTile(
//               title: Text(user['username']),
//               subtitle: Text(user['email']),
//               onTap: () {
//                 // Navigate to chat with this user
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) =>
//                         ChatScreen(userId: user.id), // Pass user ID
//                   ),
//                 );
//               },
//             );
//           },
//         );
//       },
//     );
//   }

//   @override
//   Widget buildSuggestions(BuildContext context) {
//     return Container();
//   }
// }
