import 'package:flutter/material.dart';
import 'aws_service.dart'; // Import the AWS service file

class DataStoragePage extends StatefulWidget {
  @override
  _DataStoragePageState createState() => _DataStoragePageState();
}

class DataItem {
  final int id;
  String title;

  DataItem(this.id, this.title);
}

class _DataStoragePageState extends State<DataStoragePage> {
  final List<DataItem> data = [
    DataItem(1, "Item 1"),
    DataItem(2, "Item 2"),
    DataItem(3, "Item 3"),
  ];

  DataItem? selectedItem;
  String editedTitle = "";

  void handleRowPress(DataItem item) {
    setState(() {
      selectedItem = item;
      editedTitle = item.title;
    });

    // Show a bottom sheet for editing
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: TextEditingController(text: editedTitle),
                onChanged: (value) {
                  editedTitle = value;
                },
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: handleEditTitle,
                    child: Text('Save'),
                  ),
                  ElevatedButton(
                    onPressed: handleDelete,
                    child: Text('Delete'), // Add Delete button
                  ),
                  ElevatedButton(
                    onPressed: handleUpload,
                    child: Text('Upload'), // Add Upload button
                  ),
                  ElevatedButton(
                    onPressed: handleClosePopup,
                    child: Text('Cancel'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void handleClosePopup() {
    setState(() {
      selectedItem = null;
    });
  }

  void handleEditTitle() {
    if (selectedItem != null) {
      int selectedIndex =
          data.indexWhere((item) => item.id == selectedItem!.id);
      data[selectedIndex].title = editedTitle;
      handleClosePopup();
    }
  }

  void handleDelete() {
    if (selectedItem != null) {
      data.removeWhere((item) => item.id == selectedItem!.id);
      handleClosePopup();
    }
  }

  void handleUpload() {
    // // Call the AWS service to handle the upload
    // final awsService = AwsService();
    // awsService.handleUpload(selectedItem);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data Storage Page'),
      ),
      body: ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          final item = data[index];
          return ListTile(
            title: Text(item.title),
            onTap: () => handleRowPress(item),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          data.add(DataItem(data.length + 1, "New Item"));
          setState(() {});
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
