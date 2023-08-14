// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/home.dart';
import 'package:flutter_application_1/signup.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as Im;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class Feed extends StatefulWidget {
  @override
  _FeedState createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  String? get firstLetter =>
      FirebaseAuth.instance.currentUser!.email?.substring(0, 1).toString();
  TextEditingController locationController = TextEditingController();
  TextEditingController captionController = TextEditingController();
  File? imageFile;
  bool isUploading = false;
  String postId = Uuid().v4();

  handleTakePhoto() async {
    PickedFile? pickedFile = await ImagePicker().getImage(
      source: ImageSource.camera,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
  }

  handleChooseFromGallery() async {
    PickedFile? pickedFile = await ImagePicker().getImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
  }

  selectImage(parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            title: Text("Create Post"),
            children: <Widget>[
              SimpleDialogOption(
                  child: Text("Photo with Camera"), onPressed: handleTakePhoto),
              SimpleDialogOption(
                  child: Text("Image From Gallery"),
                  onPressed: handleChooseFromGallery),
              SimpleDialogOption(
                  child: Text("Cancel"),
                  onPressed: () => Navigator.pop(context)),
            ],
          );
        });
  }

  Widget buildSplashScreen() {
    return Scaffold(
      appBar: AppBar(
        title: new Text(
          "FEED",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        alignment: Alignment.bottomCenter,
        child: RawMaterialButton(
          fillColor: Colors.amber,
          elevation: 0.0,
          padding: const EdgeInsets.symmetric(vertical: 30.0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
          onPressed: () => selectImage(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  clearImage() {
    setState(() {
      imageFile = null;
    });
  }

  compressImage() async {
    final tempdir = await getTemporaryDirectory();
    final path = tempdir.path;
    Im.Image? imagefile = Im.decodeImage(imageFile!.readAsBytesSync());
    final compressedImageFile = File('$path/img_$postId.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imagefile!, quality: 85));
    setState(() {
      imageFile = compressedImageFile;
    });
  }

  Future<String> uploadImage(imagefile) async {
    var uploadTask = storageRef.child("post_$postId.jpg").putFile(imagefile);
    var storageSnap = await uploadTask;
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    return downloadUrl;
  }

  createPostInFirestore(
      {String? mediaUrl, String? location, String? description}) {
    postsRef
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection("userPosts")
        .doc(postId)
        .set({
      "postId": postId,
      "ownerId": FirebaseAuth.instance.currentUser!.uid,
      "username": FirebaseAuth.instance.currentUser!.displayName,
      "mediaUrl": mediaUrl,
      "description": description,
      "location": location,
    });
  }

  handleSubmit() async {
    setState(() {
      isUploading = true;
    });
    await compressImage();
    String mediaUrl = await uploadImage(imageFile);
    createPostInFirestore(
      mediaUrl: mediaUrl,
      location: locationController.text,
      description: captionController.text,
    );
    captionController.clear();
    locationController.clear();
    setState(() {
      imageFile = null;
      isUploading = false;
      postId = Uuid().v4();
    });
  }

  buildUploadForm() {
    return Scaffold(
        appBar: new AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: clearImage),
          title: Text(
            "Caption Post",
            style: TextStyle(color: Colors.amber),
          ),
          actions: [
            FlatButton(
              onPressed: isUploading ? null : () => handleSubmit(),
              child: Text(
                "Post",
                style: TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0),
              ),
            )
          ],
        ),
        body: ListView(
          children: <Widget>[
            isUploading ? LinearProgressIndicator() : Text(""),
            Container(
              height: 220.0,
              width: MediaQuery.of(context).size.width * 0.8,
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: FileImage(imageFile!),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 8.0),
            ),
            ListTile(
              leading: CircleAvatar(
                child: Text(
                  this.firstLetter.toString().toUpperCase(),
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 30,
                      fontWeight: FontWeight.bold),
                ),
              ),
              title: Container(
                width: 250.0,
                child: TextField(
                  controller: captionController,
                  style: TextStyle(color: Colors.amber),
                  decoration: InputDecoration(
                      hintText: "Write a caption....",
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.amber)),
                ),
              ),
            ),
            Divider(),
            ListTile(
              leading: Icon(
                Icons.person_pin,
                color: Colors.orange,
                size: 35.0,
              ),
              title: Container(
                width: 250.0,
                child: TextField(
                  style: TextStyle(color: Colors.amber),
                  decoration: InputDecoration(
                      hintText: "TAG",
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.amber)),
                ),
              ),
            ),
            Divider(),
            ListTile(
              leading: Icon(
                Icons.pin_drop,
                color: Colors.orange,
                size: 35.0,
              ),
              title: Container(
                width: 250.0,
                child: TextField(
                  controller: locationController,
                  style: TextStyle(color: Colors.amber),
                  decoration: InputDecoration(
                    hintText: "Where was this photo taken?",
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.amber),
                  ),
                ),
              ),
            ),
            Container(
              width: 200.0,
              height: 100.0,
              alignment: Alignment.center,
              child: RaisedButton.icon(
                label: Text(
                  "use Current LOcation",
                  style: TextStyle(color: Colors.amber),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                color: Colors.blue,
                onPressed: getUserLocation,
                icon: Icon(
                  Icons.my_location,
                  color: Colors.amber,
                ),
              ),
            )
          ],
        ));
  }

  getUserLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark placemark = placemarks[0];
    //all the information which we can get through this placemark
    String completeAddress =
        '${placemark.subThoroughfare} ${placemark.thoroughfare}, ${placemark.subLocality} ${placemark.locality}, ${placemark.subAdministrativeArea} ${placemark.administrativeArea} ${placemark.postalCode}, ${placemark.country}';
    print(completeAddress);
    //i choosed these from above
    String formattedAddress = "${placemark.locality},${placemark.country}";
    locationController.text = formattedAddress;
  }

  @override
  Widget build(BuildContext context) {
    return imageFile == null ? buildSplashScreen() : buildUploadForm();
  }
}
