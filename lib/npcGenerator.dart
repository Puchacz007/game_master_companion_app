import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game_master_companion_app/adventure.dart';
import 'package:game_master_companion_app/strings.dart';

class NPCgeneratorPage extends StatefulWidget {
  NPCgeneratorPage({Key key, @required this.adventure}) : super(key: key);

  final Adventure adventure;


  @override
  _NPCgeneratorPageState createState() => _NPCgeneratorPageState(adventure);
}

class _NPCgeneratorPageState extends State<NPCgeneratorPage> {
  Adventure adventure;
  var npcs = <NPC>[];
  final skillPointsNumber = TextEditingController();

  _NPCgeneratorPageState(this.adventure) {
    adventure.maxStats.forEach((key, value) {
      priorityStats[key] = false;
      skillPointsNumber.text = "0";
    });
  }

  String dropdownGenType = NPCGENRAND;
  String dropdownStoryPoint = NPCGENWHOLESTORY;
  String dropdownStat;

  Map<String, bool> priorityStats = new Map();

  // List<Stat> test2 = [];
  bool isNPCGenerated = false;

  @override
  Widget build(BuildContext context) {
    //  test=new Map();
/*
    adventure.stats.forEach((key, value) {
      test2.add(Stat(key, false));
    });
*/

    List<DropdownMenuItem> dropdownStatList = adventure.maxStats.keys
        .toList()
        .map((val) => DropdownMenuItem(
              value: val,
              child: Row(
                children: <Widget>[
                  Checkbox(
                    onChanged: (bool check) {
                      setState(() {
                        priorityStats[val] = check;
                        // val.setCheck(value);
                      });
                    },
                    value: priorityStats[val],
                  ),
                  Text(val),
                ],
              ),
            ))
        .toList();

    List<String> temp = [NPCGENWHOLESTORY];

    for (var storyPoint in adventure.storyPoints.keys) {
      temp.add(storyPoint.toString());
    }

    List<DropdownMenuItem> dropdownStoryPointsList = temp
        .map((val) => DropdownMenuItem(
              value: val,
              child: Text(val),
            ))
        .toList();

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
                NPCGENSKILLPOINTS,
                NPCGENSTATS,
                NPCGENSKILLPOINTSSTATS
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            DropdownButton<String>(
              value: dropdownStoryPoint,
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
                  dropdownStoryPoint = newValue;
                });
              },
              items: dropdownStoryPointsList,
            ),
            if (dropdownGenType == NPCGENSKILLPOINTS ||
                dropdownGenType == NPCGENSKILLPOINTSSTATS)
              Column(
                children: [
                  Text('Number of skill points to deposit',
                      textAlign: TextAlign.center),
                  Container(
                    width: 30 * adventure.maxStats.length.toDouble(),
                    height: 25,
                    child: TextFormField(
                      controller: skillPointsNumber,
                      maxLength: adventure.maxStats.length * 3,
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
                dropdownGenType == NPCGENSKILLPOINTSSTATS))
              DropdownButton(
                value: dropdownStat,
                onChanged: (val) => setState(() => dropdownStat = val),
                items: dropdownStatList,
              ),
            RaisedButton(
              onPressed: () {
                setState(() {
                  isNPCGenerated = true;
                });

                npcs.add(NPC(adventure.maxStats, priorityStats));
                npcs[npcs.length - 1].generate(dropdownGenType,
                    skillPointsNumber: int.parse(skillPointsNumber.value.text));

                //  adventure.getNPC(adventure.npcs.length-1).generate(dropdownGenType,skillPointsNumber:int.parse(skillPointsNumber.value.text));
                /*
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AdventureDesigner(
                            adventure: adventure,
                          )),
                );
                */
              },
              child: Text("Generate NPC"),
            ),
            if (isNPCGenerated)
              RaisedButton.icon(
                onPressed: () {
                  adventure.addNPC(npcs[0]); //TODO testowe
                  adventure.storyPoints[0].addNPC(npcs[0]);
                  /*

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AdventureDesigner(
                            adventure: adventure,
                          )),
                );

                */
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
