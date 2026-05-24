import 'dart:io';
import 'package:file_picker/file_picker.dart';

Future<void> saveBackupFile(String jsonContent) async {
  final path = await FilePicker.platform.saveFile(
    dialogTitle: 'Save Backup',
    fileName: 'smart_habits_backup.json',
    type: FileType.custom,
    allowedExtensions: ['json'],
  );
  if (path != null) {
    final file = File(path);
    await file.writeAsString(jsonContent);
  }
}

Future<String?> pickAndReadBackupFile() async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['json'],
  );
  if (result != null && result.files.isNotEmpty) {
    final path = result.files.first.path;
    if (path != null) {
      final file = File(path);
      return await file.readAsString();
    }
  }
  return null;
}
