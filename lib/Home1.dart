import 'package:firebase_auth/firebase_auth.dart';
import 'package:firestore_ref/firestore_ref.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/home.dart';
import 'package:flutter_application_1/UserModel.dart';
import 'package:flutter_application_1/signup.dart';
import 'package:flutter_application_1/Feed.dart';
import 'package:flutter_application_1/EditProfile.dart';

class Home1 extends StatefulWidget {
  @override
  _Home1State createState() => _Home1State();
}

class _Home1State extends State<Home1> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: new AppBar(
          title: Text("Profile"),
        ),
        body: ListView(children: <Widget>[]));
  }
}
