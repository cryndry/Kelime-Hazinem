import 'dart:async';
import 'package:kelime_hazinem/utils/database.dart';
import 'package:sqflite/sqflite.dart';

class Word {
  Word({
    required this.id,
    required this.word,
    required this.meaning,
    required this.wordSearch,
    required this.description,
    required this.descriptionSearch,
    required this.willLearn,
    required this.favorite,
    required this.learned,
    required this.memorized,
  });

  final int id;
  String wordSearch;
  String word;
  String meaning;
  String description;
  String descriptionSearch;
  int willLearn;
  int favorite;
  int learned;
  int memorized;

  factory Word.placeholder() => Word(
        id: -1,
        word: "Yükleniyor...",
        meaning: "Yükleniyor...",
        description: "Yükleniyor...",
        wordSearch: "",
        descriptionSearch: "",
        willLearn: 0,
        favorite: 0,
        learned: 0,
        memorized: 0,
      );

  factory Word.fromJson(Map<String, dynamic> json) => Word(
        id: json["id"],
        wordSearch: json["word_search"],
        word: json["word"],
        meaning: json["meaning"],
        description: json["description"],
        descriptionSearch: json["description_search"],
        willLearn: json["willLearn"] ?? 0,
        favorite: json["favorite"] ?? 0,
        learned: json["learned"] ?? 0,
        memorized: json["memorized"] ?? 0,
      );

  // unused for now
  Map<String, dynamic> toJson() => {
        "id": id,
        "word_search": wordSearch,
        "word": word,
        "meaning": meaning,
        "description": description,
        "description_search": descriptionSearch,
        "willLearn": willLearn,
        "favorite": favorite,
        "learned": learned,
        "memorized": memorized,
      };

  int intBoolInvert(int value) => (value == 1) ? 0 : 1;
  bool intAsBool(int value) => (value == 1);

  FutureOr<void> willLearnToggle({int? setValue, Database? db}) async {
    if (setValue != null) {
      if (setValue == willLearn) return;

      willLearn = setValue;
    } else {
      willLearn = intBoolInvert(willLearn);
    }
    var changes = {"willLearn": willLearn};
    if (willLearn == 1) {
      if (intAsBool(learned)) {
        learned = 0;
        changes["learned"] = 0;
      } else if (intAsBool(memorized)) {
        memorized = 0;
        changes["memorized"] = 0;
      }
    }
    await SqlDatabase.updateWord(id, changes, db);
  }

  FutureOr<void> favoriteToggle({int? setValue, Database? db}) async {
    if (setValue != null) {
      if (setValue == favorite) return;

      favorite = setValue;
    } else {
      favorite = intBoolInvert(favorite);
    }
    await SqlDatabase.updateWord(id, {"favorite": favorite}, db);
  }

  void learnedToggle() {
    learned = intBoolInvert(learned);
    var changes = {"learned": learned};
    if (learned == 1) {
      if (intAsBool(willLearn)) {
        willLearn = 0;
        changes["willLearn"] = 0;
      } else if (intAsBool(memorized)) {
        memorized = 0;
        changes["memorized"] = 0;
      }
    }
    SqlDatabase.updateWord(id, changes);
  }

  void memorizedToggle() {
    memorized = intBoolInvert(memorized);
    var changes = {"memorized": memorized};
    if (memorized == 1) {
      if (intAsBool(willLearn)) {
        willLearn = 0;
        changes["willLearn"] = 0;
      } else if (intAsBool(learned)) {
        learned = 0;
        changes["learned"] = 0;
      }
    }
    SqlDatabase.updateWord(id, changes);
  }

  @override
  String toString() => "id: $id, kelime: $word, anlam: $meaning, çoğul/mastar: $description";
}
