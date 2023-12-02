import 'dart:collection';
import 'dart:math';
import 'dart:async';
import 'dart:core';
import 'package:collection/collection.dart';
import 'package:eval_ex/built_ins.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cupertino_icons/cupertino_icons.dart';
import 'package:audio_streamer/audio_streamer.dart';
import 'package:flutter_noise_app_117/sound_wave_animation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fftea/fftea.dart';
// import 'package:queue/queue.dart';
import 'data_page.dart';
// import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import 'local_storage.dart';
// import 'package:path_provider/path_provider.dart';
// import 'aws_service.dart';
import 'package:geolocator/geolocator.dart';
import 'main.dart';

const columnsForNoiseData = ['timeStamp', 'lat', 'lon', 'avg', 'min', 'max'];

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class ProcessedValues {
  final String timeStamp;
  final String lat;
  final String lon;
  final double avg;
  final double min;
  final double max;

  ProcessedValues({
    required this.timeStamp,
    required this.lat,
    required this.lon,
    required this.avg,
    required this.min,
    required this.max,
  });

  // Method to convert ProcessedValues to a Map
  Map<String, dynamic> toMap() {
    return {
      "timeStamp": timeStamp,
      "lat": lat,
      "lon": lon,
      "avg": avg,
      "min": min,
      "max": max,
    };
  }

  // Override toString to use the toMap method
  @override
  String toString() {
    return toMap().toString();
  }
}

class _HomePageState extends State<HomePage> {
  //Long and Lat global variables:
  double latitude = 0.0;
  double longitude = 0.0;
  //Global varible for data collection
  List<dynamic> dataList = [];
  //Interval selections
  int selectedIntervalInSeconds = 1; // default interval is 1 second
  List<double> accumulatedDBAValues = [];

  int recordingTimerDuration = 0; // Duration in seconds
  int initialrecordingTimerDuration = 0;
  List<double> RaValues = [];

  int? sampleRate;
  bool isRecording = false;
  bool isStop = false;
  bool isFinish = false;
  List<double> audio = [];
  List<double>? latestBuffer;
  double? recordingTime;
  Timer? countdownTimer;
  final audioDataQueue = ListQueue<List<double>>();
  StreamSubscription<List<double>>? audioSubscription;
  DateTime? recordingStartTime;
  // Checks if the data has already been loaded

  @override
  void initState() {
    super.initState();

    loadCache();
    loadAllPreviousData();
    calculateRaValues();
    // Start fetching geolocation every 30 seconds
    Timer.periodic(Duration(seconds: 5), (timer) {
      getCurrentLocation();
    });
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    audioSubscription?.cancel();
    // Dispose of other resources like controllers
    super.dispose();
  }

// Get current geolocation
  void getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Handle case where location services are disabled
        print('Location services are disabled.');
        return;
      }
      // Check and request location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Handle case where location permission is denied
          print('Location permission is denied.');
          return;
        }
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      if (mounted) {
        setState(() {
          latitude = position.latitude;
          longitude = position.longitude;
        });
      }
    } catch (e) {
      // Handle other location-related errors
      print("Error getting location: $e");
    }
  }

  void loadCache() async {
    if (cacheLoaded) {
      return;
    }
    cache = await readCacheOfUser();
    cacheLoaded = true;
    studyId = cache['studyId'];
  }

  void loadAllPreviousData() async {
    if (prevDataLoaded) {
      return;
    }
    List<File> files = await listOfFiles;

    for (File file in files) {
      if (file.path.split('/').last.contains(".csv")) {
        List<List<dynamic>> content = await readContent(file);
        List<dynamic> columnNames = content.removeAt(0);
        List<dynamic> tempData = [];

        for (var row in content) {
          tempData.add(Map.fromIterables(columnNames, row));
        }

        DataItem item =
            DataItem(data.length + 1, file.path.split('/').last, tempData);
        data.add(item);
      }
    }

    prevDataLoaded = true;
  }

  void exportCSV(String fileName, List<dynamic> noiseData) {
    List<List<dynamic>> rows = [];
    rows.add(columnsForNoiseData);

    for (var data in noiseData) {
      rows.add([
        data['timeStamp'],
        data['lat'],
        data['lon'],
        data['avg'],
        data['min'],
        data['max']
      ]);
    }

    String csv = const ListToCsvConverter().convert(rows);
    writeContent(fileName, csv);
  }

  void sendToDataPage() {
    String fileName = '${DateTime.now().toString()}.csv';
    List<dynamic> newArray = [];
    for (ProcessedValues newData in dataList) {
      newArray.add(newData.toMap());
    }

    exportCSV(fileName, newArray);

    setState(() {
      data.add(DataItem(data.length + 1, fileName, newArray));
    });
  }

  Future<void> reset() async {
    setState(() {
      isStop = false;
      isRecording = false;
      isFinish = false;
      recordingTimerDuration = 0;
      initialrecordingTimerDuration = 0;
      accumulatedDBAValues.clear();
      audio.clear();
      latestBuffer = null;
      dataList.clear();
    });
  }

  void checkAccumulatedArray() async {
    // Check if recording has stopped
    if (!isRecording && accumulatedDBAValues.isNotEmpty) {
      List<double> valuesToCalculate = accumulatedDBAValues;
      accumulatedDBAValues = [];
      // Calculate the sum of dBA values
      double sumOfDBA =
          valuesToCalculate.fold(0, (acc, dBA) => acc + pow(10, dBA / 10));

      // Calculate the average dBA
      double averageDBA = 10 * log10(sumOfDBA / valuesToCalculate.length);
      double minDBA = valuesToCalculate.reduce(min);
      double maxDBA = valuesToCalculate.reduce(max);

      // Round to the second decimal place
      averageDBA = double.parse(averageDBA.toStringAsFixed(2));
      minDBA = double.parse(minDBA.toStringAsFixed(2));
      maxDBA = double.parse(maxDBA.toStringAsFixed(2));
      var timeStamp = (DateTime.now()).toString();

      ProcessedValues processedValues = ProcessedValues(
        timeStamp: timeStamp,
        lat: latitude.toString(),
        lon: longitude.toString(),
        avg: averageDBA,
        min: minDBA,
        max: maxDBA,
      );
      dataList.add(processedValues);

      //Send data page
      sendToDataPage();
      print("OK");
      print(dataList);
    }
    // sendToDataPage(); // FOR TESTING ON ANDROID
  }

  // Function to process accumulated dBA values
  void processAccumulatedDBAValues() async {
    int valuesToTake = ((selectedIntervalInSeconds * 1000) / 43.5374).round();
    List<double> valuesToCalculate = accumulatedDBAValues.sublist(
        0, min(valuesToTake + 1, accumulatedDBAValues.length));
    accumulatedDBAValues = accumulatedDBAValues
        .sublist(min(valuesToTake + 1, accumulatedDBAValues.length));
    // Calculate the sum of dBA values
    double sumOfDBA =
        valuesToCalculate.fold(0, (acc, dBA) => acc + pow(10, dBA / 10));

    // Calculate the average dBA
    double averageDBA = 10 * log10(sumOfDBA / valuesToCalculate.length);
    double minDBA = valuesToCalculate.reduce(min);
    double maxDBA = valuesToCalculate.reduce(max);

    averageDBA = double.parse(averageDBA.toStringAsFixed(2));
    minDBA = double.parse(minDBA.toStringAsFixed(2));
    maxDBA = double.parse(maxDBA.toStringAsFixed(2));
    var timeStamp = (DateTime.now()).toString();

    ProcessedValues processedValues = ProcessedValues(
      timeStamp: timeStamp,
      lat: latitude.toString(),
      lon: longitude.toString(),
      avg: averageDBA,
      min: minDBA,
      max: maxDBA,
    );
    dataList.add(processedValues);
  }

  void calculateRaValues() {
    for (int i = 1; i <= 960; i++) {
      double freq = 22.97 * i;
      double Ra = calculateRa(freq);
      RaValues.add(Ra);
    }
  }

  double calculateRa(double frequency) {
    double f = frequency;
    final numerator = pow(12200, 2) * pow(f, 4);
    final denominator = (pow(f, 2) + pow(20.6, 2)) *
        (pow(f, 2) + pow(12200, 2)) *
        sqrt(pow(f, 2) + pow(107.7, 2)) *
        sqrt(pow(f, 2) + pow(737.9, 2));

    if (denominator == 0) {
      return 0.0;
    }

    final Ra = numerator / denominator;
    return 2.0 + 20 * log10(Ra);
  }

  void setRecordingTimer(int durationInSeconds) {
    setState(() {
      recordingTimerDuration = durationInSeconds;
      initialrecordingTimerDuration = durationInSeconds;
    });
  }

  void startCountdown() {
    countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (recordingTimerDuration > 0) {
          recordingTimerDuration--;
        } else {
          timer.cancel();
          stop();
          isFinish = true;
          isRecording = false;
          isStop = false;
        }
      });
    });
  }

  /// Call-back on audio sample.
  void onAudio(List<double> buffer) async {
    try {
      if (recordingTimerDuration == 0) {
        reset();
        return;
      }
      audio.addAll(buffer);
      audioDataQueue.add(buffer);

      // print(buffer.length);
      List<double> chunk = audioDataQueue.removeFirst();
      List<List<double>> smallerArrays = [];
      List<double> dBA_Arrays = [];
      int j = 0;
      while (j < chunk.length) {
        int end = j + 1920;
        if (end > chunk.length) {
          end = chunk.length;
        }
        smallerArrays.add(chunk.sublist(j, end));
        j = end;
      }

      for (List<double> smallerArray in smallerArrays) {
        final fft = FFT(smallerArray.length);
        final freq = fft.realFft(smallerArray);
        List<double> dBAValues = [];

        for (int j = 0; j < 960; j++) {
          final double real = freq[j].x;
          final double imaginary = freq[j].y;

          // Precompute squared values
          final Pi =
              (2 * (sqrt((real * real + imaginary * imaginary) / 3686400)));
          final dBi = 20 * log10(Pi);
          // Calculate the magnitude value for the current frequency bin
          final dBAvalue_i = dBi + 20 * log10(pow(2, 15)) + RaValues[j];
          final dBAvalue = pow(10, ((dBAvalue_i) / 10));
          dBAValues.add(dBAvalue as double);
        }
        final final_dBA = (10 * log10((dBAValues.sum)));
        dBA_Arrays.add(final_dBA);
      }
      accumulatedDBAValues.addAll(dBA_Arrays);
      // Check if enough values are accumulated based on the selected interval
      num requiredLength =
          ((selectedIntervalInSeconds * 1000) / 43.5374).round();
      // print(requiredLength);
      if (accumulatedDBAValues.length >= requiredLength) {
        // Call the function to process accumulated dBA values
        processAccumulatedDBAValues();
      }
      dBA_Arrays = [];

      // Get the actual sampling rate, if not already known.
      sampleRate ??= await AudioStreamer().actualSampleRate;
      double recordingTimeOnAudio = audio.length / sampleRate!;
      // print(recordingTimeOnAudio);
      if (recordingTimeOnAudio > initialrecordingTimerDuration) {
        stop();
        setState(() {
          isFinish = true;
          isRecording = false;
          isStop = false;
          recordingTimerDuration = 0;
          recordingTimeOnAudio = 0;
          buffer = [];
        });
        return;
      }

      setState(() => latestBuffer = buffer);
    } catch (e, stackTrace) {
      print('Exception: $e');
      print('Stack Trace: $stackTrace');
    }
  }

  Future<bool> checkPermission() async => await Permission.microphone.isGranted;
  Future<void> requestPermission() async =>
      await Permission.microphone.request();

  void handleError(Object error) {
    setState(() => isRecording = false);
    print(error);
  }

  void start() async {
    if (!(await checkPermission())) {
      await requestPermission();
    }
    AudioStreamer().sampleRate = 44100;

    if (recordingTimerDuration > 0) {
      startCountdown();
    }

    audioSubscription =
        AudioStreamer().audioStream.listen(onAudio, onError: handleError);

    setState(() {
      isStop = false;
      isRecording = true;
      isFinish = false; // Reset isFinish when starting recording
    });
  }

  void stop() {
    countdownTimer?.cancel(); // Cancel the countdown timer
    audioSubscription?.cancel();
    setState(() {
      isRecording = false;
      isFinish = false;
      isStop = true;
    });
  }

  void finish() {
    checkAccumulatedArray();
    setState(() {
      isStop = false;
      isRecording = false;
      isFinish = false;
      recordingTimerDuration = 0;
      initialrecordingTimerDuration = 0;
    });
    reset();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: AlertDialog(
            title: Text(
              'Recording Finished',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.green, // Set the text color to green
              ),
            ),
            content: Text('Your recording has been completed successfully.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      },
    );
  }

  void showRecordingCanelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Recording Canceled',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.orange, // Set the text color to green
            ),
          ),
          content: Text('Your recording has been cancelled.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showIntervalPicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return Container(
          height: 216,
          color: Colors.white,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  CupertinoButton(
                    child: Text('Done'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 32,
                  onSelectedItemChanged: (int index) {
                    setState(() {
                      selectedIntervalInSeconds = index + 1;
                    });
                  },
                  children: List.generate(59, (index) {
                    return Center(
                      child: Text((index + 1).toString()),
                    );
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showTimerPicker(BuildContext context) {
    setRecordingTimer(0);
    int newHours = 0;
    int newMinutes = 0;
    int newSeconds = 0;

    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return Container(
          height: 216,
          color: Colors.white,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  CupertinoButton(
                    child: Text('Done'),
                    onPressed: () {
                      int totalSeconds =
                          (newHours * 3600) + (newMinutes * 60) + newSeconds;
                      setRecordingTimer(totalSeconds);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              Expanded(
                child: CupertinoTimerPicker(
                  mode: CupertinoTimerPickerMode.hms,
                  initialTimerDuration: Duration(
                    hours: newHours,
                    minutes: newMinutes,
                    seconds: newSeconds,
                  ),
                  onTimerDurationChanged: (Duration duration) {
                    newHours = duration.inHours;
                    newMinutes = (duration.inMinutes % 60);
                    newSeconds = (duration.inSeconds % 60);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Audio Recording'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Conditionally include SoundWaveAnimation when recording
            SoundWaveAnimation(isRecording: isRecording),
            Container(
              margin: EdgeInsets.all(25),
              child: Column(
                children: [
                  RichText(
                    text: TextSpan(
                      text: 'Remaining Time: ',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.green,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: recordingTimerDuration > 0
                              ? '$recordingTimerDuration seconds'
                              : '${recordingTime?.toStringAsFixed(2) ?? "0.00"} seconds',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Interval Selection: ${selectedIntervalInSeconds} seconds',
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                  Container(
                    margin: EdgeInsets.all(20),
                    child: Text(
                      isRecording ? "MIC: ON" : "MIC: OFF",
                      style: TextStyle(fontSize: 25, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (isFinish && !isRecording)
            FloatingActionButton.extended(
              onPressed: () {
                finish();
                // Add any logic you need for finishing the recording
              },
              label: Text('Finish'),
              icon: Icon(Icons.check),
              backgroundColor: Colors.blue,
            ),
          const SizedBox(width: 2),
          if (!isRecording && isFinish)
            FloatingActionButton.extended(
              onPressed: () {
                reset();
              },
              label: Text('Delete'),
              icon: Icon(Icons.delete),
              backgroundColor: Colors.red,
            ),

          SizedBox(width: 5), // Add spacing between buttons
          if (!isFinish)
            FloatingActionButton(
              backgroundColor: isRecording ? Colors.red : Colors.green,
              child: isRecording ? Icon(Icons.stop) : Icon(Icons.mic),
              onPressed: () {
                setState(() {
                  isRecording = !isRecording;
                });
                // Start or stop recording based on the current state
                if (isRecording) {
                  start();
                } else {
                  stop();
                }
              },
            ),
          const SizedBox(width: 5),
          if (!isFinish && !isRecording && !isStop)
            FloatingActionButton(
              child: Icon(Icons.timer),
              onPressed: () {
                _showTimerPicker(context);
              },
            ),
          const SizedBox(width: 5),
          if (!isFinish && !isRecording && !isStop)
            FloatingActionButton(
              child: Icon(Icons.more_time),
              onPressed: () {
                _showIntervalPicker(context);
              },
            ),
          const SizedBox(width: 2),
          if ((isRecording && !isFinish) || (isStop && !isFinish))
            FloatingActionButton.extended(
              onPressed: () {
                stop();
                reset();
                showRecordingCanelDialog(context);
              },
              label: Text('Cancel'),
              icon: Icon(Icons.cancel),
              backgroundColor: Colors.orange,
            ),
        ],
      ),
    );
  }
}
