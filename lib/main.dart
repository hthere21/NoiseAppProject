import 'package:flutter/material.dart';
import 'home_page.dart'; // Import the home_page.dart file
import 'data_page.dart';
import 'settings_page.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';

import 'amplifyconfiguration.dart';
import 'settings_page.dart';

void main() {
  runApp(MyApp());
}

void _configureAmplify() async {
  try {
    await Amplify.addPlugin(AmplifyAuthCognito());
    await Amplify.configure(amplifyconfig);
    print('Successfully configured');
  } on Exception catch (e) {
    print('Error configuring Amplify: $e');
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _configureAmplify();
  } 

  @override
  Widget build(BuildContext context) {
    return Authenticator(
      authenticatorBuilder: (BuildContext context, AuthenticatorState state) {
        switch (state.currentStep) {
          case AuthenticatorStep.confirmSignUp:
            return Scaffold(
              appBar: AppBar(
                title: const Text("Confirmation"),
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Please wait for the owners to confirm the sign up."),
                    ElevatedButton(
                      onPressed: () => state.changeStep(
                        AuthenticatorStep.signIn,
                      ), 
                      child: const Text('Return To Sign In'))
                  ],
                ),
              )
            );
          default:
            return null;
        }
      },
      child: MaterialApp(
        builder: Authenticator.builder(),
        home: DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              title: Text('Noise App'),
              bottom: TabBar(
                tabs: [
                  Tab(text: 'Home'),
                  Tab(text: 'Data'),
                  Tab(text: 'Settings'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                HomePage(), // Use HomePage as the content for the "Home" tab
                DataStoragePage(),
                SettingsPage(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
