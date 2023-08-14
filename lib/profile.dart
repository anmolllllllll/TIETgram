import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_application_1/Home1.dart';
import 'package:flutter_application_1/UserModel.dart';
import 'package:flutter_application_1/chat.dart';
import 'package:flutter_application_1/follower.dart';
import 'package:flutter_application_1/home.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/show_notification.dart';
import 'package:flutter_application_1/signup.dart';
import 'package:flutter_application_1/tag.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:get/get.dart';

class profile extends StatefulWidget {
  // final String currentUserId;
  final String visitedUserId;

  const profile({Key? key, required this.visitedUserId}) : super(key: key);
  //final  user users;
  @override
  _profile createState() => _profile();
}

class _profile extends State<profile> {
  //final  user users;
// _profile( this.users);

  String changeTitle = 'CHANGE VIEW';
  bool checkView = false;
  bool isFollowing = false;
  bool isUploading = false;
  bool followers = true;
  String postId = Uuid().v4();
  int followerCount = 0;
  int followingCount = 0;

  File? imageFile;
  String? imageUrl;
  String? myImage;
  String? name;
  String? group;
  String? email;
  String? uid;
  String? description;
  String? Group;

  // _profile( this.users);
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
    // Navigator.pop(context);
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
        .doc(FirebaseAuth.instance.currentUser!.email)
        .get()
        .then<dynamic>((DocumentSnapshot snapshot) async {
      // myImage = snapshot.get('userImage');
      name = snapshot.get('name');
    });
  }

  void initState() {
    super.initState();
    read_userInfo();
    getFollowers();
    getFollowing();
    // checkIfFollowing();
  }

  getFollowers() async {
    QuerySnapshot snapshot = await followersRef
        .doc(FirebaseAuth.instance.currentUser!.email)
        .collection('userFollowers')
        .get();
    setState(() {
      followerCount = snapshot.docs.length;
    });
    // return followerCount;
  }

  getFollowing() async {
    QuerySnapshot snapshot = await followingRef
        .doc(FirebaseAuth.instance.currentUser!.email)
        .collection('userFollowing')
        .get();
    setState(() {
      followingCount = snapshot.docs.length;
    });
  }

  Future<String> uploadImage(imagefile) async {
    var uploadTask = storageRef.child("post_$postId.jpg").putFile(imagefile);
    var storageSnap = await uploadTask;
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    return downloadUrl;
  }

  //for caption
  buildUploadForm() async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('id')
        .child(DateTime.now().toString() + 'jpg');
    await ref.putFile(imageFile!);
    imageUrl = await ref.getDownloadURL();
    FirebaseFirestore.instance
        .collection('postss')
        .doc(FirebaseAuth.instance.currentUser!.email)
        .collection('userPosts')
        .doc(postId)
        .set({
      'postId': postId,
      'id': _auth.currentUser!.uid,
      'userImage': myImage,
      'name': name,
      'email': _auth.currentUser!.email,
      'download': 0,
      'createAt': DateTime.now(),
      'description': captionController.text,
      'Group': TagController.text,
      'Image': imageUrl,
    });
    Navigator.canPop(context) ? Navigator.pop(context) : null;
    imageFile = null;
  }

  Widget listViewWidget(
    String docId,
    String name,
    DateTime date,
    String userId,
    int downloads,
    String description,
    String Group,
    String email,
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
              colors: [Colors.pink, Colors.pink.shade400],
              begin: Alignment.centerRight,
              end: Alignment.centerRight,
              stops: const [0.2, 0.9],
            ),
          ),
          padding: const EdgeInsets.all(5.0),
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  options();
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
                      child: Text(
                        email.substring(0, 1).toUpperCase(),
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
                        Text(
                          email,
                          // FirebaseAuth.instance.currentUser!.email.toString(),
                        ),
                        SizedBox(
                          width: 10.0,
                        ),
                        Text(
                          DateFormat('dd MMM, yyyy - hh:mm a')
                              .format(date)
                              .toString(),
                          style: const TextStyle(
                              color: Colors.white54,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          width: 10.0,
                        ),
                        Text(
                          description,
                        ),
                        SizedBox(
                          width: 10.0,
                        ),
                        Text(
                          Group,
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

  Widget gridViewWidget(
    String docId,
    String name,
    DateTime date,
    String userId,
    int downloads,
    String description,
    String Group,
    String img,
  ) {
    return GridView.count(
      primary: false,
      padding: const EdgeInsets.all(2.0),
      crossAxisSpacing: 1,
      crossAxisCount: 1,
      children: [
        Container(
          // color: Colors.white,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            color: Colors.white,
          ),
          padding: const EdgeInsets.all(5.0),
          child: GestureDetector(
            onTap: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      // title: const Text("OPTIONS"),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: () {
                              handleposts();
                            },
                            child: Row(
                              children: const [
                                Padding(
                                  padding: EdgeInsets.all(4.0),
                                  child: Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                ),
                                Text(
                                  "DELETE",
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
                                    Icons.open_in_full,
                                    color: Colors.red,
                                  ),
                                ),
                                Text(
                                  "OPEN IMAGE",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  });
            },
            child: Image.network(
              img,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }

  void options() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            // title: const Text("OPTIONS"),
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
                          Icons.delete,
                          color: Colors.red,
                        ),
                      ),
                      Text(
                        "DELETE",
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
                          Icons.open_in_full,
                          color: Colors.red,
                        ),
                      ),
                      Text(
                        "OPEN IMAGE",
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

  //follow user
  handleFollowUser() {
    setState(() {
      isFollowing = true;
    });
    //make user follower of another user (update their followers collection)
    followersRef
        .doc(widget.visitedUserId)
        .collection('userFollowers')
        .doc(FirebaseAuth.instance.currentUser!.email)
        .set({});

    followingRef
        .doc(FirebaseAuth.instance.currentUser!.email)
        .collection('userFollowing')
        .doc(widget.visitedUserId)
        .set({});
  }

  handleposts() {
    //remove followers
    postsRef
        .doc(FirebaseAuth.instance.currentUser!.email)
        .collection('userPosts')
        .doc()
        .delete()
        .then((_) {
      print("success");
    });

    followingRef
        .doc(FirebaseAuth.instance.currentUser!.email)
        .collection('userFollowing')
        .doc(widget.visitedUserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  Column buildCountColumn(String label, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Column(children: [
          Text(
            count.toString(),
          ),
        ]),
        Column(children: [
          Text(
            label.toString(),
          ),
        ]),
      ],
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
                      builder: (_) => MyApp(),
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
    //  user users;
    return new Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        padding: const EdgeInsets.only(top: 30.0),
        color: Colors.white,
        child: Scaffold(
          floatingActionButton: Wrap(
            direction: Axis.horizontal,
            children: [
              Container(
                margin: const EdgeInsets.all(10.0),
                child: FloatingActionButton(
                  heroTag: "1",
                  backgroundColor: Color.fromARGB(255, 103, 206, 244),
                  onPressed: () {
                    _showImageDialog();
                  },
                  child: const Icon(Icons.image, color: Colors.white),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(10.0),
                child: FloatingActionButton(
                  heroTag: "2",
                  backgroundColor: Color.fromARGB(255, 103, 206, 244),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => tag(
                          visitedUserId: 'visitedUserId',
                        ),
                      ),
                    );
                  },
                  child: const Icon(Icons.tag, color: Colors.white),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(10.0),
                child: FloatingActionButton(
                  heroTag: "3",
                  backgroundColor: Color.fromARGB(255, 103, 206, 244),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => chat(
                          visitedUserId: widget.visitedUserId,
                        ),
                      ),
                    );
                  },
                  child: const Icon(
                    Icons.chat,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            toolbarHeight: 205,
            flexibleSpace: Container(
              height: 300,
              // decoration: BoxDecoration(
              //    gradient: LinearGradient(
              //      colors: [Colors.white, Color.fromARGB(255, 67, 145, 173)],
              //      begin: Alignment.centerLeft,
              //       end: Alignment.centerRight,
              //       stops: const [0.2, 0.9],
              //      ),
              //    ),
              padding:
                  const EdgeInsets.only(top: 20.0, left: 50.0, bottom: 32.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Color.fromARGB(255, 103, 206, 244),
                        radius: 40,
                        child: Text(
                          FirebaseAuth.instance.currentUser!.email!
                              .substring(0, 1)
                              .toString()
                              .toUpperCase(),
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 35,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(
                        width: 10.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 20.0, left: 9.0, bottom: 32.0),
                        child: Row(
                          //crossAxisAlignment: CrossAxisAlignment.baseline,
                          children: [
                            Text(
                              FirebaseAuth.instance.currentUser!.email
                                  .toString(),
                              style: TextStyle(
                                  fontSize: 24, color: Colors.pink.shade900),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Divider(
                    height: 2,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 5.0,
                      left: 0.0,
                      bottom: 5.0,
                      right: 20.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        GestureDetector(
                          child: buildCountColumn("followers", followerCount),
                          // child: buildCountColumn("following", followingCount)
                          onTap: () {
                            followers = true;
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => follower(),
                              ),
                            );
                          },
                        ),
                        GestureDetector(
                          child: buildCountColumn("following", followingCount),
                          // child: buildCountColumn("following", followingCount)
                          onTap: () {
                            followers = false;
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => follower(),
                              ),
                            );
                          },
                        ),
                        //   buildCountColumn("followers", followerCount),
                        //    buildCountColumn("following", followingCount)
                      ],
                    ),
                  ),
                  Divider(
                    height: 5,
                  ),
                ],
              ),
            ),

            title: Row(
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          // changeTitle = "LIST VIEW";
                          checkView = false;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 170.0, left: 0.0, bottom: 2.0, right: 200.0),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Icon(
                            Icons.grid_view,
                            size: 25,
                            color: Colors.pink.shade600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(
                          () {
                            // changeTitle = "GRID VIEW";
                            checkView = true;
                          },
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 165.0, left: 0.0, bottom: 2.0, right: 20.0),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Icon(
                            Icons.list,
                            size: 25,
                            color: Colors.pink.shade600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            centerTitle: true,

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
                    Icons.arrow_back_ios,
                    color: Color.fromARGB(255, 38, 116, 144),
                    size: 25,
                  ),
                )),
          ),
          body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('postss')
                .doc(FirebaseAuth.instance.currentUser!.email)
                .collection('userPosts')
                .orderBy('postId', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.connectionState == ConnectionState.active) {
                if (snapshot.data!.docs.isNotEmpty) {
                  if (checkView == true) {
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (BuildContext context, int index) {
                        return listViewWidget(
                          snapshot.data!.docs[index].id,
                          snapshot.data!.docs[index]['postId'],
                          snapshot.data!.docs[index]['createAt'].toDate(),
                          snapshot.data!.docs[index]['id'],
                          snapshot.data!.docs[index]['download'],
                          snapshot.data!.docs[index]['description'],
                          snapshot.data!.docs[index]['Group'],
                          snapshot.data!.docs[index]['email'],
                          snapshot.data!.docs[index]['Image'],
                        );
                      },
                    );
                  } else {
                    return GridView.builder(
                      itemCount: snapshot.data!.docs.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2),
                      itemBuilder: (BuildContext context, int index) {
                        return gridViewWidget(
                          snapshot.data!.docs[index].id,
                          snapshot.data!.docs[index]['postId'],
                          snapshot.data!.docs[index]['createAt'].toDate(),
                          snapshot.data!.docs[index]['id'],
                          snapshot.data!.docs[index]['download'],
                          snapshot.data!.docs[index]['description'],
                          snapshot.data!.docs[index]['Group'],
                          snapshot.data!.docs[index]['Image'],
                        );
                      },
                    );
                  }
                } else {
                  return const Center(
                    child: Text("There is no Post",
                        style: TextStyle(color: Colors.black, fontSize: 20)),
                  );
                }
              }
              return const Center(
                child: Text(
                  "Something went Wrong",
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 30),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

//showProfile(BuildContext context, {required String visitedUserId}) {
//  Navigator.push(
//    context,
//    MaterialPageRoute(
   //   builder: (context) => profile(
//        visitedUserId: visitedUserId,
//      ),
//    ),
//  );
//}
