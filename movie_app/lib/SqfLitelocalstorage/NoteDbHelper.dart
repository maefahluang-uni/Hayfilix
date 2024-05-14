import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';

import 'package:movie_app/Component/global.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class FavMovielist {
  static const dbname = 'favlist.db';
  static const dbversion = 1;
  static const tablename = 'favoriatelist';
  static const columnId = 'id';
  static const columnfavid = 'tmdbid';
  static const columnfavtype = 'tmdbtype';
  static const columnfavname = 'tmdbname';
  static const columnfavrating = 'tmdbrating';

  static final FavMovielist _instance = FavMovielist();
  static Database? _database;

  Future<Database?> get db async {
    _database ??= await _initDb();
    return _database;
  }

  _initDb() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, dbname);
    return await openDatabase(path, version: dbversion, onCreate: _onCreate);
  }

  _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE $tablename (
      $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
      $columnfavid TEXT NOT NULL,
      $columnfavtype TEXT NOT NULL,
      $columnfavname TEXT NOT NULL,
      $columnfavrating TEXT NOT NULL
    )
    ''');
  }

  Future<int> insert(Map<String, dynamic> row) async {
    Database? db = await _instance.db;
    return await db!.insert(tablename, row);
  }

  Future<List<Map<String, dynamic>>> queryAll() async {
    Database? db = await _instance.db;
    return await db!.query(tablename);
  }

  Future<int> delete(int id) async {
    Database? db = await _instance.db;
    return await db!.delete(tablename, where: '$columnId = ?', whereArgs: [id]);
  }

  // delete from database by tmdbid and tmdbtype
  Future deletespecific(String id, String type) async {
    Database? db = await _instance.db;
    return await db!.delete(tablename,
        where: '$columnfavid = ? AND $columnfavtype = ?',
        whereArgs: [id, type]);
  }

  Future search(String id, String name, String type) async {
    Database? db = await _instance.db;
    return Sqflite.firstIntValue(await db!.rawQuery(
        'SELECT COUNT(*) FROM $tablename WHERE $columnfavid = ? AND $columnfavname = ? AND $columnfavtype = ?',
        [id, name, type]));
  }

  List<Map<String, dynamic>> transformResponse(String responseBody, String sortBy) {
    // Parse the JSON string into a Map
    List<Map<String, dynamic>> transformedList = [];
    try {
      Map<String, dynamic> jsonData = jsonDecode(responseBody);
      int id = 0;
      // Loop through each key-value pair in the jsonData
      jsonData.forEach((key, value) {
        // Extract the required fields from each entry
        id = id + 1; // You can set this to whatever unique ID you prefer
        int tmdbid = int.parse(key); // Parse the key as the tmdbid
        // Extract other fields from the nested value map
        String tmdbtype = value['tmdbtype'];
        String tmdbname = value['tmdbname'];
        String tmdbrating = value['tmdbrating'];
        // Create a new Map representing the desired format
        Map<String, dynamic> transformedEntry = {
          'id': id,
          'tmdbid': tmdbid,
          'tmdbtype': tmdbtype,
          'tmdbname': tmdbname,
          'tmdbrating': tmdbrating,
        };
        // Add the transformed entry to the list
        transformedList.add(transformedEntry);
      });
      if (sortBy == "name") {
        // Sorting by name
        transformedList.sort((a, b) => a['tmdbname'].compareTo(b['tmdbname']));
      } else if (sortBy == "rating") {
        // Sorting by rating (assuming ratings are numeric strings)
        transformedList.sort((a, b) {
          double ratingA = double.parse(a['tmdbrating']);
          double ratingB = double.parse(b['tmdbrating']);
          return ratingB.compareTo(ratingA); // Sort descending by rating
        });
      }
    } catch(e) {}
    return transformedList;
  }

  ////sort by name
  Future<List<Map<String, dynamic>>> queryAllSorted() async {
    // get firebase
    Database? db = await _instance.db;
    await db!.query(tablename, orderBy: '$columnfavname ASC');
    // get firebase
    var result;
    var url = 'https://us-central1-mini-e9d02.cloudfunctions.net/api/get-fav?email=${globalEmail}&password=${globalPassword}';
    var headers = {'Content-Type': 'application/json'};
    try {
      var response =
          await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        result = transformResponse(response.body, "name");
      }
    } catch(e) {}
    return result;
  }

  ////sort by rating
  Future<List<Map<String, dynamic>>> queryAllSortedRating() async {
    // get firebase
    Database? db = await _instance.db;
    await db!.query(tablename, orderBy: '$columnfavrating DESC');
    // get firebase
    var result;
    var url = 'https://us-central1-mini-e9d02.cloudfunctions.net/api/get-fav?email=${globalEmail}&password=${globalPassword}';
    var headers = {'Content-Type': 'application/json'};
    try {
      var response =
          await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        result = transformResponse(response.body, "rating");
      }
    } catch(e) {}
    return result;
  }

  Future<List<Map<String, dynamic>>> queryAllSortedDate() async {
    // original
    Database? db = await _instance.db;
    await db!.query(tablename, orderBy: '$columnId DESC');
    // get firebase
    var result;
    var url = 'https://us-central1-mini-e9d02.cloudfunctions.net/api/get-fav?email=${globalEmail}&password=${globalPassword}';
    var headers = {'Content-Type': 'application/json'};
    try {
      var response =
          await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        result = transformResponse(response.body, "none");
      }
    } catch(e) {}
    return result;
  }

  Future close() async {
    Database? db = await _instance.db;
    db!.close();
  }
}
