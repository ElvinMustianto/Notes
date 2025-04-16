import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:notes/service/note_service.dart';
import 'package:notes/model/note.dart';

final getIt = GetIt.instance;

void setupLocator(Box<Note> noteBox) {
  // Register NoteService with the Box<Note> instance
  getIt.registerSingleton<NoteService>(NoteService(noteBox));
}
