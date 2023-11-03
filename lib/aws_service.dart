// import 'package:flutter/material.dart';
// import 'package:amplify_flutter/amplify.dart';
// import 'package:amplify_storage_s3/amplify_storage_s3.dart';

// class AwsService {
//   // Initialize and configure Amplify (move Amplify setup here)

//   Future<void> handleUpload(dynamic itemToUpload) async {
//     final result = await Amplify.Storage.uploadFile(
//       key: 'your/s3/bucket/key/$itemToUpload',
//       local: itemToUpload,
//     );

//     if (result.isComplete) {
//       print('File uploaded successfully.');
//     } else {
//       print('Upload failed: ${result.error}');
//     }
//   }
// }
