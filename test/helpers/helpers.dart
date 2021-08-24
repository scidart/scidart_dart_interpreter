import 'package:scidart_io/scidart_io.dart';

/// Save the SVG in a file
/// [fileName] the file name, if extension '.svg' is not informed,
/// it is added automatically
Future<void> saveTree(String dotStr, String fileName) async {
  const extension = '.dot';
  if (!fileName.toLowerCase().endsWith(extension)) {
    fileName += extension;
  }
  await writeTxt(dotStr, fileName);
}
