import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:notes/model/tags/tags.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'color_picker.dart';

class TagManagementPage extends StatefulWidget {
  const TagManagementPage({super.key});

  @override
  State<TagManagementPage> createState() => _TagManagementPageState();
}

class _TagManagementPageState extends State<TagManagementPage> {
  late Box<Tag> tagBox;

  @override
  void initState() {
    super.initState();
    tagBox = Hive.box<Tag>('tags');
  }

  void _addTagDialog() {
    final controller = TextEditingController();
    Color selectedColor = Colors.blue;

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text("Tambah Tag Baru"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    labelText: 'Nama Tag',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Text("Warna: "),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () async {
                        final color = await showDialog<Color>(
                          context: context,
                          builder: (_) => ColorPickerDialog(initialColor: selectedColor),
                        );
                        if (color != null) {
                          setStateDialog(() => selectedColor = color);
                        }
                      },
                      child: CircleAvatar(
                        radius: 15,
                        backgroundColor: selectedColor,
                        child: const Icon(Icons.edit, size: 14, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Batal"),
              ),
              ElevatedButton(
                onPressed: () {
                  final name = controller.text.trim();
                  final alreadyExists = tagBox.values.any((tag) => tag.name == name);

                  if (name.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Nama tag tidak boleh kosong.')),
                    );
                    return;
                  }

                  if (alreadyExists) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tag sudah ada.')),
                    );
                    return;
                  }

                  final newTag = Tag(name: name, colorValue: selectedColor.value);
                  tagBox.add(newTag);
                  Navigator.pop(context);
                  setState(() {});
                },
                child: const Text("Simpan"),
              )
            ],
          );
        });
      },
    );
  }

  void _editTagDialog(int index) {
    final tag = tagBox.getAt(index)!;
    final controller = TextEditingController(text: tag.name);
    Color selectedColor = Color(tag.colorValue);

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text("Edit Tag"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    labelText: 'Nama Tag',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Text("Warna: "),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () async {
                        final color = await showDialog<Color>(
                          context: context,
                          builder: (_) => ColorPickerDialog(initialColor: selectedColor),
                        );
                        if (color != null) {
                          setStateDialog(() => selectedColor = color);
                        }
                      },
                      child: CircleAvatar(
                        radius: 15,
                        backgroundColor: selectedColor,
                        child: const Icon(Icons.edit, size: 14, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Batal"),
              ),
              ElevatedButton(
                onPressed: () {
                  final name = controller.text.trim();
                  final alreadyExists = tagBox.values
                      .where((existingTag) => existingTag != tag)
                      .any((existingTag) => existingTag.name == name);

                  if (name.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Nama tag tidak boleh kosong.')),
                    );
                    return;
                  }

                  if (alreadyExists) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tag sudah ada.')),
                    );
                    return;
                  }

                  final updatedTag = tag.copyWith(
                    name: name,
                    colorValue: selectedColor.value,
                  );
                  tagBox.putAt(index, updatedTag);
                  Navigator.pop(context);
                  setState(() {});
                },
                child: const Text("Simpan"),
              )
            ],
          );
        });
      },
    );
  }

  void _deleteTag(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Hapus Tag"),
        content: const Text("Apakah kamu yakin ingin menghapus tag ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              tagBox.deleteAt(index);
              setState(() {});
              Navigator.pop(context);
            },
            child: const Text("Hapus"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tags = tagBox.values.toList();

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Manajemen Tag", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurpleAccent,
        onPressed: _addTagDialog,
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
      body: tags.isEmpty
          ? const Center(child: Text("Belum ada tag. Tambahkan satu!"))
          : ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        itemCount: tags.length,
        itemBuilder: (context, index) {
          final tag = tags[index];
          return Slidable(
            startActionPane: ActionPane(
              motion: const ScrollMotion(),
              children: [
                SlidableAction(
                  onPressed: (_) => _editTagDialog(index),
                  backgroundColor: Colors.blue,
                  icon: Icons.edit,
                  label: 'Edit',
                ),
                SlidableAction(
                  onPressed: (_) => _deleteTag(index),
                  backgroundColor: Colors.red,
                  icon: Icons.delete,
                  label: 'Hapus',
                ),
              ],
            ),
            child: Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: tag.color,
                  child: Text(
                    tag.name.characters.first.toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(tag.name),
              ),
            ),
          );
        },
      ),
    );
  }
}
