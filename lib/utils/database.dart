import 'package:flutter/material.dart';
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
  static const String _dbWordTableName = "Words";
  static const String _dbListTableName = "Lists";
  static const String _dbEntryTableName = "Entries";

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
      final values = await txn.query(_dbWordTableName, columns: null);
      return values;
    });
    return words.map((word) => Word.fromJson(word)).toList();
  }

  static Future<List<Word>> getWordsQuery({
    required String listName,
    required bool isIconicList,
    required bool isInRandomOrder,
    int? limit,
    List<int>? exceptionIds,
  }) async {
    List<Map<String, dynamic>> words = await _db.transaction((txn) async {
      if (isIconicList) {
        String exceptionQuery = "";
        if (exceptionIds != null) {
          for (int id in exceptionIds) {
            exceptionQuery += " AND id != $id";
          }
        }
        return await txn.rawQuery('''
            SELECT * FROM $_dbWordTableName 
            WHERE $listName = 1 $exceptionQuery 
            ${isInRandomOrder ? "ORDER BY RANDOM()" : ""} 
            ${limit != null ? "LIMIT $limit" : ""}
          ''');
      } else {
        String exceptionQuery = "";
        if (exceptionIds != null) {
          for (int id in exceptionIds) {
            exceptionQuery += " AND id != $id";
          }
        }
        return await txn.rawQuery('''
            SELECT
              Words.id as id,
              Words.word as word,
              Words.word_search as word_search,
              Words.meaning as meaning,
              Words.description as description,
              Words.description_search as description_search,
              Words.willLearn as willLearn,
              Words.favorite as favorite,
              Words.learned as learned,
              Words.memorized as memorized
            FROM $_dbWordTableName 
            JOIN $_dbEntryTableName 
              ON $_dbWordTableName.id = $_dbEntryTableName.word_id
            JOIN $_dbListTableName
              ON $_dbListTableName.name = '$listName'
            WHERE $_dbEntryTableName.list_id = $_dbListTableName.id $exceptionQuery
            ${isInRandomOrder ? "ORDER BY RANDOM()" : ""}
            ${limit != null ? "LIMIT $limit" : ""}
          ''');
      }
    });
    return words.map((word) => Word.fromJson(word)).toList();
  }

  static Future<bool> checkIfListHaveWords(String listName) async {
    return await _db.transaction((txn) async {
      final listDataQuery = await txn.rawQuery("SELECT * FROM $_dbListTableName WHERE name='$listName'");
      final listData = listDataQuery.isEmpty ? null : listDataQuery.first;
      if (listData == null) return false;

      final result = await txn.rawQuery('''
        SELECT COUNT(*) as count 
        FROM $_dbEntryTableName
        WHERE list_id=${listData['id']}
        LIMIT 1
      ''');
      return ((result[0]["count"] as int) > 0);
    });
  }

  static Future<bool> checkIfIconicListHaveWords(String listName) async {
    return await _db.transaction((txn) async {
      final result = await txn.rawQuery('''
        SELECT COUNT(*) as count
        FROM $_dbWordTableName
        WHERE $listName = 1
        LIMIT 1
      ''');
      return ((result[0]["count"] as int) > 0);
    });
  }

  static Future<Word> getRandomWord() async {
    return await _db.transaction((txn) async {
      List<Map<String, dynamic>> result =
          await txn.rawQuery("SELECT * FROM $_dbWordTableName ORDER BY random() LIMIT 1");
      return Word.fromJson(result.first);
    });
  }

  static Future<bool> updateWord(int id, Map<String, Object?> newValue) async {
    return await _db.transaction((txn) async {
      final result = await txn.update(
        _dbWordTableName,
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
        _dbWordTableName,
        where: "id = ?",
        whereArgs: [id],
      );
      if (result == 1) return true;
      return false;
    });
  }

  static Future<void> createList(String listName) async {
    return await _db.transaction((txn) async {
      await txn.execute("INSERT INTO $_dbListTableName (name) VALUES ('$listName')");
    });
  }

  static Future<void> deleteList(String listName) async {
    return await _db.transaction((txn) async {
      await txn.execute("DELETE FROM $_dbListTableName WHERE name='$listName'");
    });
  }

  static Future<void> renameList(String listName, String newName) async {
    return await _db.transaction((txn) async {
      await txn.execute("UPDATE $_dbListTableName SET name='$newName' WHERE name='$listName'");
    });
  }

  static Future<Map<String, Object?>?> getListData(listName) async {
    final result = await _db.transaction((txn) async {
      return await txn.rawQuery("SELECT * FROM $_dbListTableName WHERE name='$listName'");
    });
    return result.isEmpty ? null : result.first;
  }

  static Future<List<String>> getLists() async {
    return await _db.transaction((txn) async {
      return (await txn.rawQuery("SELECT name FROM $_dbListTableName")).map((e) => e["name"].toString()).toList();
    });
  }

  static Future<Map<String, Map<String, Object?>>> getListsOfWord(int wordId) async {
    return await _db.transaction((txn) async {
      final rawResult = await txn.rawQuery('''
        SELECT
          $_dbListTableName.id as list_id,
          $_dbListTableName.name as list_name, 
          $_dbEntryTableName.word_id as word_id 
        FROM $_dbListTableName 
        LEFT JOIN $_dbEntryTableName 
          ON $_dbListTableName.id = $_dbEntryTableName.list_id 
            AND $_dbEntryTableName.word_id = $wordId
      ''');
      final result = rawResult.map((e) => {...e, "is_word_in_list": e["word_id"] == null ? false : true}).toList();

      final resultAsMap = <String, Map<String, Object?>>{};
      for (var val in result) {
        resultAsMap[val["list_name"] as String] = val;
      }

      return resultAsMap;
    });
  }

  static Future<void> changeListsOfWord(
    int wordId,
    Map<String, dynamic> prevListsData,
    Map<String, dynamic> newListsData,
  ) async {
    var changesToTrue = <int, bool>{}; // <id, willChange>
    var changesToFalse = <int, bool>{}; // <id, willChange>
    for (String list in prevListsData.keys) {
      bool prevValue = prevListsData[list]["is_word_in_list"];
      bool newValue = newListsData[list]["is_word_in_list"];
      if (prevValue != newValue) {
        if (newValue) {
          changesToTrue[newListsData[list]["list_id"]] = newValue;
        } else {
          changesToFalse[newListsData[list]["list_id"]] = newValue;
        }
      }
    }
    if (changesToTrue.isNotEmpty || changesToFalse.isNotEmpty) {
      final batch = _db.batch();

      for (var listId in changesToTrue.keys) {
        batch.rawInsert('''
            INSERT INTO $_dbEntryTableName
            (word_id, list_id) 
            VALUES ($wordId, $listId)
          ''');
      }

      for (var listId in changesToFalse.keys) {
        batch.rawDelete('''
            DELETE FROM $_dbEntryTableName
            WHERE word_id = $wordId
              AND list_id = $listId
          ''');
      }

      await batch.commit();
    }
  }
}

abstract final class DbKeys {
  static const String firstTabIndex = "firstTabIndex";
  static const String wordLearnListLength = "wordLearnListLength";
  static const String otherModsListLength = "otherModsListLength";
  static const String isAnimatable = "isAnimatable";
  static const String darkMode = "darkMode";
  static const String notifications = "notifications";
}

abstract class KeyValueDatabase {
  static late SharedPreferences _db;

  static Future<void> initDB() async {
    _db = await SharedPreferences.getInstance();

    if (!_db.containsKey(DbKeys.firstTabIndex)) setFirstTabIndex(0);
    if (!_db.containsKey(DbKeys.wordLearnListLength)) setWordLearnListLength(30);
    if (!_db.containsKey(DbKeys.otherModsListLength)) setOtherModsListLength(15);
    if (!_db.containsKey(DbKeys.isAnimatable)) setIsAnimatable(true);
    if (!_db.containsKey(DbKeys.darkMode)) setDarkMode(false);
    if (!_db.containsKey(DbKeys.notifications)) setNotifications(true);
  }

  static int getFirstTabIndex() => _db.getInt(DbKeys.firstTabIndex)!;
  static void setFirstTabIndex(int value) => _db.setInt(DbKeys.firstTabIndex, value);

  static int getWordLearnListLength() => _db.getInt(DbKeys.wordLearnListLength)!;
  static void setWordLearnListLength(int value) => _db.setInt(DbKeys.wordLearnListLength, value);

  static int getOtherModsListLength() => _db.getInt(DbKeys.otherModsListLength)!;
  static void setOtherModsListLength(int value) => _db.setInt(DbKeys.otherModsListLength, value);

  static bool getIsAnimatable() =>
      WidgetsBinding.instance.disableAnimations ? false : _db.getBool(DbKeys.isAnimatable)!;
  static void setIsAnimatable(bool value) => _db.setBool(DbKeys.isAnimatable, value);

  static bool getDarkMode() => _db.getBool(DbKeys.darkMode)!;
  static void setDarkMode(bool value) => _db.setBool(DbKeys.darkMode, value);

  static bool getNotifications() => _db.getBool(DbKeys.notifications)!;
  static void setNotifications(bool value) => _db.setBool(DbKeys.notifications, value);
}
