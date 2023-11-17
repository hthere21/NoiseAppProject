import 'dart:collection';
import 'dart:math';
import 'dart:async';
import 'dart:core';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<String> get localPath async {
  final directory = await getApplicationDocumentsDirectory();
  print(directory.path);
  return directory.path;
}

Future<File> getLocalFile(String fileName) async {
  final path = await localPath;
  return File('$path/$fileName.csv');
}

Future<File> writeContent(String fileName, String data) async {
  final file = await getLocalFile(fileName);
  // Write the file
  return file.writeAsString(data);
}

Future<List<File>> get listOfFiles async {
  Directory directory = Directory(await localPath);
  List contents = directory.listSync();
  List<File> files = [];
  for (var file in contents) {
    if (file is File)
    {
      files.add(file);
    }

  }

  print(files);

  return files;

}

Future<List<List<dynamic>>> readContent(File file) async {
  try {
    // Read the file
    List<List<dynamic>> contents = const CsvToListConverter().convert(await file.readAsString());
    // Returning the contents of the file
    return contents;
  } catch (e) {
    // If encountering an error, return
    print("ERROR");
    return [];
  }
}