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
      Database db = await openDatabase(dbPath);
      db.execute('CREATE TABLE Lists (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT UNIQUE)');
      db.execute('''
        CREATE TABLE IF NOT EXISTS Entries (word_id INTEGER, list_id INTEGER,
        FOREIGN KEY(word_id) REFERENCES Words(id),
        FOREIGN KEY(list_id) REFERENCES Lists(id)
        );
      ''');
      _db = db;
      return;
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

  static Future<void> createList(String listName) async {
    return await _db.transaction((txn) async {
      await txn.execute("INSERT INTO Lists (name) VALUES ('$listName')");
    });
  }

  static Future<void> deleteList(String listName) async {
    return await _db.transaction((txn) async {
      await txn.execute("DELETE FROM Lists WHERE name='$listName'");
    });
  }

  static Future<void> renameList(String listName, String newName) async {
    return await _db.transaction((txn) async {
      await txn.execute("UPDATE Lists SET name='$newName' WHERE name='$listName'");
    });
  }

  static Future<List<String>> getLists() async {
    return (await _db.rawQuery("SELECT name FROM Lists")).map((e) => e["name"].toString()).toList();
  }
}

abstract final class DbKeys {
  static const String firstTabIndex = "firstTabIndex";
  static const String wordLearnListLength = "wordLearnListLength";
  static const String otherModsListLength = "otherModsListLength";
  static const String isAnimatable = "isAnimatable";
}

abstract class KeyValueDatabase {
  static late SharedPreferences _db;

  static Future<void> initDB() async {
    _db = await SharedPreferences.getInstance();

    if (!_db.containsKey(DbKeys.firstTabIndex)) setFirstTabIndex(0);
    if (!_db.containsKey(DbKeys.wordLearnListLength)) setWordLearnListLength(30);
    if (!_db.containsKey(DbKeys.otherModsListLength)) setOtherModsListLength(15);
    if (!_db.containsKey(DbKeys.isAnimatable)) setIsAnimatable(true);
  }

  static int getFirstTabIndex() => _db.getInt(DbKeys.firstTabIndex)!;
  static void setFirstTabIndex(int value) => _db.setInt(DbKeys.firstTabIndex, value);

  static int getWordLearnListLength() => _db.getInt(DbKeys.wordLearnListLength)!;
  static void setWordLearnListLength(int value) => _db.setInt(DbKeys.wordLearnListLength, value);

  static int getOtherModsListLength() => _db.getInt(DbKeys.otherModsListLength)!;
  static void setOtherModsListLength(int value) => _db.setInt(DbKeys.otherModsListLength, value);

  static bool getIsAnimatable() => _db.getBool(DbKeys.isAnimatable)!;
  static void setIsAnimatable(bool value) => _db.setBool(DbKeys.isAnimatable, value);
}
