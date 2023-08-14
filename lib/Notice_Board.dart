import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_application_1/Feed.dart';
import 'package:flutter_application_1/Home1.dart';
import 'package:flutter_application_1/home.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/usernotification.dart';
import 'package:flutter_application_1/show_notification.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class Notice_Board extends StatefulWidget {
  const Notice_Board({Key? key, required this.visitedUserId}) : super(key: key);
  final String visitedUserId;

  @override
  _Notice_BoardState createState() => _Notice_BoardState();
}

class _Notice_BoardState extends State<Notice_Board> {
  String changeTitle = 'CHANGE VIEW';
  bool checkView = false;
  bool isUploading = false;
  File? imageFile;
  String? imageUrl;
  String? myImage;
  String? myName;
  String? description;
  String? Group;
  String? TAG;
  String? MessageFor;
  String? get firstname =>
      FirebaseAuth.instance.currentUser!.email?.substring(0, 1).toString();
  String? get firstLetter =>
      FirebaseAuth.instance.currentUser!.email?.substring(0, 1).toString();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController captionController = TextEditingController();
  TextEditingController TagController = TextEditingController();
  TextEditingController GroupController = TextEditingController();
  TextEditingController mailController = TextEditingController();

  void _showImageDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Please Choose an option"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () {
                    _getFromCamera();
                  },
                  child: Row(
                    children: const [
                      Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.camera,
                          color: Colors.red,
                        ),
                      ),
                      Text(
                        "Camera",
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    _getFromGallery();
                  },
                  child: Row(
                    children: const [
                      Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.image,
                          color: Colors.red,
                        ),
                      ),
                      Text(
                        "Gallery",
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        });
  }

  void _getFromCamera() async {
    XFile? pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    imageFile = File(pickedFile!.path);

    // _cropImage(pickedFile!.path);
    //Navigator.pop(context);
    _upload_image();
  }

  void _getFromGallery() async {
    XFile? pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    imageFile = File(pickedFile!.path);
    // _cropImage(pickedFile!.path);
    // Navigator.pop(context);
    _upload_image();
  }

//to crop the image for now not working
  void _cropImage(filePath) async {
    CroppedFile? croppedImage =
        await ImageCropper().cropImage(sourcePath: filePath);

    if (croppedImage != null) {
      setState(() {
        imageFile = File(croppedImage.path);
      });
    }
  }

  void _upload_image() async {
    if (imageFile == null) {
      Fluttertoast.showToast(msg: "Please select an Image");
      return;
    }
    try {
      selectCaption(context);
    } catch (error) {
      Fluttertoast.showToast(msg: error.toString());
    }
  }

  selectCaption(parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            title: Text("Write Caption"),
            children: <Widget>[
              SimpleDialogOption(
                child: Container(
                  width: 500,
                  height: 30,
                  child: TextField(
                    controller: captionController,
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                        hintText: "Write a caption....",
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.black)),
                  ),
                ),
              ),
              SimpleDialogOption(
                child: Container(
                  width: 500,
                  height: 30,
                  child: TextField(
                    controller: GroupController,
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                        hintText: "Mention Group",
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.amber)),
                  ),
                ),
              ),
              SimpleDialogOption(
                child: Container(
                  width: 500,
                  height: 30,
                  child: TextField(
                    controller: TagController,
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                        hintText: "TAG Stream",
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.amber)),
                  ),
                ),
              ),
              SimpleDialogOption(
                child: Container(
                  width: 500,
                  height: 30,
                  child: TextField(
                    controller: mailController,
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                        hintText: "Mention mail of student",
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.amber)),
                  ),
                ),
              ),
              SimpleDialogOption(
                  child: Text("DONE"),
                  onPressed: () => Navigator.pop(buildUploadForm())),
            ],
          );
        });
  }

  void read_userInfo() async {
    FirebaseFirestore.instance
        .collection('user')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then<dynamic>((DocumentSnapshot snapshot) async {
      // myImage = snapshot.get('userImage');
      myName = snapshot.get('name');
    });
  }

  void initState() {
    super.initState();
    read_userInfo();
  }

  //for caption
  buildUploadForm() async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('userImage')
        .child(DateTime.now().toString() + 'jpg');
    await ref.putFile(imageFile!);
    imageUrl = await ref.getDownloadURL();
    FirebaseFirestore.instance
        .collection('NoticeBoard')
        .doc(DateTime.now().toString())
        .set({
      'id': _auth.currentUser!.uid,
      'userImage': myImage,
      'name': myName,
      'email': _auth.currentUser!.email,
      'Image': imageUrl,
      'download': 0,
      'createAt': DateTime.now(),
      'description': captionController.text,
      'MessageFor': mailController.text,
      'TAG': TagController.text,
      'Group': GroupController.text,
    });
    Navigator.canPop(context) ? Navigator.pop(context) : null;
    imageFile = null;
  }

  Widget Openimageview(
    String docId,
    String name,
    DateTime date,
    String userId,
    int downloads,
    String description,
    String Group,
    String img,
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
              Image.network(
                img,
                fit: BoxFit.cover,
                height: 400,
                width: 400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget listViewWidget(
    String docId,
    String email,
    String MessageFor,
    DateTime date,
    String userId,
    int downloads,
    String description,
    String Group,
    String TAG,
    String img,
  ) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 16.0,
        shadowColor: Colors.white10,
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.0)),
          //color: Color.fromARGB(255, 38, 116, 144),
          // padding: const EdgeInsets.all(5.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    top: 2.0, left: 2.0, right: 2.0, bottom: 2.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('wallpaper')
                              .orderBy("createAt", descending: true)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            } else if (snapshot.connectionState ==
                                ConnectionState.active) {
                              if (snapshot.data!.docs.isNotEmpty) {
                                return ListView.builder(
                                  itemCount: snapshot.data!.docs.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Openimageview(
                                      snapshot.data!.docs[index].id,
                                      snapshot.data!.docs[index]['Image'],
                                      snapshot.data!.docs[index]['email'],
                                      snapshot.data!.docs[index]['createAt']
                                          .toDate(),
                                      snapshot.data!.docs[index]['id'],
                                      snapshot.data!.docs[index]['download'],
                                      snapshot.data!.docs[index]['description'],
                                      snapshot.data!.docs[index]['Group'],
                                    );
                                  },
                                );
                              } else {
                                return const Center(
                                  child: Text("There is no tasks",
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
                        );
                      },
                      child: Image.network(
                        img,
                        fit: BoxFit.cover,
                        height: 180,
                        width: 180,
                      ),
                    ),
                    // Image.network(
                    //  img,
                    // fit: BoxFit.cover,
                    // height: 180,
                    //  width: 180,
                    //   ),
                    const SizedBox(
                      width: 10.0,
                      height: 100.0,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.pink.shade400,
                          child: Text(
                            email.substring(0, 1).toUpperCase(),
                            // this.firstname.toString().toUpperCase(),
                            style: TextStyle(
                                color: Color.fromARGB(255, 38, 116, 144),
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(
                          email,
                          style: TextStyle(
                              fontSize: 18,
                              color: Color.fromARGB(255, 38, 116, 144)),
                        ),
                        SizedBox(
                          width: 10.0,
                        ),
                        Text(
                          DateFormat('ddd MMM, yyyy - hh:mm a')
                              .format(date)
                              .toString(),
                          style: const TextStyle(
                              color: Color.fromARGB(137, 116, 112, 112),
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          width: 10.0,
                        ),
                        Text(
                          description,
                          style: TextStyle(
                              color: Color.fromARGB(255, 38, 116, 144)),
                        ),
                        SizedBox(
                          width: 10.0,
                        ),
                        Text(Group,
                            style: TextStyle(
                                color: Color.fromARGB(255, 38, 116, 144))),
                        SizedBox(
                          width: 10.0,
                        ),
                        Text(TAG,
                            style: TextStyle(
                                color: Color.fromARGB(255, 38, 116, 144))),
                        SizedBox(
                          width: 10.0,
                        ),
                        if (MessageFor.length < 20)
                          Text(MessageFor,
                              style: TextStyle(
                                  color: Color.fromARGB(255, 38, 116, 144))),
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
                      builder: (_) => Feed(),
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
      child: new Scaffold(
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
            floatingActionButton: Wrap(
              direction: Axis.horizontal,
              children: [
                Container(
                  margin: const EdgeInsets.all(10.0),
                  child: FloatingActionButton(
                    heroTag: "1",
                    backgroundColor: Colors.deepOrange.shade400,
                    onPressed: () {
                      _showImageDialog();
                    },
                    child: const Icon(Icons.note_add),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(10.0),
                  child: FloatingActionButton(
                    heroTag: "3",
                    backgroundColor: Colors.pink.shade400,
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => show_notification(),
                        ),
                      );
                    },
                    child: const Icon(Icons.notifications_active),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              //toolbarHeight: 100,
              flexibleSpace: Container(
                height: 300,
                color: Colors.white,
                padding:
                    const EdgeInsets.only(top: 10.0, left: 50.0, bottom: 10.0),
                child: Row(
                  children: [
                    Text(
                      "NOTICE BOARD",
                      style: TextStyle(
                          fontSize: 20,
                          color: Color.fromARGB(255, 182, 20, 74)),
                    ),
                  ],
                ),
              ),

              leading: GestureDetector(
                  onTap: () {
                    //FirebaseAuth.instance.signOut();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => Home(),
                      ),
                    );
                  },
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: Color.fromARGB(255, 182, 20, 74),
                      size: 25,
                    ),
                  )),
            ),
            body: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('NoticeBoard')
                  .orderBy("createAt", descending: true)
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
                        return listViewWidget(
                          snapshot.data!.docs[index].id,
                          snapshot.data!.docs[index]['email'],
                          snapshot.data!.docs[index]['MessageFor'],
                          snapshot.data!.docs[index]['createAt'].toDate(),
                          snapshot.data!.docs[index]['id'],
                          snapshot.data!.docs[index]['download'],
                          snapshot.data!.docs[index]['description'],
                          snapshot.data!.docs[index]['Group'],
                          snapshot.data!.docs[index]['TAG'],
                          snapshot.data!.docs[index]['Image'],
                        );
                      },
                    );
                  } else {
                    return const Center(
                      child: Text("There is no tasks",
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
          ),
        ),
      ),
    );
  }
}

showNoticBoard(BuildContext context, {required String visitedUserId}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => Notice_Board(
        visitedUserId: visitedUserId,
      ),
    ),
  );
}
