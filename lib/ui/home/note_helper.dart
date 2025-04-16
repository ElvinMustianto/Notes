import 'dart:convert';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';

String getPlainText(String jsonText) {
  try {
    final delta = Delta.fromJson(jsonDecode(jsonText));
    final doc = Document.fromDelta(delta);
    return doc.toPlainText().trim();
  } catch (e) {
    return '';
  }
}
