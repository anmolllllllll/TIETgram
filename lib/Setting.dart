import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/LoginScreen.dart';
import 'package:flutter_application_1/home.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/signup.dart';

class Setting extends StatefulWidget {
  const Setting({Key? key}) : super(key: key);

  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        flexibleSpace: Container(
          height: 300,
          color: Colors.white,
          padding: const EdgeInsets.only(top: 30.0, left: 15.0, bottom: 3.0),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    top: 10.0, left: 5.0, bottom: 13.0, right: 15.0),
                child: Icon(
                  Icons.settings,
                  color: Color.fromARGB(255, 182, 20, 74),
                ),
              ),
              Text(
                "SETTING",
                style: TextStyle(
                    fontSize: 20, color: Color.fromARGB(255, 182, 20, 74)),
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 50.0, bottom: 10.0, right: 5.0),
        child: Container(
          //color: Colors.amber,

          height: 50,
          margin: const EdgeInsets.all(15.0),
          width: double.infinity,
          child: RawMaterialButton(
            fillColor: Color.fromARGB(255, 38, 116, 144),
            elevation: 0.0,
            padding: const EdgeInsets.symmetric(vertical: 15.0),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0)),
            onPressed: () {
              //FirebaseAuth.instance.currentUser! == null;
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => LoginScreen()));
            },
            child: Text(
              "Logout",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}
