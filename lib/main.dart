import 'package:flutter/material.dart';
import 'home_page.dart'; // Import the home_page.dart file
import 'data_page.dart';
// import 'settings_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Noise App'),
            bottom: TabBar(
              tabs: [
                Tab(text: 'home'),
                Tab(text: 'Data'),
                // Tab(text: 'Settings'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              HomePage(), // Use HomePage as the content for the "Home" tab
              DataStoragePage(),
              // SettingsPage(),
            ],
          ),
        ),
      ),
    );
  }
}
