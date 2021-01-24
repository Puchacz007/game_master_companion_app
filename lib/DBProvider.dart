import 'dart:io';

import 'package:game_master_companion_app/adventure.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

class DBProvider {
  DBProvider._();

  static final DBProvider db = DBProvider._();

  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;

    // if _database is null we instantiate it
    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "GameMasterCompanion.db");
    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      await db.execute("CREATE TABLE Adventure ("
          "id INTEGER PRIMARY KEY,"
          "name TEXT"
          ")");

      await db.execute("CREATE TABLE StoryPoint ("
          "id INTEGER PRIMARY KEY,"
          "storyOrder INTEGER,"
          "adventureID INTEGER,"
          "name TEXT,"
          "note TEXT,"
          "players TEXT,"
          "x REAL,"
          "y REAL"
          ")");

      await db.execute("CREATE TABLE NPC ("
          "id INTEGER PRIMARY KEY,"
          "storyPointID INTEGER,"
          "adventureID INTEGER,"
          "name TEXT,"
          "isImportant BIT"
          ")");

      await db.execute("CREATE TABLE EVENT ("
          "name TEXT PRIMARY KEY,"
          "description TEXT,"
          "adventureID INTEGER"
          ")");
      await db.execute("CREATE TABLE STATS ("
          "name TEXT,"
          "NPCID INTEGER,"
          "adventureID INTEGER,"
          "value INTEGER,"
          "CONSTRAINT STATS_PK PRIMARY KEY(name,adventureID,NPCID)"
          ")");
      await db.execute("CREATE TABLE MAX_STATS ("
          "name TEXT,"
          "adventureID INTEGER,"
          "value INTEGER,"
          "CONSTRAINT MAX_STATS_PK PRIMARY KEY(name,adventureID)"
          ")");
      await db.execute("CREATE TABLE CONNECTIONS ("
          "ID INTEGER,"
          "targetID INTEGER,"
          "adventureID INTEGER,"
          "CONSTRAINT CONNECTIONS_PK PRIMARY KEY(ID,targetID,adventureID)"
          ")");
    });
  }

  addData(var data) async {
    final db = await database;
    String name;
    if (data is Adventure) {
      name = "Adventure";
      //  result = await  db.query(name, where: "id = ?", whereArgs: [data.id]);
      await DBProvider.db.addMaxStats(data.maxStats, data.getID());
    } else if (data is StoryPoint) {
      name = "StoryPoint";
      //  result =await db.query(name, where: "id = ?", whereArgs: [data.id]);
      await DBProvider.db
          .addConnections(data.connections, data.id, data.adventureID);
    } else if (data is NPC) {
      name = "NPC";
      await DBProvider.db.addStats(data.stats, data.getID(), data.adventureID);
      //  result = await  db.query(name, where: "id = ?", whereArgs: [data.id]);
    } else if (data is Event) {
      name = "Event";
      // result = await  db.query(name, where: "name = ?", whereArgs: [data.name]);
    }
    //if(   result.isEmpty ) {
    var res = await db.insert(name, data.toMap());
    return res;
    //  }
  }

  addMaxStats(Map<String, int> data, int adventureID) async {
    final db = await database;
    data.forEach((name, value) async {
      await db.rawInsert(
          'Insert Into MAX_STATS ( name , adventureID , value ) Values("$name",$adventureID,$value);');
    });
  }

  updateMaxStats(Map<String, int> data, int adventureID) async {
    final db = await database;
    data.forEach((name, value) async {
      await db.rawInsert(
          'Update MAX_STATS SET value = $value WHERE name = $name AND adventureID = $adventureID;');
    });
  }

  addStats(Map<String, int> data, int npcID, int adventureID) async {
    final db = await database;
    data.forEach((name, value) async {
      await db.rawInsert(
          'Insert Into STATS ( name ,NPCID,adventureID, value ) Values("$name",$npcID,$adventureID,$value);');
    });
  }

  updateStats(Map<String, int> data, int npcID, int adventureID) async {
    final db = await database;
    data.forEach((name, value) async {
      await db.rawUpdate(
          'Update STATS SET value = ? WHERE name = ? AND NPCID = ? AND adventureID = ?',
          ['$value', '$name', '$npcID', '$adventureID']);
    });
  }

  addConnections(Set<int> data, int id, int adventureID) async {
    final db = await database;
    for (int i = 0; i < data.length; ++i) {
      var targetID = data.elementAt(i);
      await db.rawInsert(
          'Insert Into CONNECTIONS ( ID,targetID,adventureID) Values($id,$targetID,$adventureID);');
    }
  }

  updateConnections(Set<int> data, int id, int adventureID) async {
    final db = await database;
    for (int i = 0; i < data.length; ++i) {
      var targetID = data.elementAt(i);
      await db.rawUpdate(
          'Update CONNECTIONS SET targetID = ? WHERE ID = ? AND adventureID = ?',
          ['$targetID', '$id', '$adventureID']);
    }
  }

  getConnections() {}

  updateData(var data) async {
    final db = await database;
    String name;
    if (data is Adventure) {
      name = "Adventure";
      //  result = await  db.query(name, where: "id = ?", whereArgs: [data.id]);
    } else if (data is StoryPoint) {
      name = "StoryPoint";
      await DBProvider.db
          .updateConnections(data.connections, data.id, data.adventureID);
      //  result =await db.query(name, where: "id = ?", whereArgs: [data.id]);
    } else if (data is NPC) {
      name = "NPC";
      await DBProvider.db
          .updateStats(data.stats, data.getID(), data.adventureID);
      //  result = await  db.query(name, where: "id = ?", whereArgs: [data.id]);
    } else if (data is Event) {
      name = "Event";
      var res = await db.update(name, data.toMap(),
          where: "name = ?", whereArgs: [data.name]);
      return res;
    }
    var res = await db
        .update(name, data.toMap(), where: "id = ?", whereArgs: [data.id]);
    return res;
  }

  getMaxAdventureID() async {
    final db = await database;
    var res = await db.rawQuery("SELECT MAX(id) as id FROM Adventure");
    List<Adventure> list =
        res.isNotEmpty ? res.map((c) => Adventure.fromMap(c)).toList() : [];
    return list.first.id != null ? list.first.id : -1;
  }

  getMaxStoryID() async {
    final db = await database;
    var res = await db.rawQuery("SELECT MAX(id) as id FROM StoryPoint");

    List<Adventure> list =
        res.isNotEmpty ? res.map((c) => Adventure.fromMap(c)).toList() : [];
    return list.first.id != null ? list.first.id : -1;
  }

  getMaxNPCID() async {
    final db = await database;
    var res = await db.rawQuery("SELECT MAX(id) as id FROM NPC");
    List<Adventure> list =
        res.isNotEmpty ? res.map((c) => Adventure.fromMap(c)).toList() : [];
    return list.first.id != null ? list.first.id : -1;
  }

  getStoryPoint(int id) async {
    final db = await database;
    var res = await db.query("StoryPoint", where: "id = ?", whereArgs: [id]);
    return res.isNotEmpty ? StoryPoint.fromMap(res.first) : Null;
  }

  getAllStoryPointsFromAdventure(int adventureID) async {
    final db = await database;
    var res = await db.query("StoryPoint",
        where: "adventureID = ?", whereArgs: [adventureID]);
    List<StoryPoint> list =
        res.isNotEmpty ? res.map((c) => StoryPoint.fromMap(c)).toList() : [];
    return list.length > 0 ? list : -1;
  }

  getAllNPCsFromAdventure(int adventureID) async {
    final db = await database;
    var res = await db
        .query("NPC", where: "adventureID = ?", whereArgs: [adventureID]);
    List<NPC> list =
        res.isNotEmpty ? res.map((c) => NPC.fromMap(c)).toList() : [];
    /*
    var resMap;
    list.forEach((element) async {

      int npcID = element.getID();
      element.stats = new Map();
      resMap = await db.rawQuery(
          "SELECT NAME,VALUE FROM STATS WHERE npcID=$npcID AND adventureID = $adventureID");
      resMap.forEach((row) async{
        element.stats[row['name']]=row['value'];
      });
    });
    {
*/

    return list.length > 0 ? list : -1;
  }

  getAllAdventureStatsValues(int adventureID) async {
    final db = await database;
    List<Map> res = await db
        .rawQuery("SELECT * FROM STATS WHERE adventureID = $adventureID");
    List<Map> parsedResult = [];
    res.forEach((r) => parsedResult.add(Map<String, dynamic>.from(r)));
    return parsedResult;
  }

  getAdventureMaxStats(int adventureID) async {
    final db = await database;
    List<Map> res = await db
        .rawQuery("SELECT * FROM MAX_STATS WHERE adventureID = $adventureID");
    List<Map> parsedResult = [];
    res.forEach((r) => parsedResult.add(Map<String, dynamic>.from(r)));
    return parsedResult;
  }

  getAllAdventureConnections(int adventureID) async {
    final db = await database;
    List<Map> res = await db
        .rawQuery("SELECT * FROM Connections WHERE adventureID = $adventureID");
    List<Map> parsedResult = [];
    res.forEach((r) => parsedResult.add(Map<String, dynamic>.from(r)));
    return parsedResult;
  }

  getAllEventsFromAdventure(int adventureID) async {
    final db = await database;
    var res = await db
        .query("Event", where: "adventureID = ?", whereArgs: [adventureID]);
    List<Event> list =
        res.isNotEmpty ? res.map((c) => Event.fromMap(c)).toList() : [];
    return list.length > 0 ? list : -1;
  }

  getAllAdventures() async {
    final db = await database;
    var res = await db.query("Adventure");
    List<Adventure> list =
        res.isNotEmpty ? res.map((c) => Adventure.fromMap(c)).toList() : [];
    return list;
  }

  getAdventure(int id) async {
    final db = await database;
    var res = await db.query("Adventure", where: "id = ?", whereArgs: [id]);
    return res.isNotEmpty ? StoryPoint.fromMap(res.first) : Null;
  }

  deleteStoryNode(int id) async // TODO bugged
  {
    final db = await database;
    await db.delete("Connections",
        where: "ID = ? OR targetID = ?", whereArgs: [id, id]);
    await db.delete("StoryPoint", where: "id = ?", whereArgs: [id]);
    var res = await db
        .query("StoryPoint", where: "storyPointID = ?", whereArgs: [id]);
    List<StoryPoint> list =
        res.isNotEmpty ? res.map((c) => StoryPoint.fromMap(c)).toList() : [];
    await db.delete("NPC", where: "storyPointID = ?", whereArgs: [id]);
    list.forEach((element) async {
      await db
          .delete("STATS", where: "NPCID = ?", whereArgs: [element.getID()]);
    });
  }
}