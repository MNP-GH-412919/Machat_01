import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:machat/model/usermodel.dart'; // Adjust import based on your project structure

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addUser(UserModel user, String uid) async {
    try {
      // Use the UID as the document ID
      await _db.collection('Users').doc(uid).set(user.toMap());
    } catch (e) {
      throw e; // or handle error as needed
    }
  }
}
