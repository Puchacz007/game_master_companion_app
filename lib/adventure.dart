import 'dart:convert';
import 'dart:math';

import 'NPC.dart';
import 'event.dart';
import 'storyPoint.dart';

class Adventure {
  String name;
  int id;
  Map<int, StoryPoint> storyPoints;
  Map<String, int> maxStats;
  String pattern;
  var events = <Event>[];
  var npcs = <NPC>[];

  Adventure({this.id, this.name, this.maxStats});

  Adventure.init(String adventureName) {
    storyPoints = new Map();
    maxStats = new Map();
    name = adventureName;
  }

  factory Adventure.fromMap(Map<String, dynamic> json) => Adventure(
        id: json["id"],
        name: json["name"],
      );
int getStatsNumber() {
    return maxStats.length;
  }

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

  void addNewStoryPoint(int index, double x, double y) async {
    if (!storyPoints.containsKey(index)) {
      storyPoints[index] = new StoryPoint.init(x, y);
    } else {
      storyPoints[index].setX(x);
      storyPoints[index].setY(y);
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

  Map<int, StoryPoint> getStoryPoints() {
    return storyPoints;
  }

  Set getConnections(int key) {
    return storyPoints[key].getStoryPointConnections();
  }

  void addStat(String name, int value) {
    maxStats[name] = value;
  }

  void addNPC(NPC npc) async {
    NPC newNPC = NPC(
        name: npc.name,
        storyPointID: npc.storyPointID,
        adventureID: npc.adventureID,
        isImportant: npc.isImportant);
    newNPC.stats.addAll(npc.stats);
    npcs.add(newNPC);
  }

  NPC getNPC(int index) {
    return npcs[index];
  }

  Event getRandomEvent() {
    var rng = new Random();
    return events[rng.nextInt(events.length)];
  }

  void addAllEvents(List<Event> events) {
    this.events.addAll(events);
  }

  addAllStoryPoints(List<StoryPoint> storyPoints) {
    this.storyPoints = new Map();
    for (int i = 0; i < storyPoints.length; ++i) {
      addStoryPoint(storyPoints[i]);
    }
  }

  void addAllNPCs(List<NPC> npcsList) {
    npcsList.forEach((npc) {
      if (npc.getStoryPointID() == null)
        npcs.add(npc);
      else
        // storyPoints[npc.getID].addNPC(npc);

        for (int i = 0; i < storyPoints.length; ++i) {
          if (storyPoints[i].getID() == npc.getStoryPointID()) {
            storyPoints[i].addNPC(npc);
            break;
          }
        }
    });
  }

  Map<int, List<NPC>> getAllNPC() {
    Map<int, List<NPC>> allNPCs = Map();
    List<NPC> adventureNPCs = npcs;
    allNPCs[-1] = adventureNPCs;
    storyPoints.forEach((key, value) {
      allNPCs[key] = value.getNpcs();
    });
    return allNPCs;
  }

  void addStoryPoint(StoryPoint storyPoint) {
    storyPoints[storyPoints.length] = StoryPoint(
        id: storyPoint.getID(),
        storyOrder: storyPoint.storyOrder,
        adventureID: storyPoint.adventureID,
        name: storyPoint.name,
        note: storyPoint.note,
        players: storyPoint.players,
        x: storyPoint.x,
        y: storyPoint.y);
    //StoryPoint(id: storyPoint.id ,adventureID: storyPoint.adventureID,storyOrder: storyPoint.storyOrder,name: storyPoint.name)
  }
}
