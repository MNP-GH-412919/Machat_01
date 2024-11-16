// lib/model/usermodel.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String? id, empname, empcode, email, mobile;

  UserModel({this.empcode, this.email, this.empname, this.id, this.mobile});

  factory UserModel.fromMap(DocumentSnapshot map) {
    return UserModel(
      email: map["email"],
      empcode: map["empcode"],
      empname: map["empname"],
      mobile: map["mobile"],
      id: map.id,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "empname": empname,
      "empcode": empcode,
      "email": email,
      "mobile": mobile,
    };
  }
}
