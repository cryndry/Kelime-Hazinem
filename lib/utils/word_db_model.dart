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
  final String? wordSearch;
  final String word;
  final String meaning;
  final String? description;
  final String? descriptionSearch;
  int willLearn;
  int favorite;
  int learned;
  int memorized;

  factory Word.fromJson(Map<String, dynamic> json) => Word(
        id: json["id"],
        wordSearch: json["wordSearch"],
        word: json["word"],
        meaning: json["meaning"],
        description: json["description"],
        descriptionSearch: json["descriptionSearch"],
        willLearn: json["willLearn"],
        favorite: json["favorite"],
        learned: json["learned"],
        memorized: json["memorized"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "wordSearch": wordSearch,
        "word": word,
        "meaning": meaning,
        "description": description,
        "descriptionSearch": descriptionSearch,
        "willLearn": willLearn,
        "favorite": favorite,
        "learned": learned,
        "memorized": memorized,
      };

  @override
  String toString() => "id: $id, kelime: $word, anlam: $meaning, çoğul/mastar: $description";
}
