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
import 'package:permission_handler/permission_handler.dart';
import 'package:fftea/fftea.dart';
import 'package:queue/queue.dart';
import 'data_page.dart';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import 'local_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'aws_service.dart';


const columnsForNoiseData = ['timeStamp', 'lat', 'lon', 'avg', 'min', 'max'];

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  

  int recordingTimerDuration = 0; // Duration in seconds
  List<double> RaValues = [];
  int? sampleRate;
  bool isRecording = false;
  List<double> audio = [];
  List<double>? latestBuffer;
  double? recordingTime;
  Timer? countdownTimer; // Added timer
  final audioDataQueue = ListQueue<List<double>>();
  StreamSubscription<List<double>>? audioSubscription;
  DateTime? recordingStartTime;

  @override
  void initState() {
    super.initState();
    calculateRaValues();
  }

  void exportCSV(String fileName, List<Map<String,dynamic>> noiseData) {
    List<List<dynamic>> rows = [];
    rows.add(columnsForNoiseData);

    for (var data in noiseData) {
      rows.add([data['timeStamp'], data['avg'], data['min'], data['max'], data['lat'], data['lon']]);
    }

    String csv = const ListToCsvConverter().convert(rows);
    writeContent(fileName, csv);
  }

  void sendToDataPage() {
    List<Map<String,dynamic>> TEMP_DATA = [
      {"timeStamp": 123456, "lat": "14.97534313396318", 
        "lon": "101.22998536005622", "avg": 123,
        "min": 5.0, "max": 500},
      {"timeStamp": 123556, "lat": "14.97534313396318", 
      "lon": "101.22998536005622", "avg": 123,
      "min": 5, "max": 500},
    ];

    String currTime = DateTime.now().toString();

    exportCSV(currTime, TEMP_DATA);

    setState(() {
      
      data.add(DataItem(data.length + 1, currTime, TEMP_DATA));
    });

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
          
        }
      });
    });
  }

  /// Call-back on audio sample.
  void onAudio(List<double> buffer) async {
    if (recordingTimerDuration == 0) {
      sendToDataPage();
      stop();
      return;
    }
    // print("Start recording: " + DateTime.now().toString());
    audio.addAll(buffer);
    audioDataQueue.add(buffer);

    if (audioDataQueue.length >= 10) {
      // Process 10 chunks of 19200 values
      for (int i = 0; i < 10; i++) {
        List<double> chunk = audioDataQueue.removeFirst();
        List<List<double>> smallerArrays = [];
        List<double> dBA_Arrays = [];

        for (int j = 0; j < chunk.length; j += 1920) {
          int end = j + 1920;
          if (end > chunk.length) {
            end = chunk.length;
          }
          smallerArrays.add(chunk.sublist(j, end));
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
          // print(dBValues.sum);
          final final_dBA = (10 * log10((dBAValues.sum)));
          // print(final_dBA);
          dBA_Arrays.add(final_dBA);
        }
        // print(dBA_Arrays);
        final averageDBA = (dBA_Arrays.sum) / 10;
        print("Current Average dBA: " + averageDBA.toString());
        // print("Finish analyze: " + DateTime.now().toString());
        dBA_Arrays = [];
      }
    }

    // Get the actual sampling rate, if not already known.
    sampleRate ??= await AudioStreamer().actualSampleRate;
    setState(() => latestBuffer = buffer);
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

    audioSubscription =
        AudioStreamer().audioStream.listen(onAudio, onError: handleError);

    setState(() {
      isRecording = true;
    });

    if (recordingTimerDuration > 0) {
      startCountdown(); // Start the countdown timer
    }
  }

  void stop() {
    audioSubscription?.cancel();
    countdownTimer?.cancel(); // Cancel the countdown timer
    setState(() {
      isRecording = false;
    });
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
                Container(
                  margin: EdgeInsets.all(25),
                  child: Column(
                    children: [
                      RichText(
                        text: TextSpan(
                          text: 'Remaining Time: ',
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.green), // The default text style
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
                      Container(
                        margin: EdgeInsets.all(20),
                        child: Text(
                          isRecording ? "MIC: ON" : "MIC: OFF",
                          style: TextStyle(fontSize: 25, color: Colors.blue),
                        ),
                      ),
                      Text('Max amp: ${latestBuffer?.reduce(max)}'),
                      Text('Min amp: ${latestBuffer?.reduce(min)}'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                backgroundColor: isRecording ? Colors.red : Colors.green,
                child: isRecording ? Icon(Icons.stop) : Icon(Icons.mic),
                onPressed: isRecording ? stop : start,
              ),
              SizedBox(width: 10),
              FloatingActionButton(
                child: Icon(Icons.timer),
                onPressed: () {
                  _showTimerPicker(context);
                },
              ),
            ],
          ),
      );
  }
}