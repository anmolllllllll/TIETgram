import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/home.dart';
import 'package:flutter_application_1/main.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_application_1/profile.dart';

final storageRef = FirebaseStorage.instance.ref();
final usersRef = FirebaseFirestore.instance.collection('user');
final userRef = FirebaseFirestore.instance.collection('wallpaper');
final postsRef = FirebaseFirestore.instance.collection('postss');
final followersRef = FirebaseFirestore.instance.collection('followers');
final followingRef = FirebaseFirestore.instance.collection('following');
final NoticeRef = FirebaseFirestore.instance.collection('NoticeBoard');

class Signup extends StatefulWidget {
  const Signup({Key? key}) : super(key: key);

  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  //login function
  static Future<User?> loginUsingEmailPassword(
      {required String email,
      required String password,
      required BuildContext context}) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      user = userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == "user-not-found") {
        print("No User found for that email");
      }
    }
    return user;
  }

  String get firstLetter => this.firstNameEditingController.text;

  //our form key
  final _formKey = GlobalKey<FormState>();
  //editing Controller
  final firstNameEditingController = new TextEditingController();
  final emailEditingController = new TextEditingController();
  final passwordEditingController = new TextEditingController();
  final branchController = new TextEditingController();
  final confermpasswordEditingController = new TextEditingController();

  Future addDat() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    String uid = auth.currentUser!.uid.toString();
    var coll = FirebaseFirestore.instance.collection('user');
    coll.doc(emailEditingController.text).set({
      'uid': uid,
      'name': firstNameEditingController.text,
      'email': emailEditingController.text,
      'group': branchController.text
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primarySwatch: Colors.amber, scaffoldBackgroundColor: Colors.black),
      //padding: EdgeInsets.all(16.0),
      home: Scaffold(
        appBar: AppBar(),
        body: PreferredSize(
          preferredSize: Size.fromHeight(100.0),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "SIGNUP",
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 44.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(15.0),
                  padding: const EdgeInsets.all(3.0),
                  decoration:
                      BoxDecoration(border: Border.all(color: Colors.white)),
                  height: 50.0,
                  child: TextField(
                    controller: firstNameEditingController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.amber),
                    decoration: const InputDecoration(
                      hintText: "User Name",
                      hintStyle: TextStyle(color: Colors.amber),
                      prefixIcon: Icon(Icons.mail, color: Colors.white),
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
                    controller: emailEditingController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.amber),
                    decoration: const InputDecoration(
                      hintText: "User Email",
                      hintStyle: TextStyle(color: Colors.amber),
                      prefixIcon: Icon(Icons.mail, color: Colors.white),
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
                    controller: branchController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.amber),
                    decoration: const InputDecoration(
                      hintText: "Branch",
                      hintStyle: TextStyle(color: Colors.amber),
                      prefixIcon: Icon(Icons.group, color: Colors.white),
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
                    controller: passwordEditingController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.amber),
                    decoration: const InputDecoration(
                      hintText: "User Password",
                      hintStyle: TextStyle(color: Colors.amber),
                      prefixIcon: Icon(Icons.lock, color: Colors.white),
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
                    controller: confermpasswordEditingController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.amber),
                    decoration: const InputDecoration(
                      hintText: "Confirm Password",
                      hintStyle: TextStyle(color: Colors.amber),
                      prefixIcon: Icon(Icons.lock, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 70.0,
                ),
                Container(
                  width: double.infinity,
                  child: RawMaterialButton(
                    fillColor: Colors.amber,
                    elevation: 0.0,
                    padding: const EdgeInsets.symmetric(vertical: 15.0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0)),
                    onPressed: () async {
                      addDat();
                      FirebaseAuth auth = FirebaseAuth.instance;
                      String uid = auth.currentUser!.uid.toString();
                      //lets test the app
                      User? user = await loginUsingEmailPassword(
                          email: emailEditingController.text,
                          password: passwordEditingController.text,
                          context: context);

                      print(user);
                      if (user != null) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => Home()),
                        );
                        //lets make a new screen
                      }
                    },
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ]),
        ),
      ),
    );
  }
}
