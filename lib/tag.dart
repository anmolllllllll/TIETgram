import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/DatabaseServices.dart';
import 'package:flutter_application_1/Feed.dart';
import 'package:flutter_application_1/Notice_Board.dart';
import 'package:flutter_application_1/UserModel.dart';
import 'package:flutter_application_1/home.dart';
import 'package:flutter_application_1/profile.dart';
import 'package:flutter_application_1/signup.dart';
import 'package:flutter_application_1/visiteduserprofile.dart';
import 'package:get/get.dart';

class tag extends StatefulWidget {
  // final String currentUserId;
  final String visitedUserId;

  const tag({Key? key, required this.visitedUserId}) : super(key: key);

  @override
  _tag createState() => _tag();
}

class _tag extends State<tag> {
  String? get firstname =>
      FirebaseAuth.instance.currentUser!.email?.substring(0, 1).toString();
  Future<QuerySnapshot>? searchResultsFuture;
  TextEditingController _searchController = TextEditingController();

  Icon customIcon = const Icon(Icons.search);
  Widget customSearchBar = const Text('My Personal Journal');
  bool tagged = false;

  clearSearch() {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _searchController.clear());
    setState(() {
      // ignore: unnecessary_null_comparison
      searchResultsFuture == null;
    });
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
      padding: const EdgeInsets.all(2.0),
      child: Card(
        elevation: 16.0,
        shadowColor: Colors.white10,
        child: Container(
          decoration: BoxDecoration(color: Colors.amber),
          // padding: const EdgeInsets.all(5.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    top: 2.0, left: 2.0, right: 2.0, bottom: 2.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {},
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
                          child: Text(
                            email.substring(0, 1).toUpperCase(),
                            // this.firstname.toString().toUpperCase(),
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(
                          email,
                          style: TextStyle(fontSize: 17),
                        ),
                        SizedBox(
                          width: 10.0,
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
                        SizedBox(
                          width: 10.0,
                        ),
                        Text(
                          TAG,
                        ),
                        SizedBox(
                          width: 10.0,
                        ),
                        Text(
                          MessageFor,
                          style: TextStyle(fontSize: 15),
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

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primarySwatch: Colors.amber, scaffoldBackgroundColor: Colors.white),
      home: Scaffold(
          backgroundColor: Colors.white,
          appBar: new AppBar(
            //backgroundColor: Colors.amber,
            title: Padding(
              padding: const EdgeInsets.only(top: 0.0, left: 0.0, bottom: 0.0),
              child: Container(
                child: TextField(
                  style: const TextStyle(color: Colors.pink),
                  controller: _searchController,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 15),
                    hintText: 'Enter Your Group...',
                    hintStyle:
                        TextStyle(color: Color.fromARGB(255, 250, 50, 103)),
                    border: InputBorder.none,
                    icon: IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: Color.fromARGB(255, 246, 45, 112),
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => Home(),
                          ),
                        );
                      },
                    ),
                    prefixIcon: Icon(
                      Icons.tag_faces,
                      color: Color.fromARGB(255, 236, 43, 107),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: Colors.pink,
                      ),
                      onPressed: () {
                        clearSearch();
                      },
                    ),
                    filled: true,
                  ),
                  onChanged: (input) {
                    if (input.isNotEmpty) {
                      setState(() {
                        tagged = true;
                        searchResultsFuture = DatabaseServices.tagUsers(input);
                        // searchResultsFuture = DatabaseServices.MessageFor(input);
                      });
                    }
                  },
                ),
              ),
            ),
          ),
          // ignore: unnecessary_null_comparison
          body: searchResultsFuture == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ShaderMask(
                          blendMode: BlendMode.srcIn,
                          shaderCallback: (Rect bounds) {
                            return RadialGradient(colors: <Color>[
                              Color.fromARGB(255, 67, 145, 173),
                              Colors.amber,
                            ], tileMode: TileMode.repeated)
                                .createShader(bounds);
                          },
                          child: Column(
                            children: [
                              Container(
                                child: Icon(
                                  Icons.tag,
                                  color: Colors.pink,
                                  size: 120,
                                ),
                              ),
                              Container(
                                  child: Text(
                                'See Who Tagged You...',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w100,
                                  color: Colors.black,
                                ),
                              )),
                            ],
                          )),
                    ],
                  ),
                )
              : tagged
                  ? FutureBuilder(
                      future: searchResultsFuture,
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (!snapshot.hasData) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (snapshot.data.docs.length == 0) {
                          return Center(
                            child: Text("oops No user found!"),
                          );
                        }
                        return Scaffold(
                            body: Container(
                          padding: const EdgeInsets.only(top: 10.0),
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 238, 7, 99),
                          ),
                          child: Scaffold(
                            backgroundColor: Color.fromARGB(0, 195, 128, 128),
                            appBar: new AppBar(
                              backgroundColor: Colors.amber,
                              //toolbarHeight: 100,
                              flexibleSpace: Container(
                                height: 300,
                                padding: const EdgeInsets.only(
                                    top: 10.0, left: 20.0, bottom: 10.0),
                                child: Row(
                                  children: [
                                    Text(
                                      "Tagged In...",
                                      style: TextStyle(
                                          fontSize: 20, color: Colors.pink),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            body: StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('NoticeBoard')
                                  .where('Group',
                                      isEqualTo: _searchController.text)
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
                                        return listViewWidget(
                                          snapshot.data!.docs[index].id,
                                          snapshot.data!.docs[index]['email'],
                                          snapshot.data!.docs[index]
                                              ['MessageFor'],
                                          snapshot.data!.docs[index]['createAt']
                                              .toDate(),
                                          snapshot.data!.docs[index]['id'],
                                          snapshot.data!.docs[index]
                                              ['download'],
                                          snapshot.data!.docs[index]
                                              ['description'],
                                          snapshot.data!.docs[index]['Group'],
                                          snapshot.data!.docs[index]['TAG'],
                                          snapshot.data!.docs[index]['Image'],
                                        );
                                      },
                                    );
                                  } else {
                                    return const Center(
                                      child: Text("There is no tasks",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20)),
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
                        ));
                      },
                    )
                  : Text("No Tags")),
    );
  }
}
