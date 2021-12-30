import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;

class DBHelper {
  static Future<void> createTable(sql.Database database) async {
    await database.execute(
        """
    Create table notes(
      id integer primary key autoincrement not null,
      title text,
      description
      )
    """);
  }

  static final dbName = 'notesdb.db';
  static final dbVersion = 1;

  static Future<sql.Database> database() async {
    return sql.openDatabase(dbName, version: dbVersion, onCreate: onCreate);
  }

  static Future onCreate(sql.Database database, int version) async {
    await createTable(database);
  }

  // ---------------------------------------------------

  //create an new note
  static Future<int> createNote(String title, String description) async {
    final db = await DBHelper.database();
    final data = {'title': title, 'description': description};
    final id = await db.insert('notes', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  //get all Notes
  static Future<List<Map<String, dynamic>>> getNotes() async {
    final db = await DBHelper.database();
    return db.query('notes', orderBy: "id");
  }

  //retrieve/read a single note by id
  static Future<List<Map<String, dynamic>>> getNote(int id) async {
    if (id != null) {
      final db = await DBHelper.database();
      return db.query('notes', where: "id = ?", whereArgs: [id], limit: 1);
    } else {
      print("Note retrieval failed!");
    }
  }

  //Update an note according to id
  static Future<int> updateNote(
      int id, String title, String description) async {
    if (id != null) {
      final db = await DBHelper.database();
      final data = {
        'title': title,
        'description': description,
      };

      final result =
          await db.update('notes', data, where: "id = ?", whereArgs: [id]);
      return result;
    } else {
      print("Note updating process failed!");
    }
  }

  //Delete a note
  static Future<void> deleteNote(int id) async {
    if (id != null) {
      final db = await DBHelper.database();
      await db.delete('notes', where: "id = ?", whereArgs: [id]);
    } else {
      print("Note deletion process failed!");
    }
  }

  //search note by title
  static Future<List<Map<String, dynamic>>> searchNote(String data) async {
    final db = await DBHelper.database();
    return db.query('notes', where: "title like ?", whereArgs: ['%$data%']);
  }
}
