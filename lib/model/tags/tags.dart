import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

part 'tags.g.dart'; // <-- Pastikan ini ada, sebagai bagian dari direktif

@HiveType(typeId: 1)
class Tag extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final int colorValue;

  Tag({required this.name, this.colorValue = 0xFF1565C0});

  Color get color => Color(colorValue);

  copyWith({
    required String name,
    required int colorValue
  }) {
    return Tag(
        name: name,
        colorValue: colorValue
    );
  }
}
