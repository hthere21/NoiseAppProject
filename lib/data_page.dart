import 'package:flutter/material.dart';
import 'aws_service.dart'; // Import the AWS service file
import 'local_storage.dart';
import 'dart:io';
import 'main.dart';

// Columns for the table
const List<DataColumn> COLUMNS = [
  DataColumn(
    label: Expanded(
      child: Text(
        'TimeStamp',
        style: TextStyle(fontStyle: FontStyle.italic),
      ),
    ),
  ),
  DataColumn(
    label: Expanded(
      child: Text(
        'Average',
        style: TextStyle(fontStyle: FontStyle.italic),
      ),
    ),
  ),
  DataColumn(
    label: Expanded(
      child: Text(
        'Minimum',
        style: TextStyle(fontStyle: FontStyle.italic),
      ),
    ),
  ),
  DataColumn(
    label: Expanded(
      child: Text(
        'Maximum',
        style: TextStyle(fontStyle: FontStyle.italic),
      ),
    ),
  ),
  DataColumn(
    label: Expanded(
      child: Text(
        'Latitude',
        style: TextStyle(fontStyle: FontStyle.italic),
      ),
    ),
  ),
  DataColumn(
    label: Expanded(
      child: Text(
        'Longitude',
        style: TextStyle(fontStyle: FontStyle.italic),
      ),
    ),
  )
];

class DataStoragePage extends StatefulWidget {
  @override
  _DataStoragePageState createState() => _DataStoragePageState();
}

// Class for storing each information about each row in the data page
class DataItem {
  final int id;
  String title;
  List<dynamic> data;
  DataItem(this.id, this.title, this.data);
}

class _DataStoragePageState extends State<DataStoragePage> {
  DataItem? selectedItem; // Variable tracks the current selected item
  String editedTitle = "";
  List<bool> selectedItems = List.generate(data.length, (index) => false);
  // Assuming this boolean variable to track whether data is loaded or not
  bool isDataLoaded = false;

  @override
  void initState() {
    super.initState();
    // Check if the list is empty
    // data.sort((a, b) => b.title.compareTo(a.title));
  }

  // Selects the item
  void handleRowPress(DataItem item) {
    setState(() {
      selectedItems = List.generate(data.length, (index) => false);
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
                readOnly: true, // Set readOnly to true to make it non-editable
              ),
              SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          await handleDelete();
                          _showDeletionConfirmation(context);
                          // Navigator.of(context).pop();
                        } catch (e) {
                          print(e);
                          _showDeletionFailure(context);
                        }
                      },
                      child: const Text('Delete'), // Add Delete button
                    ),
                    SizedBox(width: 8), // Add space between buttons
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          await handleUpload();
                          _showUploadConfirmation(context);
                          // Navigator.of(context).pop();
                        } catch (e) {
                          print("UPLOAD FAILED");
                          print(e);
                          _showUploadFailure(context);
                        }
                      },
                      child: const Text('Upload'), // Add Upload button
                    ),
                    SizedBox(width: 8), // Add space between buttons
                    ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return handleView();
                          },
                        );
                      },
                      child: const Text('View'),
                    ),
                    SizedBox(width: 8), // Add space between buttons
                    ElevatedButton(
                      onPressed: handleClosePopup,
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Creates table for viewing data
  List<DataRow> _createTableRows(int index) {
    List<DataRow> rows = [];
    DataItem item = data[index];
    List<dynamic> itemData = item.data;
    for (Map<dynamic, dynamic> row in itemData) {
      DataRow dataRow = DataRow(cells: <DataCell>[
        DataCell(Text(row['timeStamp'].toString())),
        DataCell(Text(row['avg'].toString())),
        DataCell(Text(row['min'].toString())),
        DataCell(Text(row['max'].toString())),
        DataCell(Text(row['lat'].toString())),
        DataCell(Text(row['lon'].toString())),
      ]);
      rows.add(dataRow);
    }

    return rows;
  }

  // Closes popup by removing selected item
  void handleClosePopup() {
    setState(() {
      selectedItem = null;
    });
  }

  // Prepares view popup with CSV data
  AlertDialog handleView() {
    List<DataRow> rows = _createTableRows(selectedItem!.id - 1);
    return AlertDialog(
      content: Container(
          width: 300.0,
          height: 400.0,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(columns: COLUMNS, rows: rows)),
          )),
      actions: [
        ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Close'))
      ],
    );
    // }
  }

  Future<void> handleDelete() async {
    if (selectedItem != null) {
      String fileName = selectedItem!.title;

      cache.removeWhere((key, value) => key == fileName);
      data.removeWhere((item) => item.id == selectedItem!.id);

      await deleteCacheOfUserUpload(fileName);
      await deleteContent(fileName);

      setState(() {
        selectedItem = null;
      });
    }
  }

  Future<void> handleMultipleDeletes() async {
    // Finds all items that will be deleted
    List<DataItem> allItemsToDelete = [];
    List<String> allFileNamesToDeleteFromCache = [];

    for (final (index, selected) in selectedItems.indexed) {
      if (selected) {
        allItemsToDelete.add(data[index]);
        allFileNamesToDeleteFromCache.add(data[index].title);
      }
    }

    try {
      // Deletes the data from local storage and cache
      for (DataItem itemToDelete in allItemsToDelete) {
        await deleteContent(itemToDelete.title);
        cache.removeWhere((key, value) => key == itemToDelete.title);
        data.removeWhere((item) => item.id == itemToDelete.id);
      }
      await deleteCacheOfUserMultipleUpload(allFileNamesToDeleteFromCache);
    } catch (e) {
      // print("Failed to delte multiple $e");
      rethrow;
    } finally {
      setState(() {
        selectedItem = null;
        selectedItems = List.generate(data.length, (index) => false);
      });
    }
  }

  // Show popup dialog for upload confirmation
  void _showUploadConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Upload Confirmed'),
          content: const Text('Successfully Uploaded!'),
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

  // Show popup dialog for upload failure
  void _showUploadFailure(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Upload Failed'),
          content: const Text('Failed to upload... Try Again Later.'),
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

  // Shows popup information that file deletion succeeded
  void _showDeletionConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Deletion Success'),
          content: const Text('Deleted file successfully!'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Close the AlertDialog
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Shows popup information that file deletion failed
  void _showDeletionFailure(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Deletion Fail'),
          content: const Text('Failed to delete file...'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Close the AlertDialog
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Upload CSV file of selected item
  Future<void> handleUpload() async {
    final awsService = AwsS3Service();

    try {
      // Gets filename from selected item
      String fileName = selectedItem!.title;
      File csvFile = await getLocalFile(fileName);

      // Uploads CSV file and tracks upload status by updating cache
      await awsService.uploadCSVFile(csvFile, studyId);
      setState(() {
        cache[fileName] = true;
      });
      await writeCacheOfUserUpload(fileName);
    } catch (e) {
      // print("FAILING");
      rethrow;
    }
  }

  // Upload multiple CSV files of selected items
  Future<void> handleMultipleUploads() async {
    // Stores all filenames that will be uploaded
    final awsService = AwsS3Service();
    List<String> allFilesUploaded = [];

    try {
      // Uploads only data that user selected
      for (final (index, selected) in selectedItems.indexed) {
        if (selected) {
          // Gets filename from selected data
          selectedItem = data[index];
          // print(selectedItem!.title);
          String fileName = selectedItem!.title;
          File csvFile = await getLocalFile(fileName);

          // Uploads file and tracks upload status by updating cache
          await awsService.uploadCSVFile(csvFile, studyId);
          cache[fileName] = true;
          // print("Successfully uploaded $fileName");

          // Tracks filename that was uploaded
          allFilesUploaded.add(fileName);
        }
      }
      // Updates local cache file with all files uploaded
      await writeCacheOfUserMultipleUpload(allFilesUploaded);
    } catch (e) {
      // safePrint("Error with multiple uploads $e");
      rethrow;
    } finally {
      // Reset selected data items to 0
      setState(() {
        selectedItem = null;
        selectedItems = List.generate(data.length, (index) => false);
      });
    }
  }

  // Returns filenames with uploaded tag based on cache file
  String checkUploaded(String fileName) {
    if (cache.containsKey(fileName)) {
      return "$fileName ( UPLOADED )";
    }
    return fileName;
  }

  @override
  Widget build(BuildContext context) {
    // Check if data is not loaded, display loading page
    if (!prevDataLoaded) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(), // Or your custom loading widget
        ),
      );
    }

    int selectedCount = selectedItems.where((element) => element).length;
    return Scaffold(
        appBar: AppBar(
          title: const Text('Data Storage Page'),
        ),
        body: Column(children: [
          Expanded(
            child: ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final sortedData = [...data];
                sortedData.sort((a, b) => b.title.compareTo(a.title));
                final item = sortedData[index];
                return ListTile(
                  title: Text(checkUploaded(item.title)),
                  onTap: () => handleRowPress(item),
                  trailing: Checkbox(
                    value: selectedItems[data.length - 1 - index],
                    onChanged: (bool? value) {
                      setState(() {
                        selectedItems[data.length - 1 - index] = value!;
                      });
                    },
                  ),
                );
              },
            ),
          ),
          selectedCount > 0
              ? Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            // Perform action with selected items
                            try {
                              await handleMultipleUploads();
                              _showUploadConfirmation(context);
                              print('Uploaded $selectedCount items');
                            } catch (e) {
                              _showUploadFailure(context);
                              print(e);
                            }
                          },
                          child: Text('Upload $selectedCount items'),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            // Perform another action with selected items
                            try {
                              await handleMultipleDeletes();
                              _showDeletionConfirmation(context);
                              print('Deleted $selectedCount items');
                            } catch (e) {
                              _showDeletionFailure(context);
                              print(e);
                            }
                          },
                          child: Text('Delete $selectedCount items'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25), // Adjust the height as needed
                  ],
                )
              : const SizedBox(), // Empty SizedBox when selectedCount is not greater than 0
        ]));
  }
}
