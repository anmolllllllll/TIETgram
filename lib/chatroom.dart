import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_application_1/chat.dart';
import 'package:get/get.dart';
import 'package:get/get_core/get_core.dart';

import 'home.dart';

class chatroom extends StatefulWidget {
  const chatroom({Key? key, required this.visitedUserId}) : super(key: key);
  final visitedUserId;

  @override
  State<chatroom> createState() => _chatroomState();
}

class _chatroomState extends State<chatroom> {
  //for chat

  final TextEditingController _message = TextEditingController();
  void onSendMessage() async {
    if (_message.text.isNotEmpty) {
      Map<String, dynamic> messages = {
        "sendby": FirebaseAuth.instance.currentUser!.email,
        "message": _message.text,
        "time": FieldValue.serverTimestamp(),
        "receiveby": widget.visitedUserId,
      };
      await FirebaseFirestore.instance
          .collection('chatroom')
          .doc(FirebaseAuth.instance.currentUser!.email)
          .collection('chatsWith')
          .doc(widget.visitedUserId)
          .collection('chats')
          .add(messages);
      await FirebaseFirestore.instance
          .collection('chatroom')
          .doc(widget.visitedUserId)
          .collection('chatsWith')
          .doc(FirebaseAuth.instance.currentUser!.email)
          .collection('chats')
          .add(messages);
      _message.clear();
    } else {
      print("Enter some Text");
    }
  }

  @override
  Widget build(BuildContext context) {
    return new GetMaterialApp(
      home: Scaffold(
        // resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.amber,
          title: Text(
            widget.visitedUserId,
            style: TextStyle(color: Colors.black),
          ),
          leading: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: GestureDetector(
                onTap: () {
                  //FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => chat(
                        visitedUserId: widget.visitedUserId,
                      ),
                    ),
                  );
                },
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.pink.shade600,
                    size: 25,
                  ),
                )),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(top: 5.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    height: 700,
                    width: 430,
                    color: Colors.black,
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('chatroom')
                          .doc(FirebaseAuth.instance.currentUser!.email)
                          .collection('chatsWith')
                          .doc(widget.visitedUserId)
                          .collection('chats')
                          .orderBy("time", descending: false)
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.data != null) {
                          return ListView.builder(
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              //snapshot.data!.docs[index].data();
                              return Padding(
                                padding: EdgeInsets.only(top: 10.5),
                                child: Container(
                                  alignment: snapshot.data!.docs[index]
                                              ['sendby'] ==
                                          FirebaseAuth
                                              .instance.currentUser!.email
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 10),
                                    margin: EdgeInsets.symmetric(
                                        vertical: 3, horizontal: 15),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        color: snapshot.data!.docs[index]
                                                    ['sendby'] ==
                                                FirebaseAuth
                                                    .instance.currentUser!.email
                                            ? Color.fromARGB(255, 126, 16, 53)
                                            : Colors.amber),
                                    child: Text(
                                      snapshot.data!.docs[index]['message'],
                                      style: TextStyle(
                                          color: snapshot.data!.docs[index]
                                                      ['sendby'] ==
                                                  FirebaseAuth.instance
                                                      .currentUser!.email
                                              ? Colors.white
                                              : Colors.black,
                                          fontSize: 16),
                                      maxLines: 20,
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        } else {
                          return Container();
                        }
                      },
                    ),
                  ),
                  Divider(
                    height: 3.0,
                    color: Colors.white,
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 0.5, bottom: 0.5),
                    child: Container(
                      color: Colors.amber,
                      height: 68,
                      width: 410,
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 5.0, left: 10.0, bottom: 5.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 100,
                              width: 330,
                              child: TextField(
                                cursorColor: Colors.pink,
                                controller: _message,
                                decoration: InputDecoration(
                                  hintText: "Send Message...",
                                  hintStyle: TextStyle(color: Colors.pink),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                                padding: const EdgeInsets.only(
                                    top: 5.0,
                                    left: 5.0,
                                    bottom: 5.0,
                                    right: 5.0),
                                child: IconButton(
                                    onPressed: onSendMessage,
                                    icon: Icon(
                                      Icons.send,
                                      color: Colors.pink,
                                    ))),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Divider(
                    height: 3.0,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
