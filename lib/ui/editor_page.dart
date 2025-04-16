import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:hive/hive.dart';
import 'package:notes/model/note/note.dart';
import 'package:notes/model/tags/tags.dart';
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
  final Box<Tag> tagBox = Hive.box<Tag>('tags');
  final Set<String> _selectedTags = {};

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _controller = QuillController(
        document: Document.fromJson(jsonDecode(widget.note!.text)),
        selection: const TextSelection.collapsed(offset: 0),
      );
      _selectedTags.addAll(widget.note!.tags);
    } else {
      _controller = QuillController.basic();
    }
  }

  void _toggleTag(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
    });
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
      final isTagChanged = !_setEquals(widget.note!.tags.toSet(), _selectedTags);

      if (!isTitleChanged && !isContentChanged && !isTagChanged) {
        Navigator.pop(context);
        return;
      }

      final updatedNote = widget.note!.copyWith(
        title: title,
        text: content,
        tags: _selectedTags.toList(),
      );

      noteService.updateNote(updatedNote.id, updatedNote);
    } else {
      final note = Note(
        id: noteService.getNextId(),
        title: title,
        text: content,
        createdAt: DateTime.now(),
        tags: _selectedTags.toList(),
      );
      noteService.addNote(note);
    }

    Navigator.pop(context);
  }

  bool _setEquals(Set a, Set b) {
    return a.length == b.length && a.containsAll(b);
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Colors.deepPurpleAccent;
    final tags = tagBox.values.toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Editor Catatan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
          _saveNote();
          return true;
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: QuillSimpleToolbar(
                controller: _controller,
                config: QuillSimpleToolbarConfig(
                  showColorButton: true,
                  showBackgroundColorButton: true,
                  showHeaderStyle: true,
                  multiRowsDisplay: false,
                  toolbarIconAlignment: WrapAlignment.start,
                  toolbarSize: 40,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
              child: TextField(
                controller: _titleController,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  hintText: 'Judul catatan...',
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.title),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: themeColor, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            if (tags.isNotEmpty)
              SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: tags.map((tag) {
                    final isSelected = _selectedTags.contains(tag.name);
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(tag.name),
                        selected: isSelected,
                        onSelected: (_) => _toggleTag(tag.name),
                        backgroundColor: tag.color.withOpacity(0.2),
                        selectedColor: tag.color,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
                child: Card(
                  elevation: 2,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
