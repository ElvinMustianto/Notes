import 'package:hive/hive.dart';

import '../model/note/note.dart';

class NoteService {
  final Box<Note> _noteBox;

  NoteService(this._noteBox);

  List<Note> getAllNotes() {
    return _noteBox.values.toList();
  }

  void updateNote(int id, Note note) {
    _noteBox.put(id, note); // pakai id sebagai key, langsung update
  }

  void deleteNote(int id) {
    _noteBox.delete(id); // langsung delete pakai key
  }

  void addNote(Note note) {
    _noteBox.put(note.id, note); // simpan pakai note.id sebagai key
  }

  int getNextId() {
    final keys = _noteBox.keys.cast<int>();
    return keys.isEmpty ? 1 : keys.reduce((a, b) => a > b ? a : b) + 1;
  }
}
