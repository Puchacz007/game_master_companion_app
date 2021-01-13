import 'dart:math';

import 'package:game_master_companion_app/strings.dart';

class Adventure {
  Map<int, StoryPoint> storyPoints;
  Map<String, int> maxStats;
  String pattern;
  var events = <Event>[];
  var npcs = <NPC>[];

  Adventure() {
    storyPoints = new Map();
    maxStats = new Map();
  }

  void addStoryPoint(int index) {
    if (!storyPoints.containsKey(index))
      storyPoints[index] = new StoryPoint(index, maxStats);
  }

  void removeStoryPoint(int key) {
    storyPoints.remove(key);
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
  String name;
  int storyOrder;
  String note;
  String players;
  var npcs = <NPC>[];
  Map<String, int> stats;
  Set<int> connections = {};

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

  StoryPoint(int order, this.stats) {
    storyOrder = order;
  }

  void setStoryOrder(int storyOrder) {
    this.storyOrder = storyOrder;
  }
}

class NPC {
  bool isImportant;

  Map<String, int> maxStats;
  Map<String, bool> priorityStats;
  Map<String, int> stats;

  NPC(this.maxStats, this.priorityStats) {
    stats = Map();
  }

  bool setImportance(bool value) => isImportant = value;

  void generate(String generationType, {int skillPointsNumber = 0}) {
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
  }
}

class Event {
  String eventText;
  String eventName;

  Event();

  void setEventName(String string) {
    eventName = string;
  }

  void setEventText(String string) {
    eventText = string;
  }

  String getEventText() {
    return eventText;
  }

  String getEventName() {
    return eventName;
  }
}
