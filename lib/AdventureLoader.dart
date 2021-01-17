import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:game_master_companion_app/DBProvider.dart';
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
  int choiceID = -1;
  List<Adventure> adventures = [];

  _AdventureLoaderState() {
    loadAdventures();
  }

  Future<void> loadAdventures() async {
    adventures.addAll(await DBProvider.db.getAllAdventures());
    for (int i = 0; i < adventures.length; ++i) {
      adventures[i].addAllStoryPoints(await DBProvider.db
          .getAllStoryPointsFromAdventure(adventures[i].getID()));
      adventures[i].addAllEvents(
          await DBProvider.db.getAllEventsFromAdventure(adventures[i].getID()));
      adventures[i].addAllNPCs(
          await DBProvider.db.getAllNPCsFromAdventure(adventures[i].getID()));
      setState(() {});
    }
  }

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
        title: Text("Adventure Loader"),
      ),
      body: Center(
        child: Column(
          children: [
            Text("Choose Adventure"),
            Flexible(
              child: ListView.builder(
                itemCount: adventures.length,
                itemBuilder: (context, index) {
                  return Card(
                    //color: Colors.yellow,
                    margin: EdgeInsets.all(10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    color: index == choiceID ? Colors.amber : Colors.white,
                    child: ListTile(
                      title: Center(
                        child: Text('${adventures[index].name}'),
                      ),
                      onTap: () {
                        setState(() {
                          choiceID = index;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            RaisedButton.icon(
              onPressed: () {
                if (choiceID >= 0) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            AdventureDesigner(adventure: adventures[choiceID])),
                  );
                }
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
