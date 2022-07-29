import 'package:path_provider/path_provider.dart';
import 'dart:io';

writeToFile(String text, String filename) async {
  dynamic directory =Platform.isAndroid  ? await getExternalStorageDirectory() : await getApplicationDocumentsDirectory();
  // File file = File('${directory.path}/' + filename);
  // await file.writeAsString(text);
  File('${directory.path}/'+filename).create(recursive: true)
      .then((File file) async {
    await file.writeAsString(text);
  });
}

Future<String> readFile(String filename) async {
  String text = '';
  try {
    final dynamic directory = Platform.isAndroid  ? await getExternalStorageDirectory() : await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/' + filename);
    text = await file.readAsString();
  } catch (e) {
    print("Couldn't read file");
    print(e);

  }
  return text;
}
