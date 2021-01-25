import 'dart:convert';

class Event {
  String description;
  String name;
  int adventureID;
  int id;

  Event({this.id, this.name, this.description, this.adventureID});

  factory Event.fromMap(Map<String, dynamic> json) => Event(
      id: json["id"],
      name: json["name"],
      description: json["description"],
      adventureID: json[" adventureID"]);

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "description": description,
        " adventureID": adventureID
      };

  Event eventFromJson(String str) {
    final jsonData = json.decode(str);
    return Event.fromMap(jsonData);
  }

  String eventToJson(Event data) {
    final dyn = data.toMap();
    return json.encode(dyn);
  }

  void setEventName(String string) {
    name = string;
  }

  void setAdventureID(int id) {
    this.adventureID = id;
  }

  void setEventText(String string) {
    description = string;
  }

  String getEventText() {
    return description;
  }

  String getEventName() {
    return name;
  }

  void setID(int id) {
    this.id = id;
  }

  int getID() {
    return id;
  }
}
