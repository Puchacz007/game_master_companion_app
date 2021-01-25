import 'dart:math';

import 'strings.dart';

class NPC {
  bool isImportant;
  int id, adventureID, storyPointID;
  String name;

  //Map<String, int> maxStats;
  // Map<String, bool> priorityStats;
  Map<String, int> stats = new Map();

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

  int getStoryPointID() {
    return storyPointID;
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

            if (skillPointsNumber - temp <= 0)
              stats[key] += skillPointsNumber;
            else
              stats[key] += temp;
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
            if (skillPointsNumber - temp <= 0)
              stats[key] += skillPointsNumber;
            else
              stats[key] += temp;
            skillPointsNumber -= temp;

            break;
          default:
            print("bad data");
            break;
        }
      });
    }
  }

  void changeStatValue(String name, int value) {
    stats[name] = value;
  }
}
