import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_noise_app_117/local_storage.dart';
import 'main.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class _SettingsPageState extends State<SettingsPage> {
  final studyIdController = TextEditingController(text: studyId);
  final firstNameController = TextEditingController(text: firstName);
  final lastNameController = TextEditingController(text: lastName);

  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    studyIdController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    super.dispose();
  }
  Future<void> _signOut(context) async {
    final result = await Amplify.Auth.signOut(
      options: const SignOutOptions(globalSignOut: true),
    );

    if (result is CognitoCompleteSignOut) {
      safePrint('Signed out');

      // Reset all data
      cacheLoaded = false;
      prevDataLoaded = false;
      firstName = "";
      lastName = "";
      studyId = "UNDEFINED";

      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const MyApp()));
    }
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
        behavior: HitTestBehavior.translucent,
        onTap: () {
          // Dismiss the keyboard when tapping outside of the text field
          FocusScope.of(context).unfocus();
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: firstNameController,
                enabled: false,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'First Name',
                ),
              ),
              const Padding(padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15)),
              TextField(
                controller: lastNameController,
                enabled: false,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Last Name',
                ),
              ),
              const Padding(padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15)),
              TextField(
                inputFormatters: [
                  UpperCaseTextFormatter(),
                  FilteringTextInputFormatter.allow(RegExp("[0-9a-zA-Z]"))
                ],
                controller: studyIdController,
                focusNode:
                    _focusNode, // Assign the focus node to the text field
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Study ID',
                ),
              ),
              const Text("For Study ID - Only alphanumeric characters are allowed."),
              const Padding(padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15)),
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
                child: const Text("Save Study ID")
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
