import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:notes/model/note.dart';
import 'package:notes/service/note_service.dart';
import 'package:notes/utils/injection.dart';

class EditorPage extends StatefulWidget {
  final Note? note;

  const EditorPage({super.key, this.note});

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  QuillController _controller = QuillController.basic();
  final TextEditingController _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _controller = QuillController(
        document: Document.fromJson(jsonDecode(widget.note!.text)),
        selection: const TextSelection.collapsed(offset: 0),
      );
    } else {
      _controller = QuillController.basic();
    }
  }

  void _saveNote() {
    final title = _titleController.text.trim();
    final content = jsonEncode(_controller.document.toDelta().toJson());

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul tidak boleh kosong')),
      );
      return;
    }

    final noteService = getIt<NoteService>();

    if (widget.note != null) {
      final isTitleChanged = widget.note!.title != title;
      final isContentChanged = widget.note!.text != content;

      if (!isTitleChanged && !isContentChanged) {
        Navigator.pop(context); // tidak ada perubahan, cukup keluar
        return;
      }

      final updatedNote = widget.note!.copyWith(
        title: title,
        text: content,
      );

      noteService.updateNote(updatedNote.id, updatedNote);
    } else {
      final note = Note(
        id: noteService.getNextId(),
        title: title,
        text: content,
        createdAt: DateTime.now(),
      );
      noteService.addNote(note);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Colors.deepPurpleAccent;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Editor Catatan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Colors.white),
            tooltip: 'Simpan Catatan',
            onPressed: _saveNote,
          ),
        ],
      ),
      body: WillPopScope(
        onWillPop: () async {
          final title = _titleController.text.trim();
          final content = jsonEncode(_controller.document.toDelta().toJson());

          if (widget.note != null) {
            final isTitleChanged = widget.note!.title != title;
            final isContentChanged = widget.note!.text != content;

            if (isTitleChanged || isContentChanged) {
              _saveNote(); // Simpan otomatis jika ada perubahan
            }
          } else {
            if (title.isNotEmpty) {
              _saveNote(); // Simpan catatan baru jika ada judul
            }
          }
          return true;
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: QuillSimpleToolbar(
                controller: _controller,
                config: QuillSimpleToolbarConfig(
                  showColorButton: false,
                  showBackgroundColorButton: false,
                  showHeaderStyle: true,
                  multiRowsDisplay: false,
                  toolbarIconAlignment: WrapAlignment.start,
                  toolbarSize: 40,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
              child: TextField(
                controller: _titleController,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  hintText: 'Judul catatan...',
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.title),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: themeColor, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
                child: Card(
                  elevation: 2,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: QuillEditor.basic(
                      controller: _controller,
                      config: const QuillEditorConfig(
                        placeholder: 'Tulis isi catatan di sini...',
                        expands: true,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
