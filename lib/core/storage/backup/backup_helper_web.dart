import 'dart:convert';
import 'dart:html' as html;
import 'package:file_picker/file_picker.dart';

Future<bool> saveBackupFile(String jsonContent) async {
  final bytes = utf8.encode(jsonContent);
  final blob = html.Blob([bytes], 'application/json');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.document.createElement('a') as html.AnchorElement
    ..href = url
    ..style.display = 'none'
    ..download = 'smart_habits_backup.json';
  html.document.body?.children.add(anchor);
  anchor.click();
  html.document.body?.children.remove(anchor);
  html.Url.revokeObjectUrl(url);
  return true;
}

Future<String?> pickAndReadBackupFile() async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.any,
    withData: true,
  );
  if (result != null && result.files.isNotEmpty) {
    final file = result.files.first;
    if (file.name.toLowerCase().endsWith('.json')) {
      final bytes = file.bytes;
      if (bytes != null) {
        return utf8.decode(bytes);
      }
    } else {
      throw Exception('Selected file is not a JSON backup file.');
    }
  }
  return null;
}
