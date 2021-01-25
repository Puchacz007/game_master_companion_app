import 'dart:convert';

import 'NPC.dart';

class StoryPoint {
  int id;
  int adventureID;
  String name;
  int storyOrder;
  String note;
  String players;
  var npcs = <NPC>[];
  Set<int> connections = {};
  double x, y;

  StoryPoint.init(double x, double y) {
    this.x = x;
    this.y = y;
  }

  Set<int> saveConnections(Map<int, StoryPoint> map) {
    Set<int> newConnections = Set();
    connections.forEach((target) {
      map.forEach((key, value) {
        if (key == target) newConnections.add(value.getID());
      });
    });
    return newConnections;
  }

  void loadConnections(Map<int, StoryPoint> map) {
    Set<int> newConnections = Set();
    connections.forEach((target) {
      map.forEach((key, value) {
        if (value.getID() == target) newConnections.add(key);
      });
    });
    connections.clear();
    connections.addAll(newConnections);
  }

  void setNote(String note) {
    this.note = note;
  }

  double getX() {
    return x;
  }

  double getY() {
    return y;
  }

  void setX(double x) {
    this.x = x;
  }

  void setY(double y) {
    this.y = y;
  }

  StoryPoint(
      {this.id,
      this.storyOrder,
      this.adventureID,
      this.name,
      this.note,
      this.players,
      this.x,
      this.y});

  factory StoryPoint.fromMap(Map<String, dynamic> json) => StoryPoint(
        id: json["id"],
        storyOrder: json["storyOrder"],
        adventureID: json["adventureID"],
        name: json["name"],
        note: json["note"],
        players: json["players"],
        x: json["x"],
        y: json["y"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "storyOrder": storyOrder,
        "adventureID": adventureID,
        "name": name,
        "note": note,
        "players": players,
        "x": x,
        "y": y,
      };

  void deleteConnection(int target) {
    connections.removeWhere((element) => element == target);
  }

  StoryPoint storyPointFromJson(String str) {
    final jsonData = json.decode(str);
    return StoryPoint.fromMap(jsonData);
  }

  String storyPointToJson(StoryPoint data) {
    final dyn = data.toMap();
    return json.encode(dyn);
  }

  int getID() {
    return id;
  }

  void setID(int id) {
    if (this.id == null) this.id = id;
  }

  void addNPC(NPC npc) async {
    NPC newNPC = NPC(
      id: npc.getID(),
      name: npc.name,
      storyPointID: npc.storyPointID,
      adventureID: npc.adventureID,
      isImportant: npc.isImportant,
    );
    newNPC.stats.addAll(npc.stats);
    npcs.add(newNPC);
  }

  List<NPC> getNpcs() {
    return npcs;
  }

  NPC getNPC(int index) {
    return npcs[index];
  }

  void setConnection(int connection) {
    connections.add(connection);
  }

  Set getStoryPointConnections() {
    return connections;
  }

/*
  StoryPoint(int order, this.stats) {
    storyOrder = order;
  }
*/
  void setStoryOrder(int storyOrder) {
    this.storyOrder = storyOrder;
  }

  int getStoryOrder() {
    return storyOrder;
  }

  int getStoryPointId() {
    return id;
  }

  void setAdventureID(int id) {
    this.adventureID = id;
  }
}
