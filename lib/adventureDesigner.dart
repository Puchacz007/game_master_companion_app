import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:game_master_companion_app/adventure.dart';
import 'package:game_master_companion_app/eventGenerator.dart';

import 'DBProvider.dart';
import 'NPC.dart';
import 'event.dart';
import 'npcGenerator.dart';
import 'storyPoint.dart';

class AdventureDesigner extends StatefulWidget {
  AdventureDesigner({Key key, @required this.adventure}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final Adventure adventure;

  @override
  _AdventureDesignerState createState() => _AdventureDesignerState(adventure);
}

class LinePainter extends CustomPainter {
  List<DynamicWidget> dynamicPlotPointsList;
  Adventure adventure;
  double appBarHeight;
  double statusBarHeight;
  Function getStatusBarHeight;
  ScrollController scrollController;

  LinePainter(this.dynamicPlotPointsList, this.adventure, this.appBarHeight,
      this.getStatusBarHeight, this.scrollController);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    paint.color = Colors.black;
    paint.strokeWidth = 5;

    if (adventure.storyPoints.length >= 2) {
      statusBarHeight = getStatusBarHeight();

      adventure.storyPoints.forEach((key, value) {
        RenderBox renderBox1 = dynamicPlotPointsList[dynamicPlotPointsList
                .indexWhere((element) => element.index == key)]
            ._outKey
            .currentContext
            .findRenderObject();

        adventure.getConnections(key).forEach((connection) {
          RenderBox renderBox2 = dynamicPlotPointsList[dynamicPlotPointsList
                  .indexWhere((element) => element.index == connection)]
              ._inKey
              .currentContext
              .findRenderObject();

          canvas.drawLine(
              Offset(
                  renderBox1.localToGlobal(Offset.zero).dx +
                      scrollController.offset +
                      7.5,
                  renderBox1.localToGlobal(Offset.zero).dy -
                      statusBarHeight -
                      appBarHeight +
                      7.5),
              Offset(
                  renderBox2.localToGlobal(Offset.zero).dx +
                      scrollController.offset +
                      7.5,
                  renderBox2.localToGlobal(Offset.zero).dy -
                      statusBarHeight -
                      appBarHeight +
                      7.5),
              paint);
        });
      });
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class _AdventureDesignerState extends State<AdventureDesigner> {
  double x1, x2, y1, y2;
  bool isSuccessful = false;
  double _x, _y;
  int source;
  List<DynamicWidget> dynamicPlotPointsList = [];
  List<DynamicNPCWidget> dynamicNPCWidgetList = [];
  Adventure adventure;
  bool isLoaded = false;
  ScrollController scrollController = new ScrollController();

  _AdventureDesignerState(this.adventure);

  double getStatusBarHeight() {
    return MediaQuery.of(context).padding.top;
  }

  void deletePlotPoint(int index, var dynamicPlotPoint) {
    adventure.storyPoints.forEach((key, value) {
      if (key != index) value.deleteConnection(index);
    });
   if (adventure.storyPoints[index].getID() != null)
      DBProvider.db.deleteStoryNode(adventure.storyPoints[index].getID());

    adventure.storyPoints.removeWhere((key, value) => key == index);
    dynamicPlotPointsList.remove(dynamicPlotPoint);

    setState(() {});
  }

  void connectPlotPoints(int target) {
    if (source != null && source != target && target != null) {
      adventure.addConnection(source, target);
      source = null;
    }
  }

  void setConnectionSource(int newSource) {
    source = newSource;
  }

  void loadGraph(
      Map<int, StoryPoint> map, double appBarHeight, double statusBarHeight) {
    isLoaded = true;
    map.forEach((key, storyPoint) {
      dynamicPlotPointsList.insert(
          dynamicPlotPointsList.length,
          new DynamicWidget(
              storyPoint.getX(),
              storyPoint.getY(),
              appBarHeight,
              statusBarHeight,
              setImage,
              setConnectionSource,
              connectPlotPoints,
              key,
              deletePlotPoint));
      dynamicPlotPointsList[dynamicPlotPointsList.length - 1].noteText.text =
          storyPoint.note;
      if (appBarHeight == 0 || statusBarHeight == 0) isLoaded = false;
    });
  }

  void setImage(DraggableDetails dragDetails, double appBarHeight,
      double statusBarHeight, int index) {
    if (dragDetails.offset.dx + scrollController.offset <= 100 ||
        dragDetails.offset.dy - appBarHeight - statusBarHeight <= 0) return;
    if (isSuccessful) {
      bool deleted = false;
      print("start x = " + _x.toString() + "\nstart y = " + _y.toString());
      setState(() {
        _x = dragDetails.offset.dx + scrollController.offset - 15;
        _y = dragDetails.offset.dy - appBarHeight - statusBarHeight;
        isSuccessful = false;
      });
      dynamicPlotPointsList.forEach((element) {
        if (element.index == index) {
          dynamicPlotPointsList.insert(
              index,
              new DynamicWidget(
                  _x,
                  _y,
                  appBarHeight,
                  statusBarHeight,
                  setImage,
                  setConnectionSource,
                  connectPlotPoints,
                  index,
                  deletePlotPoint));
          dynamicPlotPointsList[index].noteText.text = element.noteText.text;
          dynamicPlotPointsList.remove(element);

          deleted = true;
        }
      });
      if (deleted == false)
        dynamicPlotPointsList.insert(
            index,
            new DynamicWidget(
                _x,
                _y,
                appBarHeight,
                statusBarHeight,
                setImage,
                setConnectionSource,
                connectPlotPoints,
                index,
                deletePlotPoint));
      print("\nend y =" + _x.toString() + "\nend x =" + _y.toString());
      adventure.addNewStoryPoint(index, _x, _y);
    }
  }

  int getPlotPointsNextIndex() {
    int index = 0;
    dynamicPlotPointsList.forEach((element) {
      if (element.index == index) ++index;
    });

    return index;
  }

  @override
  Widget build(BuildContext context) {
    AppBar appBar = AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text('Adventure Designer'),
    );

    if (!isLoaded)
      loadGraph(adventure.getStoryPoints(), appBar.preferredSize.height,
          MediaQuery.of(context).padding.top);
    Timer(Duration(microseconds: 1), () {
      setState(() {});
    });
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: appBar,
      body: Stack(
        alignment: Alignment.topLeft,
        children: <Widget>[
          GestureDetector(
            onPanStart: (panStartDetails) {
              print("panStart");
            },
            onPanEnd: (panEndDetails) {
              print("panEnd");
            },
            onPanUpdate: (details) {
              print("global dx =" +
                  details.globalPosition.dx.toString() +
                  "global dy=" +
                  details.globalPosition.dy.toString());
            },
            child: SingleChildScrollView(
              controller: scrollController,
              scrollDirection: Axis.horizontal,
              child: Stack(
                children: [
                  Container(
                    height: 5000,
                    width: 5000,
                    child: Stack(
                      children: [
                        /*Positioned(
                top: 0,
                left: 100,
                width: 1000,
                height: 1000,
                child: Container(color: Colors.red),
              ),//for test
              */

                        DragTarget<AssetImage>(
                          builder: (context, List<AssetImage> candidateData,
                              rejectedData) {
                            return CustomPaint(
                              painter: LinePainter(
                                  dynamicPlotPointsList,
                                  adventure,
                                  appBar.preferredSize.height,
                                  getStatusBarHeight,
                                  scrollController),
                              child: Container(

                                  //color: Colors.yellow,

                                  ),
                            );
                          },
                          onWillAccept: (data) {
                            print("onWillAccept");
                            return true;
                          },
                          onLeave: (data) {
                            print("onLeave");
                          },
                          onAccept: (data) {
                            print("onAccept");
                            setState(() {
                              isSuccessful = true;
                            });
                          },
                        ),
                        if (dynamicPlotPointsList.isNotEmpty)
                          Stack(
                            children: dynamicPlotPointsList,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: 100,
            height: 1000,
            alignment: Alignment.topLeft,
            child: Drawer(
              child: Column(
                children: [
                  Draggable<AssetImage>(
                    data: AssetImage("assets/story_point.png"),
                    child: Image.asset("assets/story_point.png",
                        height: 100, width: 150),
                    feedback: Image.asset("assets/story_point.png",
                        height: 100, width: 150),
                    onDragEnd: (dragDetails) => setImage(
                        dragDetails,
                        appBar.preferredSize.height,
                        MediaQuery.of(context).padding.top,
                        getPlotPointsNextIndex()),
                  ),
                  /*
                  Container(
                    color: Colors.amberAccent,
                    child: Text(
                      'wieksze obrażenia od ognia , wrogie otoczenie , hałas zaalarmuje straż, ',
                      textAlign: TextAlign.left,

                      //overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  */
                  Container(
                    // width: 100,
                    // height: 40,
                    child: RaisedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  NPCgeneratorPage(adventure: adventure)),
                        );
                      },
                      child: const Text('Generate NPC',
                          style: TextStyle(fontSize: 15)),
                      // padding:const EdgeInsets.all(0.0) ,
                    ),
                  ),
                  Container(
                    //  width: 100,
                    //  height: 40,
                    child: RaisedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  EventGenerator(adventure: adventure)),
                        );
                      },
                      child: const Text('Generate event',
                          style: TextStyle(fontSize: 15)),
                      //  padding:const EdgeInsets.all(0.0) ,
                    ),
                  ),
                  Container(
                    //  width: 100,
                    //  height: 40,
                    child: RaisedButton(
                      onPressed: () {
                        Map<int, List<NPC>> allNpcs = adventure.getAllNPC();
                        dynamicNPCWidgetList.clear();
                        bool first = true;
                        int npcNumber = 0;
                        allNpcs.forEach((storyPointNumber, npcs) {
                          for (int i = 0; i < npcs.length; ++i) {
                            if (first)
                              dynamicNPCWidgetList.add(DynamicNPCWidget(
                                  true,
                                  npcs[i].stats,
                                  npcNumber,
                                  storyPointNumber,
                                  npcs[i].name));
                            else
                              dynamicNPCWidgetList.add(DynamicNPCWidget(
                                  false,
                                  npcs[i].stats,
                                  npcNumber,
                                  storyPointNumber,
                                  npcs[i].name));
                            ++npcNumber;
                            first = false;
                          }
                        });

                        /*
                          if (i == 0)
                            dynamicNPCWidgetList.add(
                                DynamicNPCWidget(true, allNpcs[i], i,allNpcs[i]));
                          else
                            dynamicNPCWidgetList.add(
                                DynamicNPCWidget(false, allNpcs[i].stats, i));
                        */
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                content: Container(
                                  width: double.maxFinite,
                                  child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Expanded(
                                            child: ListView(
                                          shrinkWrap: true,
                                          children: dynamicNPCWidgetList,
                                        ))
                                      ]),
                                ),
                              );
                            });
                      },
                      child: const Text('Show NPCs',
                          style: TextStyle(fontSize: 15)),
                      //  padding:const EdgeInsets.all(0.0) ,
                    ),
                  ),
                  Container(
                    //  width: 100,
                    //  height: 40,
                    child: RaisedButton(
                      onPressed: () {
                        if (adventure.events.isNotEmpty) {
                          Event event = adventure.getRandomEvent();

                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  content: Container(
                                    width: double.maxFinite,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          child: Text(event.getEventName()),
                                        ),
                                        Container(
                                          child: Text(event.getEventText()),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              });
                        }
                      },
                      child: const Text('Get random event',
                          style: TextStyle(fontSize: 15)),
                      //  padding:const EdgeInsets.all(0.0) ,
                    ),
                  ),
                  Container(
                    width: 100,
                    child: RaisedButton(
                      onPressed: () async {
                        if (adventure.getID() == null) {
                          adventure.setID(
                              await DBProvider.db.getMaxAdventureID() + 1);
                          await DBProvider.db.addData(adventure);
                        }

                        int newStoryPointID =
                            await DBProvider.db.getMaxStoryID() + 1;
                        int newNpcID = await DBProvider.db.getMaxNPCID();
                        int newEventID = await DBProvider.db.getMaxEventID();

                        adventure.npcs.forEach((npc) async {
                          if (npc.getID() == null) {
                            npc.setAdventureID(adventure.getID());
                            ++newNpcID;
                            npc.setID(newNpcID);
                            await DBProvider.db.addData(npc);
                          } else {
                            await DBProvider.db.updateData(npc);
                          }
                        });
                        dynamicPlotPointsList.forEach((plotPoint) {
                          adventure.storyPoints[plotPoint.index]
                              .setNote(plotPoint.noteText.text);
                        });

                        adventure.storyPoints.values
                            .forEach((storyPoint) async {
                          if (storyPoint.getID() == null) {
                            storyPoint.setAdventureID(adventure.getID());
                            storyPoint.setID(newStoryPointID);
                            ++newStoryPointID;
                            await DBProvider.db.addData(storyPoint);
                          } else {
                            await DBProvider.db.updateData(storyPoint);
                          }
                        });
                        adventure.storyPoints.values
                            .forEach((storyPoint) async {
                          storyPoint.npcs.forEach((npc) async {
                            if (npc.getID() == null) {
                              npc.setAdventureID(adventure.getID());
                              npc.setStoryPointID(storyPoint.getStoryPointId());
                              ++newNpcID;
                              npc.setID(newNpcID);
                              await DBProvider.db.addData(npc);
                            } else {
                              await DBProvider.db.updateData(npc);
                            }
                          });
                        });
                        adventure
                            .getStoryPoints()
                            .values
                            .forEach((storyPoint) async {
                          await DBProvider.db.addConnections(
                              storyPoint
                                  .saveConnections(adventure.getStoryPoints()),
                              storyPoint.getID(),
                              adventure.getID());
                        });
                        adventure.events.forEach((event) async {
                          if (event.adventureID == null) {
                            event.setAdventureID(adventure.getID());
                            ++newEventID;
                            event.setID(newEventID);
                            await DBProvider.db.addData(event);
                          } else {
                            await DBProvider.db.updateData(event);
                          }
                        });
                      },
                      child: const Text('Save', style: TextStyle(fontSize: 15)),
                      //  padding:const EdgeInsets.all(0.0) ,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DynamicWidget extends StatelessWidget {
  final double _x, _y;
  final Function setImageLocation,
      setConnectionSource,
      connectPlotPoints,
      deleteStoryPoint;
  final appBarHeight, statusBarHeight;
  final int index;
  final GlobalKey _outKey = GlobalKey();
  final GlobalKey _inKey = GlobalKey();
  final TextEditingController noteText = TextEditingController();

  DynamicWidget(
      this._x,
      this._y,
      this.appBarHeight,
      this.statusBarHeight,
      this.setImageLocation,
      this.setConnectionSource,
      this.connectPlotPoints,
      this.index,
      this.deleteStoryPoint);

  @override
  Widget build(context) {
    //   StoryPoint storyPoint = getStoryPoint(index);
    return Positioned(
      left: _x,
      top: _y,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(0.0),
            width: 15,
            height: 15,
            //color: Colors.red,
            alignment: Alignment.centerRight,
            decoration:
                BoxDecoration(color: Colors.red, shape: BoxShape.circle),
            child: IconButton(
              onPressed: () {
                connectPlotPoints(index);
              },
              icon: Icon(
                Icons.radio_button_checked_sharp,
                key: _inKey,
              ),
              iconSize: 15,
              padding: const EdgeInsets.all(0.0),
            ),
          ),
          Draggable<AssetImage>(
            data: AssetImage("assets/story_point.png"),
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Image.asset("assets/story_point.png", height: 100, width: 150),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      child: Text(
                        "storyPoint " + index.toString(),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    /*Container(
                      alignment: Alignment.center,
                      child: Text("storyOrder " + storyPoint.getStoryOrder().toString(),textAlign: TextAlign.center,),
                    ),*/

                    Container(
                      //  width: 100,
                      //  height: 40,
                      child: RaisedButton(
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  content: Container(
                                    width: double.maxFinite,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Flexible(
                                          child: TextFormField(
                                            maxLength: 500,
                                            maxLengthEnforced: true,
                                            keyboardType:
                                                TextInputType.multiline,
                                            maxLines: null,
                                            controller: noteText,
                                            decoration: InputDecoration(
                                              hintText: "note text",
                                              //   counterText: "",
                                            ),
                                          ),
                                        ),

                                        /*
                                    Container(
                                      child: Text(note),
                                    ),*/
                                      ],
                                    ),
                                  ),
                                );
                              });
                        },
                        child:
                            const Text('Notes', style: TextStyle(fontSize: 15)),
                        //  padding:const EdgeInsets.all(0.0) ,
                      ),
                    ),
                    Container(
                      child: IconButton(
                        //enableFeedback: false,
                        onPressed: () {
                          deleteStoryPoint(index, this);
                        },
                        icon: Icon(
                          Icons.delete,
                        ),
                        iconSize: 15,
                        padding: const EdgeInsets.all(0.0),
                      ),
                    ),
                    /*
                    TextField(
                    decoration: InputDecoration(
                    border: InputBorder.none,
                   hintText: 'Enter a search term'
                  ),
                  ),
                      TextField(
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Enter a search term'
                        ),
                      ),
                      */
                    /*
                    SizedBox(
                      width: 100,
                      height: 30,
                      child: RaisedButton(
                        onPressed: () {},
                        child:
                            const Text('Npcs', style: TextStyle(fontSize: 20)),
                        padding: const EdgeInsets.all(0.0),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    */
                  ],
                ),
              ],
            ),
            feedback:
                Image.asset("assets/story_point.png", height: 100, width: 150),
            onDragEnd: (dragDetails) => setImageLocation(
                dragDetails, appBarHeight, statusBarHeight, index),
          ),
          Container(
            padding: const EdgeInsets.all(0.0),

            width: 15,
            height: 15,
            //color: Colors.red,f
            alignment: Alignment.centerRight,
            decoration:
                BoxDecoration(color: Colors.red, shape: BoxShape.circle),

            child: IconButton(
              //enableFeedback: false,
              onPressed: () {
                setConnectionSource(index);
              },

              icon: Icon(
                Icons.radio_button_unchecked_sharp,
                key: _outKey,
              ),
              iconSize: 15,
              padding: const EdgeInsets.all(0.0),
            ),
          ),
        ],
      ),
    );
  }
}

class DynamicNPCWidget extends StatelessWidget {
  final bool first;
  final Map<String, int> stats;
  final List<DynamicNPCStatWidget> npsStatValueWidgetList = [];
  final List<DynamicNPCStatWidget> npsStatNameWidgetList = [];
  final number;
  final storyPointNumber;
  final name;

  DynamicNPCWidget(
      this.first, this.stats, this.number, this.storyPointNumber, this.name) {
    if (first) {
      /*
      stats.forEach((key, value) {
        npsStatNameWidgetList.add(DynamicNPCStatWidget(key.toString()));
      });
      */

    }
    stats.forEach((key, value) {
      npsStatValueWidgetList.add(DynamicNPCStatWidget(key, value.toString()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Column(
        //mainAxisAlignment: MainAxisAlignment.start,
        children: [
          /*
          Row(
            children: npsStatNameWidgetList,
          ),
        */
          if (first)
            Row(
              children: [
                Text("skill"),
                Spacer(),
                Text("value"),
              ],
            ),
          if (storyPointNumber >= 0)
            Center(
              child: Text(
                "$name nr $number from storyPoint $storyPointNumber",
                textAlign: TextAlign.center,
              ),
            ),
          if (storyPointNumber < 0)
            Center(
              child: Text(
                "$name nr $number",
                textAlign: TextAlign.center,
              ),
            ),
          Column(
            children: npsStatValueWidgetList,
          ),
        ],
      ),
    );
  }
}

class DynamicNPCStatWidget extends StatelessWidget {
  final String value, skillName;

  DynamicNPCStatWidget(this.skillName, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text("$skillName"),
        Spacer(),
        Text("$value"),
      ],
    );
  }
}