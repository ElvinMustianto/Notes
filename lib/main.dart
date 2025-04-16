import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:notes/ui/home/home_page.dart';
import 'package:notes/utils/injection.dart';

import 'model/note.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(NoteAdapter());

  // Open the Box for storing notes
  var noteBox = await Hive.openBox<Note>('notes');

  // Set up dependency injection with the noteBox
  setupLocator(noteBox);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Notes App",
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
      // 🌍 Tambahkan localizations di sini
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FlutterQuillLocalizations.delegate, // ✅ Ini penting untuk FlutterQuill
      ],
      supportedLocales: const [
        Locale('en'), // Tambahkan 'id' kalau kamu mau bahasa Indonesia juga
        Locale('id'),
      ],
    );
  }
}
