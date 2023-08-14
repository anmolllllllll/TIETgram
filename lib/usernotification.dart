import 'dart:io';
import 'package:auth/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_application_1/Notice_Board.dart';
import 'package:flutter_application_1/profile.dart';
import 'package:flutter_application_1/show_notification.dart';

class usernotification extends StatefulWidget {
  const usernotification({Key? key}) : super(key: key);

  @override
  _notificationState createState() => _notificationState();
}

class _notificationState extends State<usernotification> {
  String? email;
  String? tag;
  String? title;
  String? Notification;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController notification = TextEditingController();
  TextEditingController useremail = TextEditingController();
  TextEditingController usertitle = TextEditingController();
  TextEditingController usertag = TextEditingController();

  buildUploadForm() async {
    // await ref.putFile(imageFile!);
    // imageUrl = await ref.getDownloadURL();
    FirebaseFirestore.instance
        .collection('Notification')
        .doc(DateTime.now().toString())
        .set({
      'uid': FirebaseAuth.instance.currentUser!.uid,
      'email': _auth.currentUser!.email,
      'tag': usertag.text,
      'title': usertitle.text,
      'createAt': DateTime.now(),
      'notification': notification.text,
    });
  }

  Widget listViewWidget(
    String uid,
    String email,
    String tag,
    DateTime date,
    String title,
    String notification,
  ) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 16.0,
        shadowColor: Colors.white10,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.pink, Colors.deepOrange.shade400],
              begin: Alignment.centerRight,
              end: Alignment.centerRight,
              stops: const [0.2, 0.9],
            ),
          ),
          padding: const EdgeInsets.all(5.0),
          child: Column(
            children: [
              const SizedBox(
                height: 15.0,
              ),
              Padding(
                padding:
                    const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      child: Text(
                        email,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(
                      width: 10.0,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tag),
                        SizedBox(
                          width: 10.0,
                        ),
                        Text(
                          title,
                        ),
                        SizedBox(
                          width: 10.0,
                        ),
                        Text(
                          notification,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  getData() {}

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: const Text('Do you want to go back?'),
            actionsAlignment: MainAxisAlignment.spaceBetween,
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => Notice_Board(
                        visitedUserId: '',
                      ),
                    ),
                  );
                  //Navigator.pop(context, true);
                },
                child: const Text('Yes'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context, false);
                },
                child: const Text('No'),
              ),
            ],
          ),
        ) ??
        false);
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: new AppBar(
          title: new Text(
            "Add Notification",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
        body: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(15.0),
              padding: const EdgeInsets.all(3.0),
              decoration:
                  BoxDecoration(border: Border.all(color: Colors.white)),
              height: 50.0,
              child: TextField(
                controller: usertag,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.amber),
                decoration: const InputDecoration(
                  hintText: "TAG",
                  hintStyle: TextStyle(color: Colors.amber),
                  prefixIcon: Icon(Icons.tag, color: Colors.white),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(15.0),
              padding: const EdgeInsets.all(3.0),
              decoration:
                  BoxDecoration(border: Border.all(color: Colors.white)),
              height: 50.0,
              child: TextField(
                controller: usertitle,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.amber),
                decoration: const InputDecoration(
                  hintText: "Title",
                  hintStyle: TextStyle(color: Colors.amber),
                  prefixIcon: Icon(Icons.title, color: Colors.white),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(15.0),
              padding: const EdgeInsets.all(3.0),
              decoration:
                  BoxDecoration(border: Border.all(color: Colors.white)),
              height: 200.0,
              child: TextField(
                controller: notification,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.amber),
                decoration: const InputDecoration(
                  hintText: "Notification",
                  hintStyle: TextStyle(color: Colors.amber),
                  prefixIcon: Icon(Icons.message, color: Colors.white),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(30.0),
              width: 200,
              child: RawMaterialButton(
                fillColor: Colors.amber,
                elevation: 0.0,
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0)),
                onPressed: () {
                  buildUploadForm();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => show_notification(),
                    ),
                  );

                  //lets test the app
                },
                child: const Text(
                  "DONE",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
