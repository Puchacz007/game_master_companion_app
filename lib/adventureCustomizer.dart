import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game_master_companion_app/adventure.dart';
import 'package:game_master_companion_app/adventureDesigner.dart';

class AdventureCustomizer extends StatefulWidget {
  AdventureCustomizer({Key key, @required this.isCustom}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final bool isCustom;

  @override
  _AdventureCustomizerState createState() => _AdventureCustomizerState();
}

class _AdventureCustomizerState extends State<AdventureCustomizer> {
  // _AdventureCustomizerState ({Key key, @required this.isCustom}) : super(key: key);
  List<DynamicList> dynamicStatsWidgetList = [];
  final TextEditingController adventureNameController =
      new TextEditingController();

  _AdventureCustomizerState() {
    dynamicStatsWidgetList.add(DynamicList());
  }

  @override
  Widget build(context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("AdventureCustomizer"),
      ),
      body: Container(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.

          child: Builder(builder: (context) {
        // if (widget.isCustom)
        {
          return //Custom Adventure

              Container(
            child: Column(
              //mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                // SizedBox(height: 20,width: 20,),

                Container(
                  width: 200,
                  // height: 21,
                  alignment: Alignment.center,
                  child: TextField(
                    textAlign: TextAlign.center,
                    // keyboardType: TextInputType.name,
                    // maxLength: 3,
                    // maxLengthEnforced: true,
                    maxLengthEnforced: true,
                    maxLength: 22,
                    // not working because flutter is bugged :P
                    controller: adventureNameController,
                    decoration: InputDecoration(
                      hintText: "Adventure name",
                      counterText: "",
                    ),
                  ),
                ),

                Text(
                    "Write down each character stat used in this adventure by characters",
                    textAlign: TextAlign.center),

                //Container(
                // height: 100,
                //width: 100,
                // child: Column(
                // children:<Widget> [
                Flexible(
                    child: ListView.builder(
                        itemCount: dynamicStatsWidgetList.length,
                        itemBuilder: (_, index) =>
                            dynamicStatsWidgetList[index])),
                RaisedButton.icon(
                  onPressed: () {
                    if (adventureNameController.text.isNotEmpty) {
                      Adventure adventure =
                          new Adventure.init(adventureNameController.text);
                      bool areStatsGood = true;
                      for (int i = 0; i < dynamicStatsWidgetList.length; ++i) {
                        print(dynamicStatsWidgetList[i]
                                .statNameController
                                .text +
                            " " +
                            dynamicStatsWidgetList[i].statValueController.text);
                        if (dynamicStatsWidgetList[i]
                                .statNameController
                                .text
                                .isEmpty ||
                            dynamicStatsWidgetList[i]
                                .statValueController
                                .text
                                .isEmpty) {
                          areStatsGood = false;
                          break;
                        }
                        adventure.addStat(
                            dynamicStatsWidgetList[i].statNameController.text,
                            int.parse(dynamicStatsWidgetList[i]
                                .statValueController
                                .text));
                      }
                      if (areStatsGood) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  AdventureDesigner(adventure: adventure)),
                        );
                      }
                    }
                  },
                  icon: Icon(Icons.add_circle_rounded),
                  label: Text("Create Adventure"),
                ),
              ],

              //   ),

              //   ),

              //    ],
              //  ),
            ),
          );
        }
        /*else {
              return //Based Adventure
                SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      RaisedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AdventureDesigner()),
                          );
                        },
                        icon: Icon(Icons.add_circle_rounded),
                        label: Text("Create Adventure"),
                      ),
                    ],
                  ),
                );
            }*/
      })),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addDynamicStatTextField();
        },
        child: Icon(Icons.add),
      ),
    );
  }

  addDynamicStatTextField() {
    dynamicStatsWidgetList.add(DynamicList());
    setState(() {});
  }
}

class DynamicList extends StatelessWidget {
  final TextEditingController statValueController = new TextEditingController();
  final TextEditingController statNameController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    //return Container(
    // decoration: new BoxDecoration(border: new Border.all(width: 1.0, color: Colors.grey), color: Colors.white70),
    // margin: new EdgeInsets.symmetric(vertical: 1.0),
    //child:
    return new ListTile(
      leading: Container(
        width: 200,
        // height: 21,
        child: TextField(
          // keyboardType: TextInputType.name,
          //maxLength: 3,
          // maxLengthEnforced: true,
          maxLengthEnforced: true,
          maxLength: 22, // not working because flutter is bugged :P
          controller: statNameController,

          decoration: InputDecoration(
            hintText: "Statistic name",
            counterText: "",
          ),
        ),
      ),
      title: Container(
          alignment: Alignment.centerRight, child: Text("max stat value:")),
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
      // ),
    );
  }
}
