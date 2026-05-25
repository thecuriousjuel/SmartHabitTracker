import 'dart:io';
import 'package:file_picker/file_picker.dart';

Future<void> saveBackupFile(String jsonContent) async {
  final path = await FilePicker.platform.saveFile(
    dialogTitle: 'Save Backup',
    fileName: 'smart_habits_backup.json',
  );
  if (path != null) {
    var finalPath = path;
    if (!finalPath.toLowerCase().endsWith('.json')) {
      finalPath = '$finalPath.json';
    }
    final file = File(finalPath);
    await file.writeAsString(jsonContent);
  }
}

Future<String?> pickAndReadBackupFile() async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.any,
  );
  if (result != null && result.files.isNotEmpty) {
    final file = result.files.first;
    if (file.name.toLowerCase().endsWith('.json')) {
      final path = file.path;
      if (path != null) {
        final ioFile = File(path);
        return await ioFile.readAsString();
      }
    } else {
      throw Exception('Selected file is not a JSON backup file.');
    }
  }
  return null;
}
