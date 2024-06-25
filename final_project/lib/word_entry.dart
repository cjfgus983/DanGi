import 'package:hive/hive.dart';

part 'word_entry.g.dart';

// WordEntry 구조체 생성
@HiveType(typeId: 0)
class WordEntry extends HiveObject {
  @HiveField(0)
  String word;

  @HiveField(1)
  String meaning;

  @HiveField(2)
  DateTime date;

  WordEntry({
    required this.word,
    required this.meaning,
    required this.date,
  });
}
