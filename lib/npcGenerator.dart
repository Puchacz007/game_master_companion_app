import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game_master_companion_app/adventure.dart';

import 'adventureDesigner.dart';

class NPCgeneratorPage extends StatefulWidget {
  NPCgeneratorPage({Key key, @required this.adventure}) : super(key: key);

  final Adventure adventure;

  setState() {}

  @override
  _NPCgeneratorPageState createState() => _NPCgeneratorPageState(adventure);
}

class _NPCgeneratorPageState extends State<NPCgeneratorPage> {
  Adventure adventure;

  _NPCgeneratorPageState(this.adventure) {
    adventure.stats.forEach((key, value) {
      test[key] = false;
    });
  }

  String dropdownGenType = NPCGENRAND;
  String dropdownStat;

  static const NPCGENNONE = 'None';
  static const NPCGENRAND = 'Random';
  static const NPCGENSKILL = 'By skill points number';
  static const NPCGENSTATS = 'By main stats';
  static const NPCGENSKILLSTATS = 'By skill points number and main stats';

  Map<String, bool> test = new Map();
  List<Stat> test2 = [];

  @override
  Widget build(BuildContext context) {
    //  test=new Map();

    adventure.stats.forEach((key, value) {
      test2.add(Stat(key, false));
    });

    List<DropdownMenuItem> dropdownStatList = adventure.stats.keys
        .toList()
        .map((val) => DropdownMenuItem(
              value: val,
              child: Row(
                children: <Widget>[
                  Checkbox(
                    onChanged: (bool value) {
                      setState(() {
                        test[val] = value;
                        // val.setCheck(value);
                      });
                    },
                    value: test[val],
                  ),
                  Text(val),
                ],
              ),
            ))
        .toList();

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
            Text("Generate by", textAlign: TextAlign.center),
            DropdownButton<String>(
              value: dropdownGenType,
              icon: Icon(Icons.arrow_downward),
              iconSize: 24,
              elevation: 16,
              style: TextStyle(color: Colors.deepPurple),
              underline: Container(
                height: 2,
                color: Colors.deepPurpleAccent,
              ),
              onChanged: (String newValue) {
                setState(() {
                  dropdownGenType = newValue;
                });
              },
              items: <String>[
                NPCGENNONE,
                NPCGENRAND,
                NPCGENSKILL,
                NPCGENSTATS,
                NPCGENSKILLSTATS
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            if (dropdownGenType == NPCGENSKILL ||
                dropdownGenType == NPCGENSKILLSTATS)
              Column(
                children: [
                  Text('Number of skill points to deposit',
                      textAlign: TextAlign.center),
                  Container(
                    width: 30 * adventure.stats.length.toDouble(), // TODO TEST
                    height: 25,
                    child: TextFormField(
                      maxLength: adventure.stats.length * 3,
                      maxLengthEnforced: true,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      decoration: InputDecoration(
                        counterText: "",
                      ),
                    ),
                  ),
                ],
              ),
            if ((dropdownGenType == NPCGENSTATS ||
                dropdownGenType == NPCGENSKILLSTATS))
              DropdownButton(
                value: dropdownStat,
                onChanged: (val) => setState(() => dropdownStat = val),
                items: dropdownStatList,
              ),
            RaisedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AdventureDesigner(
                            adventure: adventure,
                          )),
                );
              },
              child: Text("Generate NPC"),
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
              icon: Icon(Icons.save_rounded),
              label: Text("Save NPCs"),
            ),
          ],
        ),
      ),
    );
  }
}

class Stat {
  bool check;
  String stat;

  Stat(this.stat, this.check);

  String getStat() {
    return stat;
  }

  void setStat(String string) {
    stat = string;
  }

  bool getCheck() {
    return check;
  }

  void setCheck(bool value) {
    check = value;
  }
}
