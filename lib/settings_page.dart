import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'main.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

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
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Confirmation"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(onPressed: () => {Amplify.Auth.signOut()}, 
              child: const Text("Log Out"))
            ]
          )
        )
    );
  }
}