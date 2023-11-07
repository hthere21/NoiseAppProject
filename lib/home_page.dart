// import 'package:flutter/material.dart';

// class HomePage extends StatefulWidget {
//   @override
//   _HomePageState createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Container(), // Replace the contents with an empty Container
//     );
//   }
// }

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:quiver/async.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  // HomePage({Key key, this.title}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _controller;
  int userDuration = 0;
  Duration userInterval = Duration(seconds: 1);
  Duration currDuration = Duration(seconds: 0);
  int counter = 0;
  late StreamSubscription timer;

  void onTapDuration() {
    Picker(
      adapter: NumberPickerAdapter(data: <NumberPickerColumn>[
        const NumberPickerColumn(begin: 0, end: 999, suffix: Text(' hours')),
        const NumberPickerColumn(begin: 0, end: 60, suffix: Text(' minutes')),
        const NumberPickerColumn(begin: 0, end: 60, suffix: Text(' seconds'))
      ]),
      delimiter: <PickerDelimiter>[
        PickerDelimiter(
          child: Container(
            width: 30.0,
            alignment: Alignment.center,
            child: Icon(Icons.more_vert),
          ),
        )
      ],
      hideHeader: true,
      confirmText: 'OK',
      confirmTextStyle:
          TextStyle(inherit: false, color: Colors.red, fontSize: 22),
      title: const Text('Select Duration'),
      selectedTextStyle: TextStyle(color: Colors.blue),
      onConfirm: (Picker picker, List<int> value) {
        // You get your duration here
        setState(() {
          userDuration = Duration(
                  hours: picker.getSelectedValues()[0],
                  minutes: picker.getSelectedValues()[1],
                  seconds: picker.getSelectedValues()[2])
              .inSeconds;
          currDuration = Duration(seconds: userDuration);
          print(currDuration);
        });
      },
    ).showDialog(context);
  }

  void onTapInterval() {
    Picker(
      adapter: NumberPickerAdapter(data: <NumberPickerColumn>[
        const NumberPickerColumn(begin: 0, end: 999, suffix: Text(' hours')),
        const NumberPickerColumn(begin: 0, end: 60, suffix: Text(' minutes')),
        const NumberPickerColumn(begin: 0, end: 60, suffix: Text(' seconds'))
      ]),
      delimiter: <PickerDelimiter>[
        PickerDelimiter(
          child: Container(
            width: 50.0,
            alignment: Alignment.center,
            child: Icon(Icons.more_vert),
          ),
        )
      ],
      hideHeader: true,
      confirmText: 'OK',
      confirmTextStyle:
          TextStyle(inherit: false, color: Colors.red, fontSize: 22),
      title: const Text('Select Interval'),
      selectedTextStyle: TextStyle(color: Colors.blue),
      onConfirm: (Picker picker, List<int> value) {
        // You get your duration here
        setState(() {
          userInterval = Duration(
              hours: picker.getSelectedValues()[0],
              minutes: picker.getSelectedValues()[1],
              seconds: picker.getSelectedValues()[2]);
          print(userInterval);
        });
      },
    ).showDialog(context);
  }

  // void _incrementCounter() {
  //   setState(() {
  //     _counter++;
  //   });
  // }

  // @override
  // void dispose() {
  //   _controller.dispose();
  //   super.dispose();
  // }

  // @override
  // void initState() {
  //   super.initState();

  //   _controller = AnimationController(
  //       vsync: this,
  //       duration: Duration(
  //           seconds:
  //               userDuration) // duration is a user entered number elsewhere in the applciation
  //       );

  // }

  void startTimer() {
    CountdownTimer countDownTimer = CountdownTimer(
      new Duration(seconds: userDuration),
      new Duration(seconds: 1),
    );

    timer = countDownTimer.listen(null);
    timer.onData((duration) {
      int secondsElapsed = duration.elapsed.inSeconds as int;

      setState(() {
        currDuration = Duration(seconds: userDuration - secondsElapsed);
      });
      counter++;

      if (counter == userInterval.inSeconds) {
        print("DO SOME CRAZY MATH");
        counter = 0;
      }
    });

    timer.onDone(() {
      print("Done");
      counter = 0;
      timer.cancel();
    });
  }

  void stopTimer() {
    print("Canceling Timer!");
    setState(() {
      userDuration = 0;
      currDuration = Duration(seconds: userDuration);
      print(currDuration);
    });
    timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Noise App"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
                style: TextStyle(
                  fontSize: 40,
                  color: Theme.of(context).primaryColor,
                ),
                'DURATION:'),
            Text(
                style: TextStyle(
                  fontSize: 40,
                  color: Theme.of(context).primaryColor,
                ),
                '${currDuration.inHours.remainder(60).toString().padLeft(2, '0')}:${currDuration.inMinutes.remainder(60).toString().padLeft(2, '0')}:${currDuration.inSeconds.remainder(60).toString().padLeft(2, '0')}'),
            ElevatedButton(
                onPressed: onTapDuration, child: Text("Set Duration")),
            Text(
                style: TextStyle(
                  fontSize: 40,
                  color: Theme.of(context).primaryColor,
                ),
                'INTERVAL:'),
            Text(
                style: TextStyle(
                  fontSize: 40,
                  color: Theme.of(context).primaryColor,
                ),
                '${userInterval.inHours.remainder(60).toString().padLeft(2, '0')}:${userInterval.inMinutes.remainder(60).toString().padLeft(2, '0')}:${userInterval.inSeconds.remainder(60).toString().padLeft(2, '0')}'),
            // Countdown(
            //   animation: StepTween(
            //     begin: userDuration, // THIS IS A USER ENTERED NUMBER
            //     end: 0,
            //   ).animate(_controller),
            //   interval: 10,
            //   startTimeInSeconds: userDuration,
            // ),

            ElevatedButton(
                onPressed: onTapInterval, child: Text("Set Interval")),
            ElevatedButton(
                onPressed: () => {startTimer()}, child: Text("Start")),
            ElevatedButton(
                onPressed: () => {stopTimer()}, child: Text("Cancel"))
          ],
        ),
      ),
    );
  }
}

// class Countdown extends AnimatedWidget {
//   Countdown({super.key, required this.animation, required this.interval, required this.startTimeInSeconds}) : super(listenable: animation);
//   Animation<int> animation;
//   int interval;
//   int startTimeInSeconds;
//   @override
//   build(BuildContext context) {
//     Duration clockTimer = Duration(seconds: animation.value);

//     String timerText =
//         '${clockTimer.inHours.remainder(60).toString().padLeft(2, '0')}:${clockTimer.inMinutes.remainder(60).toString().padLeft(2, '0')}:${clockTimer.inSeconds.remainder(60).toString().padLeft(2, '0')}';

//     // print('startTimeInSeconds ${startTimeInSeconds}');
//     // print('interval ${interval}');
//     print('animation.value  ${animation.value} ');
//     // print('inMinutes ${clockTimer.inMinutes.toString()}');
//     // print('inSeconds ${clockTimer.inSeconds.toString()}');
//     // print('inSeconds.remainder ${clockTimer.inSeconds.remainder(60).toString()}');

//     if ((startTimeInSeconds - animation.value) % interval == 0)
//     {
//       print("INTERVAL MET");
//     }

//     return Text(
//       "$timerText",
//       style: TextStyle(
//         fontSize: 60,
//         color: Theme.of(context).primaryColor,
//       ),
//     );
//   }
// }