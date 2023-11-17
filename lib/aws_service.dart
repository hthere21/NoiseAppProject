import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
// import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:file_picker/file_picker.dart';
// import 'amplifyconfiguration.dart';

import 'dart:io' as io;
import 'package:aws_common/vm.dart';
import 'local_storage.dart';

class AwsS3Service {
  // Future<void> handleUpload(String key, String localFilePath) async {
  //   try {
  //     final result = await Amplify.Storage.uploadFile(
  //       key: key,
  //       local: localFilePath,
  //     );
  //     if (result.isComplete) {
  //       print('File uploaded successfully.');
  //     } else {
  //       print('Upload failed: ${result.error}');
  //     }
  //   } catch (e) {
  //     print('Error uploading file: $e');
  //   }
  // }
//   Future<void> uploadIOFile(String file) async {
//     final awsFile = AWSFile.fromPath(file);
//     try {
//       final uploadResult = await Amplify.Storage.uploadFile(
//         localFile: awsFile,
//         key: 'images/file.jpg',
//       ).result;
//       safePrint('Uploaded file: ${uploadResult.uploadedItem.key}');
//     } on StorageException catch (e) {
//       safePrint('Error uploading file: ${e.message}');
//       rethrow;
//     }
//   }
// }

  Future<void> uploadCSVFile(io.File csvFile, String studyId) async {
    final awsFile = AWSFilePlatform.fromFile(csvFile);
    try {
      final uploadResult = await Amplify.Storage.uploadFile(
        localFile: awsFile, 
        key: '$studyId/${csvFile.path.split('/').last}'
      ).result;
      safePrint('Uploaded file: ${uploadResult.uploadedItem.key}');
    } on StorageException catch (e) {
      safePrint('Error uploading file: ${e.message}');
      rethrow;
    }
  }

  Future<void> uploadImage() async {
    // Select a file from the device
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      withData: false,
      // Ensure to get file stream for better performance
      withReadStream: true,
      allowedExtensions: ['jpg', 'png', 'gif'],
    );

    if (result == null) {
      safePrint('No file selected');
      return;
    }

    // Upload file with its filename as the key
    final platformFile = result.files.single;
    try {
      final result = await Amplify.Storage.uploadFile(
        localFile: AWSFile.fromStream(
          platformFile.readStream!,
          size: platformFile.size,
        ),
        key: platformFile.name,
        onProgress: (progress) {
          safePrint('Fraction completed: ${progress.fractionCompleted}');
        },
      ).result;
      safePrint('Successfully uploaded file: ${result.uploadedItem.key}');
    } on StorageException catch (e) {
      safePrint('Error uploading file: $e');
      rethrow;
    }
  }

  Future<String> getUserId() async {
    try {
      final attributes = await Amplify.Auth.fetchUserAttributes();
      // Represents the email as the userid
      return attributes[2].value;
    } catch (e) {
      print("Error fetching user email: $e");
      rethrow;
    }
  }

}
// Code from the aws flutter setup example below
// Future<void> _configureAmplify() async {
//   await Amplify.addPlugins([
//     AmplifyAuthCognito(),
//     AmplifyAPI(modelProvider: ModelProvider.instance),
//   ]);
//   await Amplify.configure(amplifyconfig);
// }
