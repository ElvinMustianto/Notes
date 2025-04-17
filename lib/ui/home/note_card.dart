import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:notes/model/note/note.dart';

typedef NoteCallback = void Function(Note note);

class NoteCard extends StatelessWidget {
  final Note note;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback onLongPress;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final ValueChanged<bool?>? onCheckboxChanged;
  final String plainText;

  const NoteCard({
    super.key,
    required this.note,
    required this.plainText,
    required this.isSelected,
    required this.isSelectionMode,
    required this.onLongPress,
    required this.onTap,
    required this.onDelete,
    required this.onCheckboxChanged,
  });

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy • HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      onTap: onTap,
      child: Stack(
        children: [
          Slidable(
            key: ValueKey(note.id),
            startActionPane: ActionPane(
              motion: const DrawerMotion(),
              extentRatio: 0.50,
              children: [
                SlidableAction(
                  onPressed: (_) => onDelete(),
                  icon: Icons.delete,
                  backgroundColor: Colors.redAccent,
                  label: 'Hapus',
                ),
              ],
            ),
            child: Card(
              elevation: 6,
              shadowColor: Colors.black26,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: isSelected ? Colors.deepPurple[100] : Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        color: Colors.deepPurple.withOpacity(0.1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            note.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Oswald',
                              color: Colors.deepPurple,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            plainText,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'Oswald',
                              color: Colors.black87,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                    const Divider(height: 1, color: Colors.black12),
                    Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
                            child: Wrap(
                              spacing: 6,
                              children: note.tags.map((tag) {
                                return Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: tag.color,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.fromLTRB(10, 0, 0, 6),
                          child: Text(
                            _formatDate(note.createdAt),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
              ),
            ),
          ),
          if (isSelectionMode)
            Positioned(
              right: 8,
              top: 8,
              child: Checkbox(
                value: isSelected,
                onChanged: onCheckboxChanged,
              ),
            ),
        ],
      ),
    );
  }
}
