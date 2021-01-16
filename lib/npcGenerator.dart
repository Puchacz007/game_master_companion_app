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
  bool isNPCGenerated = false;

  _NPCgeneratorPageState(this.adventure) {
    adventure.maxStats.forEach((key, value) {
      priorityStats[key] = false;
      skillPointsNumber.text = "0";
    });
  }

  String dropdownGenType = NPCGENRAND;
  String dropdownStoryPoint = NPCGENWHOLESTORY;
  String dropdownStat;
  String dropdownNPCSaveNumber = "0";
  Map<String, bool> priorityStats = new Map();

  // List<Stat> test2 = [];

  List<DynamicListStatGen> dynamicStatsWidgetList = [];

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

    temp = [];
    for (var i = 0; i < npcs.length; ++i) {
      temp.add(i.toString());
    }

    List<DropdownMenuItem> dropdownNpcNumberList = temp
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

                npcs.add(NPC());
                npcs[npcs.length - 1].generate(
                    dropdownGenType, adventure.maxStats, priorityStats,
                    skillPointsNumber: int.parse(skillPointsNumber.value.text));
                addDynamicStatTextField();
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
              Flexible(
                  child: ListView.builder(
                      itemCount: dynamicStatsWidgetList.length,
                      itemBuilder: (_, index) =>
                          dynamicStatsWidgetList[index])),
            if (isNPCGenerated)
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("saving NPC Story Point: "),
                    DropdownButton<String>(
                      value: dropdownStoryPoint,
                      icon: Icon(Icons.arrow_downward),
                      iconSize: 4,
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
                  ],
                ),
              ),
            if (isNPCGenerated)
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("saving NPC number: "),
                    DropdownButton<String>(
                      value: dropdownNPCSaveNumber,
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
                          dropdownNPCSaveNumber = newValue;
                        });
                      },
                      items: dropdownNpcNumberList,
                    ),
                  ],
                ),
              ),
            RaisedButton.icon(
              onPressed: () {
                if (dropdownStoryPoint == NPCGENWHOLESTORY)
                  adventure.addNPC(npcs[int.parse(dropdownNPCSaveNumber)]);
                else
                  adventure.storyPoints[int.parse(dropdownStoryPoint)]
                      .addNPC(npcs[int.parse(dropdownNPCSaveNumber)]);
              },
              icon: Icon(Icons.save_rounded),
              label: Text("Save NPC"),
            ),
          ],
        ),
      ),
    );
  }

  void addDynamicStatTextField() {
    dynamicStatsWidgetList.add(DynamicListStatGen(null, npcs.length - 1));
    npcs[npcs.length - 1].stats.forEach((statName, statValue) {
      dynamicStatsWidgetList.add(DynamicListStatGen(statName, statValue));
    });
    setState(() {});
  }
}

class DynamicListStatGen extends StatelessWidget {
  final TextEditingController statValueController = new TextEditingController();
  final String statName;
  final int text;

  DynamicListStatGen(this.statName, this.text) {
    statValueController.text = text.toString();
  }

  @override
  Widget build(BuildContext context) {
    //return Container(
    // decoration: new BoxDecoration(border: new Border.all(width: 1.0, color: Colors.grey), color: Colors.white70),
    // margin: new EdgeInsets.symmetric(vertical: 1.0),
    //child:
    if (statName != null)
      return ListTile(
        leading: Container(
            width: 200,
            // height: 21,
            child: Text(statName)
            // keyboardType: TextInputType.name,
            // maxLength: 3,
            // maxLengthEnforced: true,

            ),
        trailing: Container(
          width: 30,
          child: TextField(
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
            maxLength: 3,
            maxLengthEnforced: true,

            controller: statValueController,
            // textAlign: TextAlign.left ,
            decoration: InputDecoration(
              counterText: "",
            ),
          ),
        ),
      );
    else
      return Center(
        child: Text("NPC $text"),
      );
  }
}

/*
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
*/