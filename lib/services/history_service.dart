import 'dart:io';
import 'package:path_provider/path_provider.dart';

class HistoryService {
  File? _file;

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    _file = File('${dir.path}/history.txt');
  }

  Future<List<String>> loadExisting() async {
    if (_file == null || !(await _file!.exists())) return [];
    final content = await _file!.readAsString();
    return content
        .split('\n')
        .where((l) => l.trim().isNotEmpty)
        .take(10)
        .toList();
  }

  Future<void> append(String word) async {
    if (_file == null) return;
    final timestamp = DateTime.now().toIso8601String().split('T').first;
    await _file!.writeAsString('$timestamp $word\n', mode: FileMode.append);
  }
}
