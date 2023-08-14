import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/signup.dart';

class DatabaseServices {
  static Future<int> followerNum(String userId) async {
    QuerySnapshot followersSnapshot =
        await followersRef.doc(userId).collection('userfollowers').get();
    return followersSnapshot.docs.length;
  }

  static Future<int> followingNum(String userId) async {
    QuerySnapshot followersSnapshot =
        await followersRef.doc(userId).collection('userfollowing').get();
    return followersSnapshot.docs.length;
  }

  static Future<QuerySnapshot> searchUsers(String name) async {
    Future<QuerySnapshot> users = usersRef
        .where('name', isGreaterThanOrEqualTo: name)
        .where('name', isLessThan: name + '7')
        .get();

    return users;
  }

  static Future<QuerySnapshot> tagUsers(String group) async {
    Future<QuerySnapshot> users = usersRef
        .where('group', isGreaterThanOrEqualTo: group)
        .where('group', isLessThan: group + '7')
        .get();

    return users;
  }

  static Future<QuerySnapshot> MessageFor(String email) async {
    Future<QuerySnapshot> users = usersRef
        .where('email', isGreaterThanOrEqualTo: email)
        .where('email', isLessThan: email + '7')
        .get();

    return users;
  }
}
