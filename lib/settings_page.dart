import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_noise_app_117/local_storage.dart';
import 'main.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final studyIdController = TextEditingController(text: studyId);

  Future<void> _signOut(context) async {
    final result = await Amplify.Auth.signOut(
      options: const SignOutOptions(globalSignOut: true),
    );

    if (result is CognitoCompleteSignOut) {
      safePrint('Signed out');
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => const MyApp()));
    }
  }

  @override
  void dispose() {
    studyIdController.dispose();
    super.dispose();
  }

  void _showSaveConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Save Confirmed'),
          content: const Text('Successfully Changed StudyId!'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Close the AlertDialog
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: GestureDetector(
        onTap: () {
          // Dismiss the keyboard when tapping outside of the text field
          FocusScope.of(context).unfocus();
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: studyIdController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Study ID',
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // Save Study ID and dismiss keyboard
                  writeCacheOfUser("studyId", studyIdController.text);
                  setState(() {
                    studyId = studyIdController.text;
                    cache['studyId'] = studyId;
                  });
                  FocusScope.of(context).unfocus();
                  _showSaveConfirmation(context);
                },
                child: const Text("Save"),
              ),
              ElevatedButton(
                onPressed: () {
                  // Sign out and dismiss keyboard
                  Amplify.Auth.signOut();
                  FocusScope.of(context).unfocus();
                },
                child: const Text("Log Out"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
