import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/home.dart';

import 'package:flutter_application_1/main.dart';

class follower extends StatefulWidget {
  const follower({Key? key}) : super(key: key);

  @override
  State<follower> createState() => _followerState();
}

class _followerState extends State<follower> {
  bool followers = true;

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
                      builder: (_) => Home(),
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
        body: Container(
          padding: const EdgeInsets.only(top: 30.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.pink, Colors.deepOrange.shade400],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: const [0.2, 0.9],
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              leading: IconButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MyApp(),
                    ),
                  );
                },
                icon: Icon(Icons.arrow_back_ios),
              ),
              // toolbarHeight: 100,
              flexibleSpace: Container(
                height: 300,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.deepOrange.shade400, Colors.pink],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    stops: const [0.2, 0.9],
                  ),
                ),
                padding:
                    const EdgeInsets.only(top: 10.0, left: 50.0, bottom: 10.0),
                child: Row(
                  children: [
                    followers
                        ? Text(
                            "FOLLOWERS",
                            style: TextStyle(fontSize: 20),
                          )
                        : Text(
                            "FOLLOWING",
                            style: TextStyle(fontSize: 20),
                          )
                  ],
                ),
              ),
            ),
            body: followers
                ? StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('followers')
                        .doc(FirebaseAuth.instance.currentUser!.email)
                        .collection('userFollowers')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (snapshot.connectionState ==
                          ConnectionState.active) {
                        if (snapshot.data!.docs.isNotEmpty) {
                          return ListView.builder(
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Padding(
                                //key: Key(snapshot.data.[index]),
                                padding: const EdgeInsets.all(8.0),
                                child: Card(
                                  elevation: 16.0,
                                  shadowColor: Colors.white10,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.pink,
                                          Colors.deepOrange.shade400
                                        ],
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
                                          padding: const EdgeInsets.only(
                                              left: 8.0,
                                              right: 8.0,
                                              bottom: 8.0),
                                          child: Row(
                                            children: [
                                              CircleAvatar(
                                                child: ListTile(
                                                  title: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 1.0,
                                                            //left: 0.0,
                                                            // right: 30.0,
                                                            bottom: 16.0),
                                                    child: Text(
                                                      snapshot
                                                          .data!.docs[index].id
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
                                              Text(
                                                snapshot.data!.docs[index].id
                                                    .toString(),
                                                style: TextStyle(
                                                    fontSize: 17,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ); //ListView(
                              // restorationId: snapshot.data!.docs.toString());
                            },
                          );
                        } else {
                          return const Center(
                            child: Text("There is no Followers",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20)),
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
                  )
                : StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('following')
                        .doc(FirebaseAuth.instance.currentUser!.email)
                        .collection('userFollowing')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (snapshot.connectionState ==
                          ConnectionState.active) {
                        if (snapshot.data!.docs.isNotEmpty) {
                          return ListView.builder(
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Padding(
                                //key: Key(snapshot.data.[index]),
                                padding: const EdgeInsets.all(8.0),
                                child: Card(
                                  elevation: 16.0,
                                  shadowColor: Colors.white10,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.pink,
                                          Colors.deepOrange.shade400
                                        ],
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
                                          padding: const EdgeInsets.only(
                                              left: 8.0,
                                              right: 8.0,
                                              bottom: 8.0),
                                          child: Row(
                                            children: [
                                              CircleAvatar(
                                                child: ListTile(
                                                  title: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 1.0,
                                                            //left: 0.0,
                                                            // right: 30.0,
                                                            bottom: 16.0),
                                                    child: Text(
                                                      snapshot
                                                          .data!.docs[index].id
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
                                              Text(
                                                snapshot.data!.docs[index].id
                                                    .toString(),
                                                style: TextStyle(
                                                    fontSize: 17,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ); //ListView(
                              // restorationId: snapshot.data!.docs.toString());
                            },
                          );
                        } else {
                          return const Center(
                            child: Text("There is no Following",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20)),
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
          ),
        ),
      ),
    );
  }
}
