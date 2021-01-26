import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game_master_companion_app/adventure.dart';
import 'package:game_master_companion_app/strings.dart';

import 'NPC.dart';

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
    List<CheckboxListTile> dropdownStatList = adventure.maxStats.keys
        .toList()
        .map((val) => CheckboxListTile(
              value: priorityStats[val],
              title: Text(val),
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (checked) {
                setState(() {
                  priorityStats[val] = checked;
                });
                super.setState(() {
                  priorityStats[val] = checked;
                });
              },
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
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),

        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("NPC Generator"),
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
              Container(
                //  width: 100,
                //  height: 40,
                child: Column(
                  children: [
                    Center(child: Text("Select primary stats")),
                    ListTileTheme(
                      contentPadding: EdgeInsets.fromLTRB(14.0, 0.0, 24.0, 0.0),
                      child: ListBody(
                        children: dropdownStatList,
                        //children: [
                        // Text(contentText),
                        // ],
                      ),
                    ),
                  ],
                ),
                /* child: RaisedButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return StatefulBuilder(
                            builder: (context, setState) {
                              return AlertDialog(
                                title: Text('Select primary stats'),
                                contentPadding: EdgeInsets.only(top: 12.0),
                                content: SingleChildScrollView(
                                  child: ListTileTheme(
                                    contentPadding: EdgeInsets.fromLTRB(
                                        14.0, 0.0, 24.0, 0.0),
                                    child: ListBody(
                                      children: dropdownStatList,
                                      //children: [
                                      // Text(contentText),
                                      // ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        });
                  },

                  child: const Text('Primary stats',
                      style: TextStyle(fontSize: 15)),
                  //  padding:const EdgeInsets.all(0.0) ,
                ),*/
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
            if (isNPCGenerated)
              RaisedButton.icon(
                onPressed: () {
                  int firstStatIndex = int.parse(dropdownNPCSaveNumber) *
                          adventure.getStatsNumber() +
                      1 +
                      int.parse(dropdownNPCSaveNumber);
                  int temp = firstStatIndex;
                  int endLoop = firstStatIndex + adventure.getStatsNumber();
                  for (; firstStatIndex < endLoop; firstStatIndex++) {
                    if (temp == firstStatIndex)
                      npcs[int.parse(dropdownNPCSaveNumber)].setName(
                          dynamicStatsWidgetList[firstStatIndex - 1]
                              .nameController
                              .text);
                    npcs[int.parse(dropdownNPCSaveNumber)].changeStatValue(
                        dynamicStatsWidgetList[firstStatIndex].statName,
                        int.parse(dynamicStatsWidgetList[firstStatIndex]
                            .statValueController
                            .text));
                  }

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
  final TextEditingController nameController = new TextEditingController();
  final String statName;
  final int number;

  DynamicListStatGen(this.statName, this.number) {
    statValueController.text = number.toString();
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
            autofocus: false,
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
        child: Container(
          width: 100,
          child: TextField(
            autofocus: false,
            maxLength: 20,
            maxLengthEnforced: true,
            controller: nameController,
            // textAlign: TextAlign.left ,
            decoration: InputDecoration(counterText: "", hintText: "npc name"),
          ),
        ),
        //Text("NPC $number"),
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