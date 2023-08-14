import 'package:auth/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_application_1/Notice_Board.dart';
import 'package:flutter_application_1/Search.dart';
import 'package:flutter_application_1/UserModel.dart';
import 'package:flutter_application_1/chatroom.dart';
import 'package:flutter_application_1/home.dart';
import 'package:flutter_application_1/profile.dart';
import 'package:flutter_application_1/signup.dart';
import 'package:flutter_application_1/usernotification.dart';

class chat extends StatelessWidget {
  final visitedUserId;

  const chat({super.key, required this.visitedUserId});
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: Container(
        padding: const EdgeInsets.only(top: 30.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color.fromARGB(255, 67, 145, 173)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            stops: const [0.2, 0.9],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            // toolbarHeight: 100,
            flexibleSpace: Container(
              height: 300,
              color: Colors.white,
              padding:
                  const EdgeInsets.only(top: 10.0, left: 50.0, bottom: 10.0),
              child: Row(
                children: [
                  Text(
                    "CHATRooM",
                    style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 38, 116, 144)),
                  ),
                ],
              ),
            ),

            leading: GestureDetector(
                onTap: () {
                  //FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => Home()),
                  );
                },
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Icon(
                    Icons.arrow_back_ios,
                    color: Color.fromARGB(255, 38, 116, 144),
                    size: 25,
                  ),
                )),
          ),
          body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('listofuserschatting')
                //.orderBy("time", descending: false)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.connectionState == ConnectionState.active) {
                if (snapshot.data!.docs.isNotEmpty) {
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        //key: Key(snapshot.data.[index]),
                        padding: const EdgeInsets.all(3.0),
                        child: Card(
                          elevation: 16.0,
                          shadowColor: Colors.white10,
                          child: Container(
                            color: Color.fromARGB(255, 38, 116, 144),
                            padding: const EdgeInsets.all(3.0),
                            child: Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    //userdetails
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 8.0,
                                        left: 8.0,
                                        right: 10.0,
                                        bottom: 8.0),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: Colors.white,
                                          child: ListTile(
                                            title: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 1.0,
                                                  //left: 0.0,
                                                  right: 10.0,
                                                  bottom: 16.0),
                                              child: Text(
                                                snapshot.data!.docs[index].id
                                                    .substring(0, 1)
                                                    .toUpperCase()
                                                    .toString(),
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10.0,
                                        ),
                                        Container(
                                          width: 200,
                                          child: Text(
                                            snapshot.data!.docs[index].id
                                                .toString(),
                                            style: TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10.0,
                                        ),
                                        Padding(
                                            padding: EdgeInsets.only(
                                                left: 30.0, right: 10.0),
                                            child: Container(
                                                child: GestureDetector(
                                                    onTap: () {
                                                      Navigator.pushReplacement(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (_) =>
                                                              chatroom(
                                                            visitedUserId:
                                                                snapshot
                                                                    .data!
                                                                    .docs[index]
                                                                    .id
                                                                    .toString(),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    child: Align(
                                                      child: Icon(
                                                        Icons.chat,
                                                        size: 25,
                                                        color: Colors.white,
                                                      ),
                                                    )))),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                      //
                    },
                  );
                } else {
                  return const Center(
                    child: Text("There is no Data",
                        style: TextStyle(color: Colors.white, fontSize: 20)),
                  );
                }
              }
              return const Center(
                child: Text(
                  "Something went Wrong",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 30),
                ),
              );
            },
          ),
          floatingActionButton: Wrap(
            direction: Axis.horizontal,
            children: [
              Container(
                margin: const EdgeInsets.all(10.0),
                child: FloatingActionButton(
                  heroTag: "1",
                  backgroundColor: Colors.white,
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => Search(
                          visitedUserId: '',
                        ),
                      ),
                    );
                  },
                  child: const Icon(
                    Icons.add,
                    color: Color.fromARGB(255, 32, 72, 87),
                    size: 32,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
