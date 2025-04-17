import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ColorPickerDialog extends StatefulWidget {
  final Color initialColor;

  const ColorPickerDialog({required this.initialColor});

  @override
  State<ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
  late Color selectedColor;

  final List<Color> colors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.brown,
    Colors.pink,
    Colors.teal,
  ];

  @override
  void initState() {
    super.initState();
    selectedColor = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Pilih Warna"),
      content: Wrap(
        spacing: 8,
        children: colors.map((color) {
          return GestureDetector(
            onTap: () {
              Navigator.pop(context, color);
            },
            child: CircleAvatar(
              backgroundColor: color,
              radius: 20,
              child: selectedColor == color ? const Icon(Icons.check, color: Colors.white) : null,
            ),
          );
        }).toList(),
      ),
    );
  }
}
