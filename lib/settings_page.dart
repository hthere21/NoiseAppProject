import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
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

// Forces any text to uppercase
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

// Inside _SettingsPageState class
class _SettingsPageState extends State<SettingsPage>
    with SingleTickerProviderStateMixin {
  late TabController controller;
  final studyIdController = TextEditingController(text: studyId);
  final firstNameController = TextEditingController(text: firstName);
  final lastNameController = TextEditingController(text: lastName);

  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    controller = TabController(length: 2, vsync: this);

    // Add the listener to dismiss the keyboard when tab index changes
    controller.addListener(() {
      _focusNode.unfocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    studyIdController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    controller.dispose();
    super.dispose();
  }

  // User signs out of the app
  Future<void> _signOut(context) async {
    final result = await Amplify.Auth.signOut(
      options: const SignOutOptions(globalSignOut: true),
    );

    if (result is CognitoCompleteSignOut) {
      // safePrint('Signed out');

      setState(() {
        // Reset all data
        prevDataLoaded = false;
        cacheLoaded = false;
        cache = {};
        studyId = "UNDEFINED";
        userId = "";
        firstName = "";
        lastName = "";
        data.clear();
      });

      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => const MyApp()));
    }
  }

  // Show popup dialog that saving studyId confirmed
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
        title: const Text(""),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          // Dismiss the keyboard when tapping outside of the text field
          FocusScope.of(context).unfocus();
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Fake CircleAvatar
                CircleAvatar(
                  radius: 60, // Adjust the radius as needed
                  backgroundColor: Colors.grey, // Set the background color
                  child: Icon(
                    Icons.person,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16), // Adjust the spacing as needed
                TextField(
                  controller: firstNameController,
                  enabled: false,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'First Name',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: lastNameController,
                  enabled: false,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Last Name',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  inputFormatters: [
                    UpperCaseTextFormatter(),
                    FilteringTextInputFormatter.allow(RegExp("[0-9a-zA-Z]")),
                  ],
                  controller: studyIdController,
                  focusNode: _focusNode,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Study ID',
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "For Study ID - Only alphanumeric characters are allowed.",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 16),
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
                  style: ElevatedButton.styleFrom(
                    primary: Colors.green, // Set button color to red
                  ),
                  child: const Text(
                    "Save Study ID",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Sign out and dismiss keyboard
                    // Amplify.Auth.signOut();

                    FocusScope.of(context).unfocus();
                    _signOut(context);
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red, // Set button color to red
                  ),
                  child: const Text(
                    "Log Out",
                    style: TextStyle(
                        color: Colors.white), // Set text color to white
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
