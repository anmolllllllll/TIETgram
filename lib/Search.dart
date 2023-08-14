import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/DatabaseServices.dart';
import 'package:flutter_application_1/UserModel.dart';
import 'package:flutter_application_1/home.dart';
import 'package:flutter_application_1/profile.dart';
import 'package:flutter_application_1/signup.dart';
import 'package:flutter_application_1/visiteduserprofile.dart';
import 'package:get/get.dart';

class Search extends StatefulWidget {
  // final String currentUserId;
  final String visitedUserId;

  const Search({Key? key, required this.visitedUserId}) : super(key: key);

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  String? get firstname =>
      FirebaseAuth.instance.currentUser!.email?.substring(0, 1).toString();
  Future<QuerySnapshot>? searchResultsFuture;
  TextEditingController _searchController = TextEditingController();

  Icon customIcon = const Icon(Icons.search);
  Widget customSearchBar = const Text('My Personal Journal');

  clearSearch() {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _searchController.clear());
    setState(() {
      // ignore: unnecessary_null_comparison
      searchResultsFuture == null;
    });
  }

  buildUserFile(users) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(
          this.firstname.toString().toUpperCase(),
          style: TextStyle(
              color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      title: Text(users.name),
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => profile(
                  //currentUserId: FirebaseAuth.instance.currentUser!.uid,
                  visitedUserId: users.uid,
                )));
      },
    );
  }

  handleSearch(String query) {
    Future<QuerySnapshot> users = postsRef
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('userPosts')
        .where("name", isGreaterThanOrEqualTo: query)
        .get();
    setState(() {
      searchResultsFuture = users;
    });
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
      child: new MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            primarySwatch: Colors.amber, scaffoldBackgroundColor: Colors.black),
        home: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Color.fromARGB(255, 0, 0, 0),
          appBar: new AppBar(
            backgroundColor: Colors.white,
            title: Padding(
              padding: const EdgeInsets.only(top: 0.0, left: 0.0, bottom: 0.0),
              child: Container(
                child: TextField(
                  style: const TextStyle(color: Color.fromARGB(255, 9, 49, 64)),
                  controller: _searchController,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 15),
                    hintText: 'search',
                    hintStyle:
                        TextStyle(color: Color.fromARGB(255, 182, 20, 74)),
                    border: InputBorder.none,
                    icon: IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: Color.fromARGB(255, 182, 20, 74),
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
                      Icons.search,
                      color: Color.fromARGB(255, 182, 20, 74),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: Color.fromARGB(255, 182, 20, 74),
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
                        searchResultsFuture =
                            DatabaseServices.searchUsers(input);
                      });
                    }
                  },
                ),
              ),
            ),
          ),
          // ignore: unnecessary_null_comparison
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Color.fromARGB(255, 67, 145, 173)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                stops: const [0.2, 0.9],
              ),
            ),
            child: searchResultsFuture == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        //     ShaderMask(
                        //        blendMode: BlendMode.srcIn,
                        //        shaderCallback: (Rect bounds) {
                        //          return RadialGradient(colors: <Color>[
                        //            Color.fromARGB(255, 38, 116, 144),
                        //            Color.fromARGB(255, 218, 50, 106),
                        //          ], tileMode: TileMode.repeated)
                        //              .createShader(bounds);
                        //        },
                        Column(
                          children: [
                            Container(
                              child: Icon(
                                Icons.search,
                                color: Colors.white,
                                size: 100,
                              ),
                            ),
                            //        Container(
                            //            child: Text(
                            //          'Search...',
                            //          style: TextStyle(
                            //            fontSize: 20,
                            //            fontWeight: FontWeight.w400,
                            //            color: Colors.black,
                            //          ),
                            //        )),
                          ],
                        )
                        //    ),
                      ],
                    ),
                  )
                : FutureBuilder(
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
                      List<UserResult> searchResults = [];
                      snapshot.data.docs.forEach((doc) {
                        postss users = postss.fromDocument(doc);
                        UserResult searchResult = UserResult(users);
                        searchResults.add(searchResult);
                      });
                      return ListView(
                        children: searchResults,
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }
}

class UserResult extends StatelessWidget {
  final postss users;

  UserResult(this.users);
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color.fromARGB(255, 38, 116, 144).withOpacity(0.7),
      child: Column(children: <Widget>[
        GestureDetector(
          onTap: () => showProfile(context, visitedUserId: users.email),
          child: ListTile(
            leading: CircleAvatar(
              child: Text(
                users.email.substring(0, 1).toString().toUpperCase(),
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              users.name,
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              users.email,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        Divider(
          color: Colors.white54,
          height: 2.0,
        )
      ]),
    );
  }
}
