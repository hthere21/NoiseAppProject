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
    try {
      final awsFile = AWSFilePlatform.fromFile(csvFile);
      String userId = await getUserId();
    
      final uploadResult = await Amplify.Storage.uploadFile(
        localFile: awsFile, 
        key: 'studyid=$studyId/userid=$userId/${csvFile.path.split('/').last}'
      ).result;
      print('Uploaded file: ${uploadResult.uploadedItem.key}');
    } catch (e) {
      print("Error uploading CSV file: $e");
      rethrow;
    }
  }

  Future<List<AuthUserAttribute>> getUserInformation() async {
  try {
      final attributes = await Amplify.Auth.fetchUserAttributes();
      return attributes;
    } catch (e) {
      print("Error fetching user information: $e");
      rethrow;
    }
  }

  Future<String> getUserId() async {
    try {
      final attributes = await Amplify.Auth.fetchUserAttributes();
      // Represents the email as the userid
      String userid = "";
      for (AuthUserAttribute a in attributes)
      {
        if (a.userAttributeKey.key == 'email')
        {
          userid = a.value;
        }
      }
      return userid;
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
