import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:game_master_companion_app/adventure.dart';
import 'package:game_master_companion_app/adventureDesigner.dart';

class AdventureLoader extends StatefulWidget {
  AdventureLoader({Key key, @required this.isEditable}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final bool isEditable;

  @override
  _AdventureLoaderState createState() => _AdventureLoaderState();
}

class _AdventureLoaderState extends State<AdventureLoader> {
  bool isLoaded = false;
  Adventure adventure;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("AdventureCustomizer"),
      ),
      body: Center(
        child: Column(
          children: [
            ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) {
                return GestureDetector(
                  // ListTile(title: Text($index));

                  onTap: () {},
                );
              },
            ),
            RaisedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AdventureDesigner(adventure: null)),
                );
              },
              icon: Icon(Icons.add_circle_rounded),
              label: Text("Load adventure"),
            ),
          ],
        ),
      ),
    );
  }
}
