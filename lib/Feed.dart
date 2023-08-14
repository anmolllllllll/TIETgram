import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_application_1/Home1.dart';
import 'package:flutter_application_1/home.dart';
import 'package:flutter_application_1/main.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class Feed extends StatefulWidget {
  //const profile({Key? key}) : super(key: key);

  @override
  _FeedState createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  String changeTitle = 'CHANGE VIEW';
  bool checkView = false;
  bool isUploading = false;
  File? imageFile;
  String? imageUrl;
  String? myImage;
  String? myName;
  String? description;
  String? Group;
  String? get firstname =>
      FirebaseAuth.instance.currentUser!.email?.substring(0, 1).toString();
  String? get firstLetter =>
      FirebaseAuth.instance.currentUser!.email?.substring(0, 1).toString();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController captionController = TextEditingController();
  TextEditingController TagController = TextEditingController();

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
    _upload_image();
  }

  void _getFromGallery() async {
    XFile? pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    imageFile = File(pickedFile!.path);
    // _cropImage(pickedFile!.path);
    //Navigator.pop(context);
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
            title: Text("CWrite Caption"),
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
                    controller: TagController,
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                        hintText: "Write a caption....",
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
        .collection('wallpaper')
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
      'Group': TagController.text,
    });
    Navigator.canPop(context) ? Navigator.pop(context) : null;
    imageFile = null;
  }

  Widget listViewWidget(String docId, String img, String name, DateTime date,
      String userId, int downloads, String description, String Group) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 16.0,
        shadowColor: Colors.white10,
        child: Container(
          color: Color.fromARGB(255, 38, 116, 144),
          padding: const EdgeInsets.all(5.0),
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  //userdetails
                },
                child: Image.network(
                  img,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(
                height: 15.0,
              ),
              Padding(
                padding:
                    const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.pink.shade400,
                      child: Text(
                        name.substring(0, 1).toUpperCase(),
                        style: TextStyle(
                            color: Colors.white,
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
                        Text(
                          name,
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          width: 10.0,
                        ),
                        Text(
                          description,
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.normal),
                        ),
                        SizedBox(
                          width: 10.0,
                        ),
                        Text(
                          Group,
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.normal),
                        ),
                        SizedBox(
                          width: 10.0,
                        ),
                        Text(
                          DateFormat('dd MMM, yyyy').format(date).toString(),
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
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
                    backgroundColor: Color.fromARGB(255, 173, 60, 98),
                    onPressed: () {
                      _showImageDialog();
                    },
                    child: const Icon(
                      Icons.image,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
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
                      "FEED",
                      style: TextStyle(
                          fontSize: 20,
                          color: Color.fromARGB(255, 182, 20, 74)),
                    ),
                  ],
                ),
              ),

              ////new Text(
              // "PROFILE",
              //  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              //  ),
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
                      Icons.arrow_back,
                      size: 25,
                      color: Colors.pink,
                    ),
                  )),
            ),
            body: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('wallpaper')
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
                          snapshot.data!.docs[index]['Image'],
                          snapshot.data!.docs[index]['email'],
                          snapshot.data!.docs[index]['createAt'].toDate(),
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
