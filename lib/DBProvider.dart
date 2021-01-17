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
          "value INTEGER,"
          "NPCID INTEGER,"
          "adventureID INTEGER,"
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
          "TARGET_ID INTEGER,"
          "adventureID INTEGER,"
          "CONSTRAINT MAX_STATS_PK PRIMARY KEY(ID,TARGET_ID)"
          ")");
    });
  }

  addData(var data) async {
    final db = await database;
    String name;
    var result;
    if (data is Adventure) {
      name = "Adventure";
      //  result = await  db.query(name, where: "id = ?", whereArgs: [data.id]);
    } else if (data is StoryPoint) {
      name = "StoryPoint";
      //  result =await db.query(name, where: "id = ?", whereArgs: [data.id]);
    } else if (data is NPC) {
      name = "NPC";
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

  addMaxStats(Map<String, int> data, String adventureID) async {
    final db = await database;
    data.forEach((name, value) async {
      String valueString = value.toString();
      await db.rawInsert(
          "Insert Into MAX_STATS ( name , adventureID , value ) Values($name,$adventureID,$valueString);");
    });
  }

  updateData(var data) async {
    final db = await database;
    String name;
    if (data is Adventure) {
      name = "Adventure";
      //  result = await  db.query(name, where: "id = ?", whereArgs: [data.id]);
    } else if (data is StoryPoint) {
      name = "StoryPoint";
      //  result =await db.query(name, where: "id = ?", whereArgs: [data.id]);
    } else if (data is NPC) {
      name = "NPC";
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
    return list;
  }

  getAllNPCsFromAdventure(int adventureID) async {
    final db = await database;
    var res = await db
        .query("NPC", where: "adventureID = ?", whereArgs: [adventureID]);
    List<NPC> list =
        res.isNotEmpty ? res.map((c) => NPC.fromMap(c)).toList() : [];
    return list;
  }

  getAllEventsFromAdventure(int adventureID) async {
    final db = await database;
    var res = await db
        .query("Event", where: "adventureID = ?", whereArgs: [adventureID]);
    List<Event> list =
        res.isNotEmpty ? res.map((c) => Event.fromMap(c)).toList() : [];
    return list;
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
}
