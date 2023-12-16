# flutter_noise_apps_117

A new Flutter project.

## Getting Started

# Flutter Noise App

## Overview

The **Flutter Noise App** is a versatile mobile application built with the Flutter framework, offering seamless noise-related data recording and management for various studies. With a clean and intuitive interface, users can navigate through different tabs to access essential features, including Home, Data Storage, and Settings.

## Features

1. **Authentication**: Secure user authentication is facilitated through Amplify Auth Cognito, enabling users to sign up and sign in effortlessly.

2. **Data Recording**: Users can efficiently record and manage noise-related data within the app, providing a robust solution for data collection.

3. **Data Storage**: The Data tab allows users to conveniently view and manage their recorded noise-related data, ensuring easy access and organization.

4. **Settings**: Customize your app experience with the Settings tab, providing users with options to tailor preferences to their liking.

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

## Acknowledgments

This app was crafted to streamline noise-related data recording for diverse studies. Special thanks to the Flutter and AWS Amplify communities for their continuous support and invaluable resources.

## License

This project is licensed under the Noise App Group License. See the [LICENSE](LICENSE) file for detailed information.

