import 'package:hive/hive.dart';

part 'note.g.dart';

@HiveType(typeId: 0)
class Note extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String text;

  @HiveField(3)
  DateTime createdAt;

  Note({
    required this.id,
    required this.title,
    required this.text,
    required this.createdAt,
  });

  // Tambahkan ini:
  Note copyWith({
    int? id,
    String? title,
    String? text,
    DateTime? createdAt,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

