import 'package:firebase_auth/firebase_auth.dart';
import 'package:firestore_ref/firestore_ref.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_application_1/signup.dart';

class postss {
  final String uid;
  final String name;
  final String email;
  final String group;

  postss({
    required this.uid,
    required this.name,
    required this.email,
    required this.group,
  });

  factory postss.fromDocument(DocumentSnapshot doc) {
    return postss(
      uid: doc['uid'],
      name: doc['name'],
      email: doc['email'],
      group: doc['group'],
    );
  }
}
