import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class CountdownTimerScreen extends StatefulWidget {
  final bool isGreen;


  CountdownTimerScreen({
    required this.isGreen
  });

  @override
  _CountdownTimerScreenState createState() => _CountdownTimerScreenState();
}

class _CountdownTimerScreenState extends State<CountdownTimerScreen> with TickerProviderStateMixin{
  AnimationController? _controller;
  AnimationStatus? status;
  bool? startTrack = false;
  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
    _timer();


  }

  @override
  void dispose() {
    super.dispose();
    _controller!.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            widget.isGreen
                ? "assets/images/bg_countdown_timer_green.webp"
                : "assets/images/bg_countdown_timer_blue.webp",
            fit: BoxFit.cover,
          ),
          Lottie.asset(
            widget.isGreen
                ? 'assets/animation/countdown_green.json'
                : 'assets/animation/countdown_blue.json',
            width: 100,
            controller: _controller,
            height: 150,
            repeat: false,
            onLoaded: (composition) {
              _controller!
                ..duration = composition.duration
                ..forward();

            },
          )
        ],
      ),
    );
  }

  void _timer() {
    startTrack = true;
    _controller!.addListener(() => setState(() {}));
    TickerFuture tickerFuture = _controller!.forward();
    tickerFuture.timeout(Duration(milliseconds: 3800), onTimeout:  () {
      _controller!.forward(from: 0);
      _controller!.stop(canceled: true);

      Navigator.pop(context);
    });
  }
}
