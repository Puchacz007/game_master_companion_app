import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:game_master_companion_app/adventure.dart';
import 'package:game_master_companion_app/adventureDesigner.dart';

class EventGenerator extends StatefulWidget {
  EventGenerator({Key key, @required this.adventure}) : super(key: key);

  final Adventure adventure;

  @override
  _EventGeneratorState createState() => _EventGeneratorState(adventure);
}

class _EventGeneratorState extends State<EventGenerator> {
  Adventure adventure;

  _EventGeneratorState(this.adventure);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("AdventureCustomizer"),
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            RaisedButton.icon(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AdventureDesigner(
                            adventure: adventure,
                          )),
                );
              },
              icon: Icon(Icons.add_circle_rounded),
              label: Text("Save Events"),
            ),
          ],
        ),
      ),
    );
  }
}
