import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock/wakelock.dart';

void main() => runApp(ContextClickerApp());

class ContextClickerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setEnabledSystemUIOverlays([]);
    return MaterialApp(
      title: 'Context Clicker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ContextClickerPage(),
    );
  }
}

class ContextClickerPage extends StatefulWidget {
  ContextClickerPage({
    Key key,
  }) : super(key: key);

  static const List<Color> defaultColors = [
    Colors.yellowAccent,
    Colors.redAccent,
    Colors.cyanAccent,
    Colors.greenAccent,
    Colors.deepPurpleAccent,
  ];

  @override
  _ContextClickerPageState createState() => _ContextClickerPageState();
}

class _ContextClickerPageState extends State<ContextClickerPage> {
  int _contextDepth = 0;

  AudioPlayer _audioPlayer;
  Timer _timer;
  Color _currentColor = Colors.yellowAccent;
  Brightness _currentBrightness = Brightness.light;

  initState() {
    super.initState();
    Wakelock.enable();
    _timer = Timer.periodic(Duration(seconds: 4), (Timer t) => doClicks());
  }

  Future<void> doClicks() async {
    if (_contextDepth < 1) {
      return;
    }
    randomNewColor();
    for (int i = 0; i < _contextDepth; i++) {
      _audioPlayer = await AudioCache().play("sounds/click.mp3");
      if (i < _contextDepth - 1) {
        await new Future.delayed(Duration(milliseconds: 100));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      resizeToAvoidBottomPadding: false,
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              color: _currentColor,
              child: Center(
                  child: Text("snap out of it",
                      style: Theme.of(context)
                          .textTheme
                          .display1
                          .copyWith(color: _currentBrightness == Brightness.light ? Colors.black : Colors.white, fontSize: 50))),
            ),
          ),
          Expanded(
            child: IntrinsicHeight(
              child: Stack(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      IncrementDecrementButton(
                          icon: Icons.add,
                          color: Colors.white,
                          callback: onIncrement),
                      IncrementDecrementButton(
                          icon: Icons.remove,
                          color: Colors.black,
                          brightness: Brightness.dark,
                          callback: onDecrement)
                    ],
                  ),
                  IgnorePointer(
                    child: Center(
                        child: Card(
                            color: _currentColor,
                            elevation: 0,
                            shape: StadiumBorder(),
                            child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 32.0),
                                child: Text(
                                  this._contextDepth.toString(),
                                  style: TextStyle(
                                      fontSize: 84,
                                      fontFamily: "monospace",
                                      color: _currentBrightness == Brightness.light ? Colors.black : Colors.white),
                                )))),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void randomNewColor() {
    setState(() {
      _currentColor = ContextClickerPage.defaultColors[Random().nextInt(ContextClickerPage.defaultColors.length)];
      _currentBrightness = _currentColor.computeLuminance() > 0.3 ? Brightness.light : Brightness.dark;
    });
  }

  void onDecrement() {
//    audioPlayer.play()
    setState(() {
      _contextDepth = max(_contextDepth - 1, 0);
      if (_contextDepth == 0) {
        _currentBrightness = Brightness.light;
        _currentColor = Colors.grey;
      }
    });
  }

  void onIncrement() {
    setState(() {
      _contextDepth = min(_contextDepth + 1, 9);
      randomNewColor();
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _timer.cancel();
    Wakelock.disable();
    super.dispose();
  }
}

class IncrementDecrementButton extends StatelessWidget {
  IconData _icon;
  Color _color;
  Brightness _brightness;
  Function _callback;

  IncrementDecrementButton(
      {IconData icon,
      Color color,
      Brightness brightness = Brightness.light,
      Function callback})
      : _icon = icon,
        _color = color,
        _brightness = brightness,
        _callback = callback;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: _color,
        child: InkWell(
          child: Icon(
            _icon,
            color:
                _brightness == Brightness.light ? Colors.black : Colors.white,
            size: 80,
          ),
          onTap: _callback,
        ),
      ),
    );
  }
}
