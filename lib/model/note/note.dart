import 'package:hive/hive.dart';
import 'package:notes/model/tags/tags.dart';

part 'note.g.dart';

@HiveType(typeId: 0)
class Note extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String text;

  @HiveField(3)
  final List<Tag> tags;

  @HiveField(4)
  final DateTime createdAt;

  Note({
    required this.id,
    required this.title,
    required this.text,
    this.tags = const [],
    required this.createdAt,
  });

  // Tambahkan ini:
  Note copyWith({
    int? id,
    String? title,
    String? text,
    List<Tag>? tags,
    DateTime? createdAt,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      text: text ?? this.text,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

