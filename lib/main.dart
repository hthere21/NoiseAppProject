import 'package:flutter/material.dart';
import 'home_page.dart'; // Import the home_page.dart file
import 'data_page.dart';
import 'settings_page.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'amplifyconfiguration.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';

// Tracks if all data when app starts is loaded
bool prevDataLoaded = false;
bool cacheLoaded = false;
bool dataSetup = false;

// Global variables that will be changed throughout the app
Map<String, dynamic> cache = {}; // Cache for storing current studyId and what files have been already uploaded
String studyId = "UNDEFINED"; // StudyId to send any uploaded data to
String userId = ""; // email from current user
const String cacheFileName = "user.json"; // File to store cache of studyId and files already uploaded
const String cacheLastLoginFileName = "lastLogin.json"; // Stores the last login of user
String firstName = ""; // User's first name
String lastName = ""; // User's last name

// All rows of data to be shown. Keeps track of any additions of recordings
List<DataItem> data = [];

// Setsup connection to AWS
Future<void> _configureAmplify() async {
  try {
    final auth = AmplifyAuthCognito();
    final storage = AmplifyStorageS3();
    await Amplify.addPlugins([auth, storage]);

    // call Amplify.configure to use the initialized categories in your app
    await Amplify.configure(amplifyconfig);
  } on Exception catch (e) {
    safePrint('An error occurred configuring Amplify: $e');
  }
}

// Starts the app
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _configureAmplify();
  runApp(MyApp());
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
  }

  @override
  Widget build(BuildContext context) {
    return Authenticator(
      signUpForm: SignUpForm.custom(fields: [
        SignUpFormField.username(),
        SignUpFormField.password(),
        SignUpFormField.passwordConfirmation(),
        SignUpFormField.name(),
        SignUpFormField.familyName()
      ]),
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
                      const Text(
                          "Please wait for the owners to confirm the sign up."),
                      ElevatedButton(
                          onPressed: () => state.changeStep(
                                AuthenticatorStep.signIn,
                              ),
                          child: const Text('Return To Sign In'))
                    ],
                  ),
                ));
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
              // controller: tabController,
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
