# Flutter Noise App Project
[![My Skills](https://skillicons.dev/icons?i=flutter, dart, aws, figma)](https://skillicons.dev)
## Overview

The **Flutter Noise App** is a versatile mobile application built with the Flutter framework, offering seamless noise-related data recording and management for various studies. With a clean and intuitive interface, users can navigate through different tabs to access essential features, including Home, Data Storage, and Settings.

## Features

1. **Authentication**: Secure user authentication is facilitated through Amplify Auth Cognito, enabling users to sign up and sign in effortlessly.

2. **Data Recording**: Users can efficiently record dBA surround noise during real time. The app captures the stream of audio from the mic then using FFT to convert it into dBA values. After finish recording, user can upload or discard the recording.

3. **Data Storage**: The Data tab allows users to conveniently view and manage their recorded noise-related data, ensuring easy access and organization. User can upload the data to the AWS S3 buckets or delete it.

4. **Settings**: Customize your app experience with the Settings tab, providing users with options to modify their StudyID for the research.

## Global Variables

The app employs well-organized global variables for efficient data management:

- `cache`: A map storing the current study ID and information about files already uploaded.
- `studyId`: A unique identifier for the current study, facilitating seamless data uploads.
- `userId`: The email address of the current user, ensuring personalized interactions.
- `cacheFileName` and `cacheLastLoginFileName`: Files for storing cache and user login timestamp, respectively.
- `firstName` and `lastName`: Strings representing the user's first and last names.
- `data`: A list of `DataItem` objects, providing a structured approach to managing all data entries.

## AWS Amplify Integration

The app seamlessly integrates with AWS Amplify, leveraging powerful AWS services. The `_configureAmplify` function sets up the connection to AWS, configuring necessary plugins like Amplify Auth Cognito and Amplify Storage S3.

## Getting Started

1. **Clone the Repository**: Begin by cloning the repository to your local machine.
2. **Install Flutter and Dart**: Ensure you have Flutter and Dart installed on your development environment.
3. **Install Dependencies**: Run `flutter pub get` to install project dependencies.
4. **Configure Amplify**: Update the `amplifyconfiguration.dart` file with your AWS Amplify settings.
5. **Run the App**: Execute `flutter run` to launch the app.

## Xcode Test

### Requirements

- Mac with Xcode installed from Apple Store
- iPhone and cable to connect to Mac
- Developer mode turned on in iPhone

### Directions

1. Open `Runner.xcworkspace` under the `ios` folder.
2. Configure signing and capabilities in Xcode.
3. Assign "Runner" to your iPhone.
4. Click the "Play Button" to build the app.
5. Grant permission on your iPhone.
6. Re-run the app by clicking the "Play Button."

*Note: The app only runs when the runner is attached to the phone.*


## License

This project is licensed under the Noise App Group License. See the [LICENSE](LICENSE) file for detailed information.

