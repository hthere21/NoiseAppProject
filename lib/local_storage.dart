import 'dart:core';
import 'dart:convert';
import 'package:flutter_noise_app_117/main.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<void> createUserDirectory() async {
  final directory = await getApplicationDocumentsDirectory();
  
  String directoryPath = '${directory.path}/$userId';
  Directory newDirectory = Directory(directoryPath);
  if (!(await newDirectory.exists())) {
    await newDirectory.create(recursive: true);
    print("Directory created: $directoryPath");
  } else {
    print("Directory already exists: $directoryPath");
  }

}

// Get directory for only storing app information
Future<String> get localPath async {
  final directory = await getApplicationDocumentsDirectory();
  String directoryPath = '${directory.path}/$userId';
  print(directoryPath);
  Directory newDirectory = Directory(directoryPath);

  if (!(await newDirectory.exists())) {
    await newDirectory.create(recursive: true);
    print("Directory created: $directoryPath");
  } else {
    print("Directory already exists: $directoryPath");
  }

  return directoryPath; 
}

// Get local file stored in the app directory
Future<File> getLocalFile(String fileName) async {
  final path = await localPath;
  return File('$path/$fileName');
}

// Writing csv files with the given data
Future<File> writeContent(String fileName, String data) async {
  final file = await getLocalFile(fileName);
  // Write the file
  return file.writeAsString(data);
}

// Stores misc information about user's actions (ex: studyid, what files were uploaded)
Future<File> writeCacheOfUser(String name, String value) async {
  final path = await getLocalFile(cacheFileName);
  Map<String, dynamic> jsonResponse = {};

  if (await path.exists()) {
    String contents = await path.readAsString();
    jsonResponse = jsonDecode(contents) as Map<String, dynamic>;
  }

  jsonResponse[name] = value;
  return await path.writeAsString(json.encode(jsonResponse));
}

// Stores misc information about user's actions (ex: studyid, what files were uploaded)
Future<File> writeCacheOfUserUpload(String fileName) async {
  final path = await getLocalFile(cacheFileName);
  Map<String, dynamic> jsonResponse = {};

  if (await path.exists()) {
    String contents = await path.readAsString();
    jsonResponse = jsonDecode(contents) as Map<String, dynamic>;
  }

  jsonResponse[fileName] = true;
  return await path.writeAsString(json.encode(jsonResponse));
}

// Stores misc information about user's actions (ex: studyid, what files were uploaded)
Future<File> writeCacheOfUserMultipleUpload(List<String> fileNames) async {
  final path = await getLocalFile(cacheFileName);
  Map<String, dynamic> jsonResponse = {};

  if (await path.exists()) {
    String contents = await path.readAsString();
    jsonResponse = jsonDecode(contents) as Map<String, dynamic>;
  }

  for (String fileName in fileNames) {
    jsonResponse[fileName] = true;
  }

  return await path.writeAsString(json.encode(jsonResponse));
}

// Stores misc information about user's actions (ex: studyid, what files were uploaded)
Future<File> deleteCacheOfUserUpload(String fileName) async {
  final path = await getLocalFile(cacheFileName);
  Map<String, dynamic> jsonResponse = {};

  if (await path.exists()) {
    String contents = await path.readAsString();
    jsonResponse = jsonDecode(contents) as Map<String, dynamic>;
    jsonResponse.removeWhere((key, value) => key == fileName);
  }

  return await path.writeAsString(json.encode(jsonResponse));
}

// Deletes information about user's actions (ex: what files were uploaded)
Future<File> deleteCacheOfUserMultipleUpload(List<String> fileNames) async {
  final path = await getLocalFile(cacheFileName);
  Map<String, dynamic> jsonResponse = {};
  print(path);
  if (await path.exists()) {
    String contents = await path.readAsString();
    jsonResponse = jsonDecode(contents) as Map<String, dynamic>;
    print("JSON");
    print(jsonResponse);

    for (String fileName in fileNames) {
      if (fileName.contains('.csv')) {
        jsonResponse.removeWhere((key, value) => key == fileName);
      }
    }
  }

  return await path.writeAsString(json.encode(jsonResponse));
}

// Reads misc information about user's actions
Future<Map<String, dynamic>> readCacheOfUser() async {
  final path = await getLocalFile(cacheFileName);
  if ((await path.exists()) == false) {
    Map<String, dynamic> jsonResponse = {"studyId": "UNDEFINED"};
    await writeCacheOfUser("studyId", studyId);
    return jsonResponse;
  } else {
    String contents = await path.readAsString();
    Map<String, dynamic> jsonResponse =
        jsonDecode(contents) as Map<String, dynamic>;
    return jsonResponse;
  }
}

// Deletes csv file
Future<void> deleteContent(String fileName) async {
  try {
    final file = await getLocalFile(fileName);
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
    if (file is File) {
      files.add(file);
    }
  }
  print("ALL FILES");
  print(files);
  return files;
}

Future<List<List<dynamic>>> readContent(File file) async {
  try {
    // Read the file
    List<List<dynamic>> contents =
        const CsvToListConverter().convert(await file.readAsString());
    // Returning the contents of the file
    return contents;
  } catch (e) {
    // If encountering an error, return
    print("ERROR");
    return [];
  }
}
