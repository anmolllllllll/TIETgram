import 'package:auth/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_application_1/Notice_Board.dart';
import 'package:flutter_application_1/usernotification.dart';

class show_notification extends StatefulWidget {
  const show_notification({Key? key}) : super(key: key);

  @override
  _show_notificationState createState() => _show_notificationState();
}

class _show_notificationState extends State<show_notification> {
  String? email;
  String? tag;
  String? title;
  String? Notification;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController notification = TextEditingController();
  TextEditingController useremail = TextEditingController();
  TextEditingController usertitle = TextEditingController();
  TextEditingController usertag = TextEditingController();

  buildUploadForm() async {
    // await ref.putFile(imageFile!);
    // imageUrl = await ref.getDownloadURL();
    FirebaseFirestore.instance
        .collection('Notification')
        .doc(DateTime.now().toString())
        .set({
      'uid': FirebaseAuth.instance.currentUser!.uid,
      'email': _auth.currentUser!.email,
      'tag': usertag.text,
      'title': usertitle.text,
      'createAt': DateTime.now(),
      'notification': notification.text,
    });
  }

  Widget listViewWidget(
    String uid,
    String email,
    String tag,
    DateTime date,
    String title,
    String notification,
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
                        SizedBox(
                          width: 10.0,
                        ),
                        Text(
                          email,
                        ),
                        SizedBox(
                          width: 10.0,
                        ),
                        Text(tag),
                        SizedBox(
                          width: 10.0,
                        ),
                        Text(
                          title,
                        ),
                        SizedBox(
                          width: 10.0,
                        ),
                        Text(
                          notification,
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
                      builder: (_) => Notice_Board(
                        visitedUserId: '',
                      ),
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
                  Navigator.pop(context);
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
                    Text(
                      "NOTIFICATION",
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              ),
            ),
            body: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Notification')
                  .orderBy('createAt', descending: true)
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
                          snapshot.data!.docs[index]['uid'],
                          snapshot.data!.docs[index]['email'],
                          snapshot.data!.docs[index]['tag'],
                          snapshot.data!.docs[index]['createAt'].toDate(),
                          snapshot.data!.docs[index]['title'],
                          snapshot.data!.docs[index]['notification'],
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
            floatingActionButton: Wrap(
              direction: Axis.horizontal,
              children: [
                Container(
                  margin: const EdgeInsets.all(10.0),
                  child: FloatingActionButton(
                    heroTag: "1",
                    backgroundColor: Colors.deepOrange.shade400,
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => usernotification(),
                        ),
                      );
                    },
                    child: const Icon(Icons.notification_add),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
