import 'package:flutter/material.dart';

class SoundWaveAnimation extends StatefulWidget {
  final bool isRecording;

  const SoundWaveAnimation({Key? key, required this.isRecording})
      : super(key: key);

  @override
  State<SoundWaveAnimation> createState() => _SoundWaveAnimationState();
}

class _SoundWaveAnimationState extends State<SoundWaveAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;
  late List<double> _dotHeights;

  int dotCount = 18;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );

    _dotHeights = List.generate(dotCount, (index) => 20.0);

    _animations = List.generate(dotCount, (index) {
      return TweenSequence<double>([
        TweenSequenceItem(
          tween: Tween<double>(
            begin: _dotHeights[index],
            end: _dotHeights[index] + 25.0,
          ),
          weight: 1.0,
        ),
        TweenSequenceItem(
          tween: Tween<double>(
            begin: _dotHeights[index] + 25.0,
            end: _dotHeights[index],
          ),
          weight: 1.0,
        ),
      ]).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            index / dotCount,
            (index + 1) / dotCount,
            curve: Curves.easeInOut,
          ),
        ),
      );
    });

    _controller.addListener(() {
      for (int i = 0; i < dotCount; i++) {
        _dotHeights[i] = _animations[i].value;
      }
      setState(() {});
    });
  }

  // Method to reset the animation to its initial state
  void resetAnimation() {
    _controller.stop();
    _controller.reset();
    for (int i = 0; i < dotCount; i++) {
      _dotHeights[i] = 20.0; // Set initial height value
    }
    setState(() {});
  }

  @override
  void didUpdateWidget(SoundWaveAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if the recording state has changed
    if (widget.isRecording) {
      _controller.repeat();
    } else {
      _controller.stop();
      resetAnimation(); // Call the reset method when not recording
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 75, // Set a fixed height for SoundWaveAnimation
      child: SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(dotCount, (index) {
              return SizedBox(
                height: _dotHeights[index],
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  constraints: BoxConstraints(
                    minWidth: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(35),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
