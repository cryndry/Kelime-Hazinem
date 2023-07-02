import 'package:kelime_hazinem/utils/word_db_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:io' as io;

abstract class SqlDatabase {
  static late Database _db;
  static const String _dbName = "hazine.db";
  static const String _dbTableName = "Words";

  static Future<void> initDB() async {
    io.Directory applicationDirectory = await getApplicationDocumentsDirectory();
    String dbPath = path.join(applicationDirectory.path, _dbName);

    bool dbExists = await io.File(dbPath).exists();
    if (!dbExists) {
      // copies the db file from assets
      ByteData data = await rootBundle.load(path.join("assets", _dbName));
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await io.File(dbPath).writeAsBytes(bytes, flush: true);
    }

    _db = await openDatabase(dbPath);
  }

  static Future<List<Word>> getAllWords() async {
    List<Map<String, dynamic>> words = await _db.transaction((txn) async {
      final values = await txn.query(_dbTableName, columns: null);
      return values;
    });
    return words.map((word) => Word.fromJson(word)).toList();
  }

  static Future<List<Word>> getWordsQuery(int limit, String listName) async {
    List<Map<String, dynamic>> words = await _db.transaction((txn) async {
      return await txn.rawQuery("SELECT * FROM $_dbTableName WHERE $listName = 1 LIMIT $limit");
    });
    return words.map((word) => Word.fromJson(word)).toList();
  }

  static Future<bool> checkIfListHaveWords(String listName) async {
    try {
      return await _db.transaction((txn) async {
        final result = await txn.rawQuery("SELECT * FROM $_dbTableName WHERE $listName = 1");
        return result.isNotEmpty;
      });
    } catch (e) {
      return false;
    }
  }

  static Future<Word> getRandomWord() async {
    return await _db.transaction((txn) async {
      List<Map<String, dynamic>> result = await txn.rawQuery("SELECT * FROM $_dbTableName ORDER BY random() LIMIT 1");
      return Word.fromJson(result.first);
    });
  }

  static Future<bool> updateWord(int id, Map<String, Object?> newValue) async {
    return await _db.transaction((txn) async {
      final result = await txn.update(
        _dbTableName,
        newValue,
        conflictAlgorithm: ConflictAlgorithm.replace,
        where: "id = ?",
        whereArgs: [id],
      );
      if (result == 1) return true;
      return false;
    });
  }

  static Future<bool> deleteWord(int id) async {
    return await _db.transaction((txn) async {
      final result = await txn.delete(
        _dbTableName,
        where: "id = ?",
        whereArgs: [id],
      );
      if (result == 1) return true;
      return false;
    });
  }
}

abstract class SharedPreferencesDatabase {
  static late SharedPreferences db;

  static Future<void> initDB() async {
    db = await SharedPreferences.getInstance();

    if (!db.containsKey("firstTabIndex")) {
      SharedPreferencesDatabase.db.setInt("firstTabIndex", 0);
    }

    if (!db.containsKey("wordLearnListLength")) {
      SharedPreferencesDatabase.db.setInt("wordLearnListLength", 50);
    }

    if (!db.containsKey("otherModsListLength")) {
      SharedPreferencesDatabase.db.setInt("otherModsListLength", 20);
    }
  }
}
