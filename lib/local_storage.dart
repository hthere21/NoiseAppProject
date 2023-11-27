import 'dart:collection';
import 'dart:math';
import 'dart:async';
import 'dart:core';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

const String cacheFileName = "user.json";

Future<String> get localPath async {
  final directory = await getApplicationDocumentsDirectory();
  print(directory.path);
  return directory.path;
}

Future<File> getLocalFile(String fileName) async {
  final path = await localPath;
  return File('$path/$fileName');
}

Future<File> writeContent(String fileName, String data) async {
  final file = await getLocalFile(fileName);
  // Write the file
  return file.writeAsString(data);
}

// Stores misc information about user's actions (ex: studyid, what files were uploaded) 
Future<File> writeCacheOfUser(String name, String value) async {
  final path = await getLocalFile(cacheFileName);
  Map<String, dynamic> jsonResponse = {};

  if (await path.exists())
  {
    String contents = await path.readAsString();
    jsonResponse = jsonDecode(contents) as Map<String, dynamic>;
  }

  jsonResponse[name] = value;
  return path.writeAsString(json.encode(jsonResponse));
}

// Stores misc information about user's actions (ex: studyid, what files were uploaded) 
Future<File> writeCacheOfUserUpload(String fileName) async {
  final path = await getLocalFile(cacheFileName);
  Map<String, dynamic> jsonResponse = {};

  if (await path.exists())
  {
    String contents = await path.readAsString();
    jsonResponse = jsonDecode(contents) as Map<String, dynamic>;
  }

  jsonResponse[fileName] = true;
  return path.writeAsString(json.encode(jsonResponse));
}

// Stores misc information about user's actions (ex: studyid, what files were uploaded) 
Future<File> deleteCacheOfUserUpload(String fileName) async {
  final path = await getLocalFile(cacheFileName);
  Map<String, dynamic> jsonResponse = {};

  if (await path.exists())
  {
    String contents = await path.readAsString();
    jsonResponse = jsonDecode(contents) as Map<String, dynamic>;
    jsonResponse.removeWhere((key, value) => key == fileName);
  }

  return path.writeAsString(json.encode(jsonResponse));

}


// Reads misc information about user's actions
Future<Map<String,dynamic>> readCacheOfUser() async {
  final path = await getLocalFile(cacheFileName);
  if ((await path.exists()) == false)
  {
    Map<String,dynamic> jsonResponse = {"studyId": "UNDEFINED"}; 
    return jsonResponse;
  }
  else
  {
    String contents = await path.readAsString();
    Map<String,dynamic> jsonResponse = jsonDecode(contents) as Map<String, dynamic>;
    return jsonResponse;
  }
}

Future<void> deleteContent(String fileName) async {
  String path = await localPath;
  try {
    final file = File('$path/$fileName');
    await file.delete();
  } catch (e) {
    rethrow;
  }

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