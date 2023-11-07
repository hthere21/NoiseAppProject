import 'dart:collection';
import 'dart:math';
import 'dart:async';
import 'package:collection/collection.dart';
import 'dart:core';
import 'package:eval_ex/built_ins.dart';

import 'package:flutter/material.dart';
import 'package:audio_streamer/audio_streamer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fftea/fftea.dart';
import 'package:queue/queue.dart';

void main() => runApp(new AudioStreamingApp());

class AudioStreamingApp extends StatefulWidget {
  @override
  AudioStreamingAppState createState() => new AudioStreamingAppState();
}

class AudioStreamingAppState extends State<AudioStreamingApp> {
  //Calculating Ra values beforehand
  List<double> RaValues = [];
  //Other initialization
  int? sampleRate;
  bool isRecording = false;
  List<double> audio = [];
  List<double>? latestBuffer;
  double? recordingTime;
  final audioDataQueue = ListQueue<List<double>>();
  StreamSubscription<List<double>>? audioSubscription;
  //
  DateTime? recordingStartTime;

  //
  void initState() {
    super.initState();
    calculateRaValues();
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
    final Ra = numerator / denominator;
    return 2.0 + 20 * log10(Ra);
  }

  /// Call-back on audio sample.
  void onAudio(List<double> buffer) async {
    print("Start recording: " + DateTime.now().toString());
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
        // final averageDBA = (dBA_Arrays.sum) / 10;
        // print(dBA_Arrays);
        print("Finish analyze: " + DateTime.now().toString());
        dBA_Arrays = [];
      }
    }

    // Get the actual sampling rate, if not already known.
    sampleRate ??= await AudioStreamer().actualSampleRate;
    recordingTime = audio.length / sampleRate!;
    setState(() => latestBuffer = buffer);
  }

  /// Check if microphone permission is granted.
  Future<bool> checkPermission() async => await Permission.microphone.isGranted;

  /// Request the microphone permission.
  Future<void> requestPermission() async =>
      await Permission.microphone.request();

  /// Call-back on error.
  void handleError(Object error) {
    setState(() => isRecording = false);
    print(error);
  }

  /// Start audio sampling.
  void start() async {
    // Check permission to use the microphone.
    //
    // Remember to update the AndroidManifest file (Android) and the
    // Info.plist and pod files (iOS).
    if (!(await checkPermission())) {
      await requestPermission();
    }

    // Set the sampling rate - works only on Android.
    AudioStreamer().sampleRate = 44100;

    // Start listening to the audio stream.
    audioSubscription =
        AudioStreamer().audioStream.listen(onAudio, onError: handleError);

    setState(() => isRecording = true);
  }

  /// Stop audio sampling.
  void stop() async {
    audioSubscription?.cancel();
    setState(() => isRecording = false);
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        home: Scaffold(
          body: Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                Container(
                    margin: EdgeInsets.all(25),
                    child: Column(children: [
                      Container(
                        child: Text(isRecording ? "Mic: ON" : "Mic: OFF",
                            style: TextStyle(fontSize: 25, color: Colors.blue)),
                        margin: EdgeInsets.only(top: 20),
                      ),
                      Text(''),
                      Text('Max amp: ${latestBuffer?.reduce(max)}'),
                      Text('Min amp: ${latestBuffer?.reduce(min)}'),
                      Text(
                          '${recordingTime?.toStringAsFixed(2)} seconds recorded.'),
                    ])),
              ])),
          floatingActionButton: FloatingActionButton(
            backgroundColor: isRecording ? Colors.red : Colors.green,
            child: isRecording ? Icon(Icons.stop) : Icon(Icons.mic),
            onPressed: isRecording ? stop : start,
          ),
        ),
      );
}
