import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:notes/model/note/note.dart';
import 'package:notes/model/tags/tags.dart';
import 'package:notes/service/note_service.dart';
import 'package:notes/service/tag_service.dart';

final getIt = GetIt.instance;

void setupLocator(Box<Note> noteBox, Box<Tag> tagBox) {
  // Register services and boxes
  getIt.registerSingleton<Box<Note>>(noteBox);
  getIt.registerSingleton<Box<Tag>>(tagBox);

  getIt.registerSingleton<NoteService>(NoteService(noteBox));
  getIt.registerSingleton<TagService>(TagService(tagBox));
}
