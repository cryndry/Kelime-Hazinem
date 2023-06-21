import 'package:kelime_hazinem/utils/word_db_model.dart';
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

    Database db = await openDatabase(dbPath);
    await db.transaction((txn) async {
      final List<Map<String, Object?>> doesDbHaveInitialColumns = await txn
          .rawQuery("SELECT COUNT(*) as isFound FROM pragma_table_info('$_dbTableName') WHERE name='willLearn';");
      if (doesDbHaveInitialColumns[0]["isFound"] == 1) return;

      await txn.execute("ALTER TABLE $_dbTableName ADD willLearn int(1) default 0;");
      await txn.execute("ALTER TABLE $_dbTableName ADD favorite int(1) default 0;");
      await txn.execute("ALTER TABLE $_dbTableName ADD learned int(1) default 0;");
      await txn.execute("ALTER TABLE $_dbTableName ADD memorized int(1) default 0;");
    });

    _db = db; // to ensure that db is used after the initialization completed with all aspects
  }

  static Future<List<Word>> getAllWords() async {
    List<Map<String, dynamic>> words = await _db.transaction((txn) async {
      final values = await txn.query(_dbTableName, columns: null);
      return values;
    });
    return words.map((word) => Word.fromJson(word)).toList();
  }
  
  static Future<List<Map<String, dynamic>>> getAllWordsJson() async {
    return await _db.transaction((txn) async {
      return await txn.query(_dbTableName, columns: null);
    });
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
}
