import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_application_1/Home1.dart';
import 'package:flutter_application_1/Search.dart';
import 'package:flutter_application_1/UserModel.dart';
import 'package:flutter_application_1/chat.dart';
import 'package:flutter_application_1/home.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/show_notification.dart';
import 'package:flutter_application_1/signup.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class visiteduserprofile extends StatefulWidget {
  // final String currentUserId;
  final String visitedUserId;

  const visiteduserprofile({Key? key, required this.visitedUserId})
      : super(key: key);
  //final  user users;
  @override
  _visiteduserprofile createState() => _visiteduserprofile();
}

class _visiteduserprofile extends State<visiteduserprofile> {
  //final  user users;
// _profile( this.users);
  Map<String, dynamic>? userMap;

  String changeTitle = 'CHANGE VIEW';
  bool checkView = false;
  bool isFollowing = false;
  bool isUploading = false;
  bool followers = true;
  bool isseen = false;
  String postId = Uuid().v4();
  int followerCount = 0;
  int followingCount = 0;

  File? imageFile;
  String? imageUrl;
  String? myImage;
  String? name;
  String? myName;
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

  String chatRoomId(String user1, String user2) {
    if (user1[0].toLowerCase().codeUnits[0] >
        user2.toLowerCase().codeUnits[0]) {
      return "$user1$user2";
    } else {
      return "$user2$user1";
    }
  }

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
          .collection('listofuserschatting')
          .doc(widget.visitedUserId)
          .set({});
      await FirebaseFirestore.instance
          .collection('listofuserschatting')
          .doc(FirebaseAuth.instance.currentUser!.email)
          .set({});
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
    Navigator.pop(context);
  }

  void _getFromGallery() async {
    XFile? pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    imageFile = File(pickedFile!.path);
    // _cropImage(pickedFile!.path);
    Navigator.pop(context);
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
      myName = snapshot.get('name');
    });
  }

  void initState() {
    super.initState();
    read_userInfo();
    getFollowers();
    getFollowing();
    checkIfFollowing();
  }

  checkIfFollowing() async {
    DocumentSnapshot doc = await followingRef
        .doc(FirebaseAuth.instance.currentUser!.email)
        .collection('userFollowing')
        .doc(widget.visitedUserId)
        .get();
    setState(() {
      isFollowing = doc.exists;
    });
    return isFollowing;
  }

  getFollowers() async {
    QuerySnapshot snapshot = await followersRef
        .doc(widget.visitedUserId)
        .collection('userFollowers')
        .get();
    setState(() {
      followerCount = snapshot.docs.length;
    });
    // return followerCount;
  }

  getFollowing() async {
    QuerySnapshot snapshot = await followingRef
        .doc(widget.visitedUserId)
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
        ));
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
      padding: const EdgeInsets.only(top: 3.0),
      crossAxisSpacing: 1,
      crossAxisCount: 1,
      children: [
        Container(
          color: Color.fromARGB(255, 38, 116, 144),
          padding: const EdgeInsets.all(2.0),
          child: GestureDetector(
            onTap: () {
              //userdetail
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

  //unfollow user
  handleUnfollowUser() {
    setState(() {
      isFollowing = false;
    });
    //remove followers
    followersRef
        .doc(widget.visitedUserId)
        .collection('userFollowers')
        .doc(FirebaseAuth.instance.currentUser!.email)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
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
            style: TextStyle(color: Colors.black, fontSize: 15),
          ),
        ]),
        Column(children: [
          Text(
            label.toString(),
            style: TextStyle(color: Colors.black, fontSize: 13),
          ),
        ]),
      ],
    );
  }

  //chat with user
  chat() {
    return new GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        resizeToAvoidBottomInset: false,
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
                  Get.to(
                      visiteduserprofile(visitedUserId: widget.visitedUserId));
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

  follower() {
    return new Scaffold(
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

              leading: GestureDetector(
                  onTap: () {
                    //Get.back();
                    Get.off(visiteduserprofile(
                      visitedUserId: widget.visitedUserId,
                    ));
                    //FirebaseAuth.instance.signOut();
                  },
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Icon(
                      Icons.arrow_back,
                      size: 25,
                    ),
                  )),
            ),
            body: followers
                ? StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('followers')
                        .doc(widget.visitedUserId)
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
                        .doc(widget.visitedUserId)
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
                  )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    //  user users;
    return new Scaffold(
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
                  backgroundColor: Colors.deepOrange.shade400,
                  onPressed: () {
                    FirebaseAuth.instance.currentUser != widget.visitedUserId
                        ? isseen = false
                        : isseen = true;
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => chat(),
                      ),
                    );
                  },
                  child: const Icon(
                    Icons.chat,
                    color: Color.fromARGB(255, 142, 13, 56),
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            toolbarHeight: 205,
            flexibleSpace: Container(
              height: 300,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, Color.fromARGB(255, 67, 145, 173)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  stops: const [0.2, 0.9],
                ),
              ),
              padding:
                  const EdgeInsets.only(top: 20.0, left: 50.0, bottom: 32.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Color.fromARGB(255, 172, 11, 0),
                        radius: 40,
                        child: Text(
                          widget.visitedUserId
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
                            top: 20.0, left: 13.0, bottom: 32.0),
                        child: Column(
                          children: [
                            Row(
                              //crossAxisAlignment: CrossAxisAlignment.baseline,
                              children: [
                                Text(
                                  widget.visitedUserId.toString(),
                                  style: TextStyle(fontSize: 24),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Divider(
                    height: 2,
                    // color: Colors.black,
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
                            if (isFollowing) {
                              followers = true;
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => follower(),
                                ),
                              );
                            }
                          },
                        ),
                        GestureDetector(
                          child: buildCountColumn("following", followingCount),
                          // child: buildCountColumn("following", followingCount)
                          onTap: () {
                            if (isFollowing) {
                              followers = false;
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => follower(),
                                ),
                              );
                            }
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
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 1.0, left: 0.0, bottom: 1.0, right: 20.0),
                    child: Container(
                        height: 40,
                        width: 120,
                        child: isFollowing
                            ? RawMaterialButton(
                                fillColor: Colors.white,
                                elevation: 0.0,
                                //padding: const EdgeInsets.symmetric(vertical: 15.0),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0)),
                                onPressed: () {
                                  if (FirebaseAuth.instance.currentUser !=
                                      null) {
                                    handleUnfollowUser();
                                  }
                                  //lets test the app
                                },
                                child: const Text(
                                  "UNFOLLOW",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.bold),
                                ),
                              )
                            : RawMaterialButton(
                                fillColor: isFollowing
                                    ? Colors.white
                                    : Color.fromARGB(255, 172, 11, 0),
                                elevation: 0.0,
                                //padding: const EdgeInsets.symmetric(vertical: 15.0),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0)),
                                onPressed: () {
                                  if (FirebaseAuth.instance.currentUser !=
                                      null) {
                                    Text(
                                      "FOLLOWING",
                                      style: TextStyle(color: Colors.black),
                                    );
                                    handleFollowUser();
                                  }
                                  //lets test the app
                                },
                                child: isFollowing
                                    ? const Text(
                                        "hello",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.bold),
                                      )
                                    : const Text(
                                        "FOLLOW",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.bold),
                                      ),
                              )),
                  ),
                  Divider(
                    height: 5,
                    // color: Colors.black,
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
                            top: 165.0, left: 0.0, bottom: 2.0, right: 200.0),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Icon(
                            Icons.grid_view,
                            size: 25,
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
                      builder: (_) => Search(
                        visitedUserId: '',
                      ),
                    ),
                  );
                },
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Icon(
                    Icons.arrow_back,
                    size: 25,
                  ),
                )),
          ),
          body: isFollowing
              ? StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('postss')
                      .doc(widget.visitedUserId)
                      .collection('userPosts')
                      .orderBy('postId', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.connectionState ==
                        ConnectionState.active) {
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
                          child: Text("There is no tasks",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20)),
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
              : Center(
                  child: Text(
                    "You Dont Follow This User!",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
        ),
      ),
    );
  }
}

showProfile(BuildContext context, {required String visitedUserId}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => visiteduserprofile(
        visitedUserId: visitedUserId,
      ),
    ),
  );
}
