import 'package:hive/hive.dart';
import 'package:notes/model/tags/tags.dart';

class TagService {
  final Box<Tag> _tagBox;

  TagService(this._tagBox);

  /// Ambil semua tag
  List<Tag> getAllTags() {
    return _tagBox.values.toList();
  }

  /// Tambah tag baru jika belum ada (default warna biru 800)
  Future<void> addTag(String name, {int colorValue = 0xFF1565C0}) async {
    if (!_tagBox.values.any((tag) => tag.name == name)) {
      await _tagBox.add(Tag(name: name, colorValue: colorValue));
    }
  }

  /// Hapus tag berdasarkan nama
  Future<void> deleteTag(String name) async {
    final key = _tagBox.keys.firstWhere(
          (k) => _tagBox.get(k)?.name == name,
      orElse: () => null,
    );
    if (key != null) {
      await _tagBox.delete(key);
    }
  }

  /// Ganti nama dan/atau warna tag
  Future<void> renameTag(String oldName, String newName, {int? newColorValue}) async {
    final key = _tagBox.keys.firstWhere(
          (k) => _tagBox.get(k)?.name == oldName,
      orElse: () => null,
    );

    if (key != null && !_tagBox.values.any((tag) => tag.name == newName)) {
      final oldTag = _tagBox.get(key);
      if (oldTag != null) {
        await _tagBox.put(key, Tag(
          name: newName,
          colorValue: newColorValue ?? oldTag.colorValue,
        ));
      }
    }
  }

  /// Cek apakah tag dengan nama tertentu sudah ada
  bool tagExists(String name) {
    return _tagBox.values.any((tag) => tag.name == name);
  }
}
