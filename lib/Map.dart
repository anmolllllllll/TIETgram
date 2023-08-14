import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/Notice_Board.dart';
import 'package:flutter_application_1/home.dart';
import 'package:pinch_zoom/pinch_zoom.dart';

class Map extends StatefulWidget {
  const Map({Key? key}) : super(key: key);

  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<Map> {
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
                    Icons.map,
                    color: Color.fromARGB(255, 182, 20, 74),
                  ),
                ),
                Text(
                  "MAP",
                  style: TextStyle(
                      fontSize: 20, color: Color.fromARGB(255, 182, 20, 74)),
                ),
              ],
            ),
          ),
        ),
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
          child: PinchZoom(
            child: Image.asset('assets/map.png'),
            resetDuration: const Duration(milliseconds: 100),
            maxScale: 2.5,
            onZoomStart: () {
              print('Start zooming');
            },
            onZoomEnd: () {
              print('Stop zooming');
            },
          ),
        ),
      ),
    );
  }
}
