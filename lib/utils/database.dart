import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cr_file_saver/file_saver.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:kelime_hazinem/firebase_options.dart';
import 'package:kelime_hazinem/notifications/notifications.dart';
import 'package:kelime_hazinem/utils/word_db_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:io' as io;

abstract class SqlDatabase {
  static late Database _db;
  static late io.Directory _applicationDirectory;
  static const String _dbName = "hazine.db";
  static const String _cacheDbName = "data.db";
  static const String _dbWordTableName = "Words";
  static const String _dbListTableName = "Lists";
  static const String _dbEntryTableName = "Entries";

  static Future<void> initDB() async {
    _applicationDirectory = (await getApplicationDocumentsDirectory()).absolute;
    String dbPath = path.join(_applicationDirectory.path, _dbName);

    bool dbExists = await io.File(dbPath).exists();
    if (!dbExists) {
      // copies the db file from assets
      ByteData data = await rootBundle.load(path.join("assets", _dbName));
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await io.File(dbPath).writeAsBytes(bytes, flush: true);
    }

    _db = await openDatabase(dbPath, onOpen: (db) {
      db.execute("PRAGMA foreign_keys = ON");
    });
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
            exceptionQuery += " AND $_dbWordTableName.id != $id";
          }
        }
        return await txn.rawQuery('''
            SELECT
              $_dbWordTableName.id as id,
              $_dbWordTableName.word as word,
              $_dbWordTableName.word_search as word_search,
              $_dbWordTableName.meaning as meaning,
              $_dbWordTableName.description as description,
              $_dbWordTableName.description_search as description_search,
              $_dbWordTableName.willLearn as willLearn,
              $_dbWordTableName.favorite as favorite,
              $_dbWordTableName.learned as learned,
              $_dbWordTableName.memorized as memorized
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

  static Future<Word> getRandomWord([Database? db]) async {
    return await (db ?? _db).transaction((txn) async {
      List<Map<String, dynamic>> result =
          await txn.rawQuery("SELECT * FROM $_dbWordTableName ORDER BY random() LIMIT 1");
      return Word.fromJson(result.first);
    });
  }

  static Future<Map<String, Object?>?> getWordData(String word) async {
    final result = await _db.transaction((txn) async {
      return await txn.rawQuery("SELECT * FROM $_dbWordTableName WHERE word='$word'");
    });
    return result.isEmpty ? null : result.first;
  }

  static Future<int> createWord(Map<String, Object?> word) async {
    return await _db.transaction((txn) async {
      return await txn.insert(_dbWordTableName, word);
    });
  }

  static Future<bool> updateWord(int id, Map<String, Object?> newValue, [Database? db]) async {
    return await (db ?? _db).transaction((txn) async {
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

  static Future<bool> checkIfWordExists(String word) async {
    final result = await _db.transaction((txn) async {
      return await txn.rawQuery("SELECT * FROM $_dbWordTableName WHERE word='$word'");
    });
    return result.isNotEmpty;
  }

  static Future<int> createList(String listName) async {
    return await _db.transaction((txn) async {
      return await txn.rawInsert("INSERT INTO $_dbListTableName (name) VALUES ('$listName')");
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

  static Future<bool> checkIfListExists(String listName) async {
    final result = await _db.transaction((txn) async {
      return await txn.rawQuery("SELECT * FROM $_dbListTableName WHERE name='$listName'");
    });
    return result.isNotEmpty;
  }

  static Future<Map<String, Object?>?> getListData(String listName) async {
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

  static Future<void> changeListsOfWord(int wordId, Map<String, dynamic> listsData) async {
    final batch = _db.batch();
    await _db.transaction((txn) async {
      for (var listData in listsData.entries) {
        int listId = listData.value["list_id"];
        bool isWordInList = listData.value["is_word_in_list"];

        final query = await txn.rawQuery('''
          SELECT * FROM $_dbEntryTableName
          WHERE word_id = $wordId
            AND list_id = $listId
        ''');

        if (query.isEmpty && isWordInList) {
          final timeCreated = DateTime.now().toString().split(".")[0];
          batch.rawInsert(
              "INSERT INTO $_dbEntryTableName (word_id, list_id, time_created) VALUES ($wordId, $listId, '$timeCreated')");
        } else if (query.isNotEmpty && !isWordInList) {
          batch.rawDelete("DELETE FROM $_dbEntryTableName WHERE word_id = $wordId AND list_id = $listId");
        }
      }
    });

    await batch.commit();
  }

  static Future<io.File> shareLists(List<String> lists) async {
    final sharableData = await _db.transaction((txn) async {
      final listsAsString = lists.map((e) => "'$e'").join(", ");
      final wordsData = await txn.rawQuery('''
        SELECT DISTINCT
          $_dbWordTableName.id as id,
          $_dbWordTableName.word as word,
          $_dbWordTableName.word_search as word_search,
          $_dbWordTableName.meaning as meaning,
          $_dbWordTableName.description as description,
          $_dbWordTableName.description_search as description_search
        FROM $_dbWordTableName 
        JOIN $_dbEntryTableName 
          ON $_dbWordTableName.id = $_dbEntryTableName.word_id
        JOIN $_dbListTableName
          ON $_dbListTableName.name IN ($listsAsString)
        WHERE $_dbEntryTableName.list_id = $_dbListTableName.id
      ''');

      final listsData = await txn.rawQuery('''
        SELECT * FROM $_dbListTableName
        WHERE name IN ($listsAsString)
      ''');

      final listIds = listsData.map((e) => e["id"]).join(", ");
      final entriesData = await txn.rawQuery('''
        SELECT word_id, list_id FROM $_dbEntryTableName
        WHERE list_id IN ($listIds)
      ''');

      return {
        _dbWordTableName: wordsData,
        _dbListTableName: listsData,
        _dbEntryTableName: entriesData,
      };
    });

    final io.Directory applicationDirectory = await getApplicationDocumentsDirectory();
    final String cacheDbPath = path.join(applicationDirectory.path, _cacheDbName);
    final cacheDbFile = io.File(cacheDbPath);
    final bool cacheDbExists = await cacheDbFile.exists();
    if (cacheDbExists) cacheDbFile.deleteSync();

    final cacheDb = await openDatabase(cacheDbPath, version: 1, onCreate: (db, version) async {
      await db.execute("""
        CREATE TABLE $_dbWordTableName (
          "id" INTEGER NOT NULL UNIQUE PRIMARY KEY,
          "word_search" TEXT,
          "word" TEXT,
          "meaning" TEXT,
          "description" TEXT,
          "description_search" TEXT
        )
      """);
      await db.execute('''
        CREATE TABLE $_dbListTableName (
          id INTEGER PRIMARY KEY,
          name TEXT UNIQUE
        )
      ''');
      await db.execute('''
        CREATE TABLE Entries (
          word_id INTEGER,
          list_id INTEGER
        )
      ''');

      final batch = db.batch();

      for (var word in sharableData[_dbWordTableName]!) {
        batch.insert(_dbWordTableName, word);
      }
      for (var list in sharableData[_dbListTableName]!) {
        batch.insert(_dbListTableName, list);
      }
      for (var entry in sharableData[_dbEntryTableName]!) {
        batch.insert(_dbEntryTableName, entry);
      }

      await batch.commit();
    });

    cacheDb.close();
    return cacheDbFile;
  }

  static Future<List<String>> importLists(bool willCopyNewMeanings, bool willExtendExistingLists) async {
    final String cacheDbPath = path.join(_applicationDirectory.path, _cacheDbName);
    final cacheDbFile = io.File(cacheDbPath);
    final cacheDb = await openDatabase(cacheDbPath);

    final cacheDbData = await cacheDb.transaction((txn) async {
      final listData = await txn.query(_dbListTableName);
      final wordData = await txn.query(_dbWordTableName);
      final entryData = await txn.query(_dbEntryTableName);

      return {
        "listData": List.of(listData.map((e) => Map.of(e))),
        "wordData": List.of(wordData.map((e) => Map.of(e))),
        "entryData": List.of(entryData.map((e) => Map.of(e))),
      };
    });
    cacheDb.close();
    cacheDbFile.delete();

    int listIndex = 0;
    final extendedExistingList = [];
    for (var list in cacheDbData["listData"]!) {
      final listIdInDbFile = list["id"] as int;
      final listName = list["name"] as String;
      final listData = await getListData(listName);
      final doesListExist = listData != null;

      int listId;
      if (doesListExist && willExtendExistingLists) {
        listId = listData["id"] as int;
        extendedExistingList.add(listData["name"]);
      } else {
        final newListName = "${doesListExist ? "_" : ""}$listName";
        listId = await createList(newListName);
        cacheDbData["listData"]![listIndex]["name"] = newListName;
      }

      for (int index = 0; index < cacheDbData["entryData"]!.length; index++) {
        if (cacheDbData["entryData"]![index]["list_id"] == listIdInDbFile) {
          cacheDbData["entryData"]![index].update("list_id", (value) => listId);
        }
      }
      listIndex++;
    }

    for (var word in cacheDbData["wordData"]!) {
      final wordIdInDbFile = word["id"] as int;
      final wordData = await getWordData(word["word"] as String);
      final doesWordExist = wordData != null;
      word.remove("id");

      int wordId;
      if (doesWordExist) {
        wordId = wordData["id"] as int;
        if (willCopyNewMeanings) await updateWord(wordId, word);
      } else {
        wordId = await createWord(word);
      }

      for (int index = 0; index < cacheDbData["entryData"]!.length; index++) {
        if (cacheDbData["entryData"]![index]["word_id"] == wordIdInDbFile) {
          cacheDbData["entryData"]![index].update("word_id", (value) => wordId);
        }
      }
    }

    await _db.transaction((txn) async {
      final batch = txn.batch();

      for (var entry in cacheDbData["entryData"]!) {
        final query = await txn.rawQuery('''
          SELECT * FROM $_dbEntryTableName
          WHERE word_id = ${entry["word_id"]}
            AND list_id = ${entry["list_id"]}
        ''');
        final doesEntryExist = query.isNotEmpty;
        if (doesEntryExist) continue;

        final timeCreated = DateTime.now().toString().split(".")[0];
        batch.rawInsert('''
        INSERT INTO $_dbEntryTableName (word_id, list_id, time_created)
        VALUES (${entry["word_id"]}, ${entry["list_id"]}, '$timeCreated')
      ''');
      }

      await batch.commit();
    });

    return cacheDbData["listData"]!.map((e) => e["name"] as String).toList()
      ..removeWhere((list) => extendedExistingList.contains(list));
  }

  static Future<void> exportDBFile() async {
    final isPermitted = await CRFileSaver.requestWriteExternalStoragePermission();
    debugPrint("isPermitted: $isPermitted");
    if (isPermitted) {
      String dbPath = path.join(_applicationDirectory.path, _dbName);
      final timeCreated = DateTime.now().toString().split(".")[0];
      final result = await CRFileSaver.saveFileWithDialog(SaveFileDialogParams(
        sourceFilePath: dbPath,
        destinationFileName: "$timeCreated.db",
      ));
      debugPrint(result);
    }
  }

  static Future<void> execTempOperation({required FutureOr Function(Database) action}) async {
    _applicationDirectory = (await getApplicationDocumentsDirectory()).absolute;
    String dbPath = path.join(_applicationDirectory.path, _dbName);

    await openDatabase(dbPath).then((db) async {
      await db.execute("PRAGMA foreign_keys = ON");
      await action(db);
    });
  }
}

abstract final class DbKeys {
  static const String firstTabIndex = "firstTabIndex";
  static const String wordLearnListLength = "wordLearnListLength";
  static const String otherModsListLength = "otherModsListLength";
  static const String isAnimatable = "isAnimatable";
  static const String darkMode = "darkMode";
  static const String notifications = "notifications";
  static const String notificationTime = "notificationTime";
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
    if (!_db.containsKey(DbKeys.notifications)) setNotifications(false);
    if (!_db.containsKey(DbKeys.notificationTime)) setNotificationTime("12:00");
  }

  static int getFirstTabIndex() => _db.getInt(DbKeys.firstTabIndex)!;
  static void setFirstTabIndex(int value) => _db.setInt(DbKeys.firstTabIndex, value);

  static int getWordLearnListLength() => _db.getInt(DbKeys.wordLearnListLength)!;
  static void setWordLearnListLength(int value) => _db.setInt(DbKeys.wordLearnListLength, value);

  static int getOtherModsListLength() => _db.getInt(DbKeys.otherModsListLength)!;
  static void setOtherModsListLength(int value) => _db.setInt(DbKeys.otherModsListLength, value);

  static bool getIsAnimatable() {
    return WidgetsBinding.instance.disableAnimations ? false : _db.getBool(DbKeys.isAnimatable)!;
  }

  static Future<bool> setIsAnimatable(bool value) async {
    await _db.setBool(DbKeys.isAnimatable, value);
    return value;
  }

  static bool getDarkMode() => _db.getBool(DbKeys.darkMode)!;
  static Future<bool> setDarkMode(bool value) async {
    await _db.setBool(DbKeys.darkMode, value);
    return value;
  }

  static bool getNotifications() => _db.getBool(DbKeys.notifications)!;
  static Future<bool> setNotifications(bool value) async {
    if (value) {
      final isAllowed = await Notifications.requestPermission();
      await _db.setBool(DbKeys.notifications, isAllowed);
      return isAllowed;
    }
    await _db.setBool(DbKeys.notifications, value);
    return value;
  }

  static String getNotificationTime() => _db.getString(DbKeys.notificationTime)!;
  static void setNotificationTime(String value) => _db.setString(DbKeys.notificationTime, value);
}

abstract class FirebaseDatabase {
  static final _firestore = FirebaseFirestore.instance;
  static final _storage = FirebaseStorage.instance.ref();
  static late final io.Directory _applicationDirectory;
  static const _collectionName = "sharedLists";
  static const _dbFileName = "data.db";

  static Future<void> initDB() async {
    _applicationDirectory = (await getApplicationDocumentsDirectory()).absolute;
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }

  static Future<String> addSharedFileData(Map<String, dynamic> data) async {
    DocumentReference doc = await _firestore.collection(_collectionName).add(data);
    return doc.id;
  }

  static Future<bool> checkIfCodeExists(String importCode) async {
    final snapshot = await _firestore.collection(_collectionName).doc(importCode).get();
    return snapshot.exists;
  }

  static UploadTask uploadFile(io.File file, String exportCode) {
    final fileRef = _storage.child("$exportCode/$_dbFileName");
    return fileRef.putFile(file);
  }

  static DownloadTask downloadFile(String importCode) {
    final fileRef = _storage.child("$importCode/$_dbFileName");
    final String cacheDbPath = path.join(_applicationDirectory.path, _dbFileName);
    final cacheDbFile = io.File(cacheDbPath);
    return fileRef.writeToFile(cacheDbFile);
  }
}
