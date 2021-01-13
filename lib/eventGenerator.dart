import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:game_master_companion_app/adventure.dart';

class EventGenerator extends StatefulWidget {
  EventGenerator({Key key, @required this.adventure}) : super(key: key);

  final Adventure adventure;

  @override
  _EventGeneratorState createState() => _EventGeneratorState(adventure);
}

class _EventGeneratorState extends State<EventGenerator> {
  Adventure adventure;
  bool newEvent = true;

  _EventGeneratorState(this.adventure);

  Event event;
  TextEditingController eventTextController = TextEditingController();
  TextEditingController eventNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("AdventureCustomizer"),
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            if (newEvent == true)
              TextFormField(
                controller: eventNameController,
                decoration: InputDecoration(
                  counterText: "",
                ),
              ),
            if (newEvent == true)
              TextFormField(
                controller: eventTextController,
                decoration: InputDecoration(
                  counterText: "",
                ),
              ),
            if (newEvent == true)
              RaisedButton.icon(
                onPressed: () {
                  event = Event();
                  event.setEventName(eventNameController.text);
                  event.setEventText(eventTextController.text);
                  adventure.events.add(event);
                },
                icon: Icon(Icons.save_rounded),
                label: Text("Save Event"),
              ),
            if (newEvent == false)
              RaisedButton.icon(
                onPressed: () {
                  event = adventure.getRandomEvent();
                  setState(() {});
                },
                icon: Icon(Icons.create),
                label: Text("Generate Event"),
              ),
            if (newEvent == false)
              Text(event.getEventName() + "\n" + event.getEventText()),
          ],
        ),
      ),
    );
  }
}
