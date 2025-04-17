import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:notes/model/note/note.dart';
import 'package:notes/model/tags/tags.dart';
import 'package:notes/service/note_service.dart';
import 'package:notes/ui/editor_page.dart';
import 'package:notes/ui/home/note_card.dart';
import 'package:notes/ui/tags/tag_management_page.dart';
import 'package:notes/utils/injection.dart';
import 'note_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final noteService = getIt<NoteService>();
  List<Note> notes = [];
  List<Note> filteredNotes = [];
  bool isSelectionMode = false;
  Set<int> selectedNoteIds = {};
  bool isSearching = false;
  final TextEditingController searchController = TextEditingController();
  Timer? _debounce;
  String? selectedTagFilter;

  @override
  void initState() {
    super.initState();
    notes = noteService.getAllNotes();
    filteredNotes = notes;
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final keyword = searchController.text.toLowerCase();
      setState(() {
        filteredNotes = notes.where((note) {
          final plainText = getPlainText(note.text).toLowerCase();
          return note.title.toLowerCase().contains(keyword) ||
              plainText.contains(keyword);
        }).toList();
      });
    });
  }

  void refreshNotes() {
    print("Selected tag filter: $selectedTagFilter");

    List<Note> updatedNotes = noteService.getAllNotes();

    // Filter catatan berdasarkan tag
    if (selectedTagFilter != null) {
      updatedNotes = updatedNotes.where((note) {
        // Pastikan tag name cocok dengan filter yang dipilih
        return note.tags.any((tag) => tag.name == selectedTagFilter);
      }).toList();
    }

    final keyword = searchController.text.toLowerCase();
    updatedNotes = updatedNotes.where((note) {
      final plainText = getPlainText(note.text).toLowerCase();
      return note.title.toLowerCase().contains(keyword) || plainText.contains(keyword);
    }).toList();

    setState(() {
      filteredNotes = updatedNotes;
    });
    print("Filtered notes: ${filteredNotes.length}");
  }

  void toggleSelectionMode(bool enabled) {
    setState(() {
      isSelectionMode = enabled;
      if (!enabled) selectedNoteIds.clear();
    });
  }

  void toggleNoteSelection(int id) {
    setState(() {
      if (selectedNoteIds.contains(id)) {
        selectedNoteIds.remove(id);
        if (selectedNoteIds.isEmpty) isSelectionMode = false;
      } else {
        selectedNoteIds.add(id);
      }
    });
  }

  void deleteSelectedNotes() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Apakah Anda yakin ingin menghapus ${selectedNoteIds.length} catatan?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              for (var id in selectedNoteIds) {
                noteService.deleteNote(id);
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${selectedNoteIds.length} catatan dihapus'),
                  duration: const Duration(seconds: 2),
                ),
              );
              setState(() {
                selectedNoteIds.clear();
                isSelectionMode = false;
                refreshNotes();
              });
              Navigator.of(context).pop();
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final tagBox = Hive.box<Tag>('tags');

    return Scaffold(
      appBar: AppBar(
        title: isSearching
            ? TextField(
          controller: searchController,
          autofocus: true,
          style: const TextStyle(color: Colors.white, fontFamily: 'Oswald'),
          decoration: const InputDecoration(
            hintText: 'Cari catatan...',
            hintStyle: TextStyle(color: Colors.white54),
            border: InputBorder.none,
          ),
        )
            : Text(
          isSelectionMode ? '${selectedNoteIds.length} Dipilih' : 'CATATAN',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 24,
            fontFamily: 'Oswald',
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurpleAccent,
        actions: [
          if (!isSelectionMode) ...[
            IconButton(
              icon: Icon(
                isSearching ? Icons.close : Icons.search,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  if (isSearching) {
                    searchController.clear();
                  }
                  isSearching = !isSearching;
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.label, color: Colors.white),
              tooltip: 'Kelola Tag',
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TagManagementPage()),
                );
                setState(() {
                  refreshNotes();
                });
              },
            ),
          ],
          if (isSelectionMode)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: deleteSelectedNotes,
            ),
        ],
      ),
      floatingActionButton: isSelectionMode
          ? FloatingActionButton(
        backgroundColor: Colors.grey,
        onPressed: () => toggleSelectionMode(false),
        child: const Icon(Icons.close, color: Colors.white),
      )
          : FloatingActionButton(
        backgroundColor: Colors.deepPurpleAccent,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EditorPage()),
          );
          setState(() {
            refreshNotes();
          });
        },
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      body: Column(
        children: [
          if (tagBox.isNotEmpty)
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: const Text('Semua'),
                      selected: selectedTagFilter == null,
                      onSelected: (_) {
                        setState(() {
                          selectedTagFilter = null;
                          refreshNotes();
                        });
                      },
                    ),
                  ),
                  ...tagBox.values.map((tag) {
                    final isSelected = selectedTagFilter == tag.name;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(tag.name),
                        selected: isSelected,
                        backgroundColor: tag.color.withOpacity(0.2),
                        selectedColor: tag.color,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                        onSelected: (_) {
                          setState(() {
                            selectedTagFilter = isSelected ? null : tag.name;
                            refreshNotes();
                          });
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
          if (filteredNotes.isEmpty)
            const Expanded(
              child: Center(
                child: Text(
                  'Belum ada catatan!',
                  style: TextStyle(fontFamily: 'Oswald', fontSize: 18),
                ),
              ),
            )
          else
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16.0),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: screenWidth > 600 ? 4 : 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: screenWidth > 600 ? 0.8 : 0.9,
                ),
                itemCount: filteredNotes.length,
                itemBuilder: (context, index) {
                  final note = filteredNotes[index];
                  final plainText = getPlainText(note.text);
                  final isSelected = selectedNoteIds.contains(note.id);

                  return NoteCard(
                    note: note,
                    plainText: plainText,
                    isSelected: isSelected,
                    isSelectionMode: isSelectionMode,
                    onLongPress: () {
                      toggleSelectionMode(true);
                      toggleNoteSelection(note.id);
                    },
                    onTap: () async {
                      if (isSelectionMode) {
                        toggleNoteSelection(note.id);
                      } else {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditorPage(note: note),
                          ),
                        );
                        setState(() {
                          refreshNotes();
                        });
                      }
                    },
                    onDelete: () {
                      setState(() {
                        noteService.deleteNote(note.id);
                        refreshNotes();
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Catatan "${note.title}" dihapus',
                            style: const TextStyle(fontFamily: 'Oswald'),
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    onCheckboxChanged: (_) {
                      toggleNoteSelection(note.id);
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
