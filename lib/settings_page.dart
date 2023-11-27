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

    if (result is CognitoCompleteSignOut)
    {
      safePrint('Signed out');
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const MyApp()));

    }
  }

  @override
  void dispose() {
    studyIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Confirmation"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: studyIdController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Study ID'
                ),
              ),
              ElevatedButton(
                onPressed: () { 
                  setState(() {
                    studyId = studyIdController.text;
                  });
                  writeCacheOfUser("studyId", studyId);
                  FocusScope.of(context).unfocus();
                }, 
                child: const Text("Save")
              ),
              ElevatedButton(
                onPressed: () => {Amplify.Auth.signOut()}, 
                child: const Text("Log Out")
              )
            ]
          )
        )
    );
  }
}