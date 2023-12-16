# flutter_noise_apps_117

A new Flutter project.

## Getting Started

Flutter Noise App
Overview
The Flutter Noise App is a mobile application built using the Flutter framework for both iOS and Android platforms. This app is designed to facilitate the recording and management of noise-related data for various studies. Users can navigate through different tabs to access features such as Home, Data Storage, and Settings.

Features
Authentication: The app uses Amplify Auth Cognito for user authentication, allowing users to sign up and sign in securely.

Data Recording: Users can record noise-related data, which is stored and managed within the app.

Data Storage: The app includes a Data tab where users can view and manage their recorded noise-related data.

Settings: The Settings tab provides users with customization options and app preferences.

Global Variables
The app utilizes global variables to store and manage data efficiently:

cache: A map to store the current study ID and information about files already uploaded.
studyId: A string to identify the current study ID for data uploads.
userId: A string representing the email address of the current user.
cacheFileName: The file used to store the cache of study ID and uploaded files.
cacheLastLoginFileName: The file storing the last login timestamp of the user.
firstName and lastName: Strings representing the user's first and last names.
data: A list of DataItem objects to store all rows of data shown in the app.
AWS Amplify Integration
The app integrates with AWS Amplify to connect to AWS services. The _configureAmplify function sets up the connection to AWS, configuring Amplify with the necessary plugins, such as Amplify Auth Cognito and Amplify Storage S3.

Getting Started
Clone the repository.
Install Flutter and Dart.
Run flutter pub get to install dependencies.
Configure Amplify by updating the amplifyconfiguration.dart file with your AWS Amplify settings.
Run the app using flutter run.
Acknowledgments
This app was created to streamline noise-related data recording and management for various studies. Special thanks to the Flutter and AWS Amplify communities for their support and resources.

License
This project is licensed under the Noise App Group License - see the LICENSE file for details.
