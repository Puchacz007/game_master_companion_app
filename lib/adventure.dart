import 'dart:convert';
import 'dart:math';

import 'package:game_master_companion_app/strings.dart';

class Adventure {
  String name;
  int id;
  Map<int, StoryPoint> storyPoints;
  Map<String, int> maxStats; //TODO
  String pattern;
  var events = <Event>[];
  var npcs = <NPC>[];

  Adventure({this.id, this.name, this.maxStats});

  Adventure.init() {
    storyPoints = new Map();
    maxStats = new Map();
  }

  factory Adventure.fromMap(Map<String, dynamic> json) => Adventure(
        id: json["id"],
        name: json["name"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
      };

  Adventure storyPointFromJson(String str) {
    final jsonData = json.decode(str);
    return Adventure.fromMap(jsonData);
  }

  String storyPointToJson(Adventure data) {
    final dyn = data.toMap();
    return json.encode(dyn);
  }

  void setID(int id) {
    if (this.id == null) this.id = id;
  }

  void addStoryPoint(int index) async {
    if (!storyPoints.containsKey(index)) {
      storyPoints[index] = new StoryPoint();
    }
    storyPoints[index].setStoryOrder(index);
  }

  void removeStoryPoint(int key) {
    storyPoints.remove(key);
  }

  int getID() {
    return id;
  }

  void editStoryPointPlayers(int key, String players) {
    storyPoints[key].players = players;
  }

  void editStoryPointNote(int key, String note) {
    storyPoints[key].note = note;
  }

  void editStoryPointOrder(int key, int storyOrder) {
    storyPoints.forEach((id, value) {
      if (id != key) {
        if (value.storyOrder >= storyOrder) value.storyOrder++;
      }
    });
    storyPoints[key].storyOrder = storyOrder;
  }

  void addConnection(int key, int connection) {
    storyPoints[key].setConnection(connection);
  }

  Set getConnections(int key) {
    return storyPoints[key].getStoryPointConnections();
  }

  void addStat(String name, int value) {
    maxStats[name] = value;
  }

  void addNPC(NPC npc) {
    npcs.add(npc);
  }

  NPC getNPC(int index) {
    return npcs[index];
  }

  Event getRandomEvent() {
    var rng = new Random();
    return events[rng.nextInt(events.length - 1)];
  }
}

class StoryPoint {
  int id;
  int adventureID;
  String name;
  int storyOrder;
  String note;
  String players;
  var npcs = <NPC>[];
  Set<int> connections = {}; //TODO

  StoryPoint(
      {this.id,
      this.storyOrder,
      this.adventureID,
      this.name,
      this.note,
      this.players});

  factory StoryPoint.fromMap(Map<String, dynamic> json) => StoryPoint(
        id: json["id"],
        storyOrder: json["storyOrder"],
        adventureID: json["adventureID"],
        name: json["name"],
        note: json[" note"],
        players: json["players"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "storyOrder": storyOrder,
        "adventureID": adventureID,
        "name": name,
        "note": note,
        "players": players,
      };

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

  void addNPC(NPC npc) {
    npcs.add(npc);
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

  int getStoryPointId() {
    return id;
  }

  void setAdventureID(int id) {
    this.adventureID = id;
  }
}

class NPC {
  bool isImportant;
  int id, adventureID, storyPointID;
  String name;

  //Map<String, int> maxStats;
  // Map<String, bool> priorityStats;
  Map<String, int> stats; //TODO
/*
  NPC(this.maxStats, this.priorityStats) {
    stats = Map();
  }
*/
  NPC(
      {this.id,
      this.storyPointID,
      this.adventureID,
      this.name,
      this.isImportant});

  factory NPC.fromMap(Map<String, dynamic> json) => NPC(
      id: json["id"],
      storyPointID: json["storyPointID"],
      adventureID: json["adventureID"],
      name: json["name"],
      isImportant: json["isImportant"]);

  Map<String, dynamic> toMap() => {
        "id": id,
        "storyPointID": storyPointID,
        "adventureID": adventureID,
        "name": name,
        "isImportant": isImportant
      };

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

  void setStoryPointID(int id) {
    this.storyPointID = id;
  }

  void setAdventureID(int id) {
    this.adventureID = id;
  }

  bool setImportance(bool value) => isImportant = value;

  void generate(String generationType, Map<String, int> maxStats,
      Map<String, bool> priorityStats,
      {int skillPointsNumber = 0}) {
    stats = Map();
    var rng = new Random();

    for (var i in maxStats.keys) {
      stats[i] = 0;
    }
    bool loop = true;

    while (loop) {
      loop = false;
      maxStats.forEach((key, value) {
        switch (generationType) {
          case NPCGENNONE:
            stats[key] = 0;
            break;
          case NPCGENRAND:
            stats[key] = rng.nextInt(maxStats[key] + 1);
            break;
          case NPCGENSKILLPOINTS:
            if (skillPointsNumber <= 0 || maxStats[key] == stats[key]) break;
            loop = true;
            var temp = rng.nextInt(maxStats[key] + 1 - stats[key]);
            stats[key] += temp;

            if (skillPointsNumber - temp <= 0) stats[key] = skillPointsNumber;
            skillPointsNumber -= temp;

            break;
          case NPCGENSTATS:
            if (priorityStats[key])
              stats[key] = rng.nextInt((maxStats[key] + 1) ~/ 2) +
                  (maxStats[key] + 1) ~/ 2;
            else
              stats[key] = rng.nextInt((maxStats[key] + 1) ~/ 2);
            break;
          case NPCGENSKILLPOINTSSTATS:
            if (skillPointsNumber <= 0 || maxStats[key] == stats[key]) break;
            loop = true;
            var temp = rng.nextInt(maxStats[key] + 1 - stats[key]);
            if (!priorityStats[key]) {
              if (temp ~/ 2 > 0)
                temp = temp ~/ 2;
              else if (temp > 0) temp = 1;
            }
            stats[key] += temp;

            if (skillPointsNumber - temp <= 0) stats[key] = skillPointsNumber;
            skillPointsNumber -= temp;
            break;
          default:
            print("bad data");
            break;
        }
      });
    }
    void changeStat(String name, int value) {
      stats[name] = value;
    }
  }
}

class Event {
  String description;
  String name;
  int adventureID;

  Event({this.name, this.description, this.adventureID});

  factory Event.fromMap(Map<String, dynamic> json) => Event(
      name: json["name"],
      description: json["description"],
      adventureID: json[" adventureID"]);

  Map<String, dynamic> toMap() =>
      {"name": name, "description": description, " adventureID": adventureID};

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
}
