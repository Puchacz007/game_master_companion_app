import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:game_master_companion_app/adventure.dart';
import 'package:game_master_companion_app/eventGenerator.dart';

import 'npcGenerator.dart';

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

  LinePainter(this.dynamicPlotPointsList, this.adventure, this.appBarHeight,
      this.getStatusBarHeight);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    paint.color = Colors.black;
    paint.strokeWidth = 5;

    if (adventure.storyPoints.length >= 2) {
      statusBarHeight = getStatusBarHeight();

      adventure.storyPoints.forEach((key, value) {
        RenderBox renderBox1 = dynamicPlotPointsList[key]
            ._outKey
            .currentContext
            .findRenderObject();

        adventure.getConnections(key).forEach((element) {
          RenderBox renderBox2 = dynamicPlotPointsList[element]
              ._inKey
              .currentContext
              .findRenderObject();

          canvas.drawLine(
              Offset(
                  renderBox1.localToGlobal(Offset.zero).dx,
                  renderBox1.localToGlobal(Offset.zero).dy -
                      statusBarHeight -
                      appBarHeight),
              Offset(
                  renderBox2.localToGlobal(Offset.zero).dx,
                  renderBox2.localToGlobal(Offset.zero).dy -
                      statusBarHeight -
                      appBarHeight),
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
  Adventure adventure;

  _AdventureDesignerState(this.adventure);

  double getStatusBarHeight() {
    return MediaQuery.of(context).padding.top;
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

  void setImage(DraggableDetails dragDetails, double appBarHeight,
      double statusBarHeight, int index) {
    if (isSuccessful) {
      bool deleted = false;
      print("start x = " + _x.toString() + "\nstart y = " + _y.toString());
      setState(() {
        _x = dragDetails.offset.dx;
        _y = dragDetails.offset.dy - appBarHeight - statusBarHeight;
        isSuccessful = false;
      });
      dynamicPlotPointsList.forEach((element) {
        if (element.index == index) {
          dynamicPlotPointsList.insert(
              index,
              new DynamicWidget(_x, _y, appBarHeight, statusBarHeight, setImage,
                  setConnectionSource, connectPlotPoints, index));
          dynamicPlotPointsList.remove(element);

          deleted = true;
        }
      });
      if (deleted == false)
        dynamicPlotPointsList.insert(
            index,
            new DynamicWidget(_x, _y, appBarHeight, statusBarHeight, setImage,
                setConnectionSource, connectPlotPoints, index));
      print("\nend y =" + _x.toString() + "\nend x =" + _y.toString());
      adventure.addStoryPoint(index);

      /*  if (dynamicPlotPointsList.length > 1)
        adventure.addConnection(index - 1, index); //testowe*/
    }
  }

  AssetImage boxes = new AssetImage("assets/test.png");

  @override
  Widget build(BuildContext context) {
    AppBar appBar = AppBar(
      title: Text('Adventure Designer'),
    );

    return Scaffold(
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
            child: DragTarget<AssetImage>(
              builder: (context, List<AssetImage> candidateData, rejectedData) {
                return CustomPaint(
                  painter: LinePainter(dynamicPlotPointsList, adventure,
                      appBar.preferredSize.height, getStatusBarHeight),
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
          ),
          Container(
            width: 100,
            height: 1000,
            alignment: Alignment.topLeft,
            child: Drawer(
              child: Column(
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Draggable<AssetImage>(
                    data: boxes,
                    child:
                        Image.asset("assets/test.png", height: 100, width: 100),
                    feedback:
                        Image.asset("assets/test.png", height: 100, width: 100),
                    onDragEnd: (dragDetails) => setImage(
                        dragDetails,
                        appBar.preferredSize.height,
                        MediaQuery.of(context).padding.top,
                        dynamicPlotPointsList.length),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    color: Colors.amberAccent,
                    child: Text(
                      'wieksze obrażenia od ognia , wrogie otoczenie , hałas zaalarmuje straż, ',
                      textAlign: TextAlign.left,

                      //overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  SizedBox(
                    // width: 100,
                    // height: 40,
                    child: RaisedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
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
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                    //  width: 100,
                    //  height: 40,
                    child: RaisedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
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
                ],
              ),
            ),
          ),
          if (dynamicPlotPointsList.isNotEmpty)
            Stack(
              children: dynamicPlotPointsList,
            )
        ],
      ),
    );
  }
}

class DynamicWidget extends StatelessWidget {
  final double _x, _y;
  final Function setImageLocation, setConnectionSource, connectPlotPoints;
  final appBarHeight, statusBarHeight;
  final int index;
  final GlobalKey _outKey = GlobalKey();
  final GlobalKey _inKey = GlobalKey();

  DynamicWidget(
      this._x,
      this._y,
      this.appBarHeight,
      this.statusBarHeight,
      this.setImageLocation,
      this.setConnectionSource,
      this.connectPlotPoints,
      this.index);

  @override
  Widget build(context) {
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
                print("test");
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
            data: AssetImage("assets/test.png"),
            child: Stack(
              children: [
                Image.asset("assets/test.png", height: 100, width: 100),
                Column(
                  children: [
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
                  ],
                )
              ],
            ),
            feedback: Image.asset("assets/test.png", height: 100, width: 100),
            onDragEnd: (dragDetails) => setImageLocation(
                dragDetails, appBarHeight, statusBarHeight, index),

            /*
         Image(
        width: 100,
        height: 100,
        image: new AssetImage("assets/test.png")


        ),
        */
          ),
          Container(
            padding: const EdgeInsets.all(0.0),

            width: 15,
            height: 15,
            //color: Colors.red,
            alignment: Alignment.centerRight,
            decoration:
                BoxDecoration(color: Colors.red, shape: BoxShape.circle),

            child: IconButton(
              //enableFeedback: false,
                onPressed: () {
                  setConnectionSource(index);
                print("test");
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
