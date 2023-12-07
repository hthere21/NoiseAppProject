import 'package:amplify_flutter/amplify_flutter.dart';
import 'dart:io' as io;
import 'package:aws_common/vm.dart';

class AwsS3Service {
  // Upload CSV to specified studyid
  Future<void> uploadCSVFile(io.File csvFile, String studyId) async {
    try {
      final awsFile = AWSFilePlatform.fromFile(csvFile);
      String userId = await getUserId();
    
      final uploadResult = await Amplify.Storage.uploadFile(
        localFile: awsFile, 
        key: 'studyid=$studyId/userid=$userId/${csvFile.path.split('/').last}'
      ).result;
      // print('Uploaded file: ${uploadResult.uploadedItem.key}');
    } catch (e) {
      // print("Error uploading CSV file: $e");
      rethrow;
    }
  }

  // Gets the current user information
  Future<List<AuthUserAttribute>> getUserInformation() async {
  try {
      final attributes = await Amplify.Auth.fetchUserAttributes();
      return attributes;
    } catch (e) {
      // print("Error fetching user information: $e");
      rethrow;
    }
  }

  // Gets the current userId (email) 
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
      // print("Error fetching user email: $e");
      rethrow;
    }
  }
}
