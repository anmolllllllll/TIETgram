import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_application_1/Feed.dart';
import 'package:flutter_application_1/Home1.dart';
import 'package:flutter_application_1/Notice_Board.dart';
import 'package:flutter_application_1/Search.dart';
import 'package:flutter_application_1/Map.dart';
import 'package:flutter_application_1/Setting.dart';
import 'package:flutter_application_1/UserModel.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/profile.dart';
import 'package:flutter_application_1/signup.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;

  final List<Widget> _children = [
    profile(
      // currentUserId: 'currentUserId',
      visitedUserId: 'visitedUserId',
      //users: 'users',
    ),
    Search(
      visitedUserId: 'visitedUserId',
    ),
    Feed(),
    Notice_Board(visitedUserId: 'visitedUserId'),
    Map(),
    Setting(),
  ];

  static var currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.supervised_user_circle_rounded),
              label: 'profile',
              backgroundColor: Color.fromARGB(255, 103, 206, 244)),
          BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Search',
              backgroundColor: Color.fromARGB(255, 103, 206, 244)),
          BottomNavigationBarItem(
              icon: Icon(Icons.feed),
              label: 'Feed',
              backgroundColor: Color.fromARGB(255, 103, 206, 244)),
          BottomNavigationBarItem(
              icon: Icon(Icons.book),
              label: 'Notice Board',
              backgroundColor: Color.fromARGB(255, 103, 206, 244)),
          BottomNavigationBarItem(
              icon: Icon(Icons.map),
              label: 'Map',
              backgroundColor: Color.fromARGB(255, 103, 206, 244)),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Setting',
              backgroundColor: Color.fromARGB(255, 103, 206, 244)),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
