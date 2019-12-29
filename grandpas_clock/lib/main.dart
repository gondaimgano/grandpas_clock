import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:provider/provider.dart';

import 'package:vector_math/vector_math.dart' as math;


const backgroundColor=Color.fromRGBO(6, 24, 19, 1);
const accentColor=Color.fromRGBO(211,238,232, 1);

const backgroundColor1=Color.fromRGBO(62, 145, 247, 1);
const accentColor1=Color.fromRGBO(233,248,253, 1);


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);

  return runApp(Root());
}

String _addLeadingZeroIfNeeded(int value) {
  if (value < 10) return '0$value';
  return value.toString();
}

String _timer({String m, Function toggle}) {
  toggle();
  return m ??
      "${_addLeadingZeroIfNeeded(TimeOfDay.now().hour)}:${_addLeadingZeroIfNeeded(TimeOfDay.now().minute)}:${_addLeadingZeroIfNeeded(DateTime.now().second)}";
}

class Root extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      StreamProvider<String>(
        create: (_) => Stream.periodic(
            Duration(milliseconds: 400),
            (d) =>
                "${_addLeadingZeroIfNeeded(TimeOfDay.now().hour)}:${_addLeadingZeroIfNeeded(TimeOfDay.now().minute)}:${_addLeadingZeroIfNeeded(DateTime.now().second)}"),
      ),
    ], child: MyClockApp());
  }
}

class MyClockApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Clock Face',
      theme: ThemeData.light().copyWith(
      ),
      home: ClockFace(title: '''Gondai's Clock Competition'''),
    );
  }
}

class ClockFace extends StatefulWidget {
  ClockFace({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _ClockFaceState createState() => _ClockFaceState();
}

class _ClockFaceState extends State<ClockFace>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  double oscillate() =>
      lerpDouble(-30.0, 30.0, Curves.bounceInOut.transform(_controller.value));

  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 3000));
    super.initState();
  }

  String _timeHHmmOnly(String s)
  {
   s= s??"${_addLeadingZeroIfNeeded(TimeOfDay.now().hour)}:${_addLeadingZeroIfNeeded(TimeOfDay.now().minute)}:${_addLeadingZeroIfNeeded(DateTime.now().second)}";

    var l= s.split(":");
    l.removeLast();
    return l.join(":");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor1,
      body: Container(
        alignment: Alignment.center,
        child: Consumer<String>(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) => Container(
              width: 150,
              height: 150,
              child: CustomPaint(
                painter: ClockPainter(
                  value: oscillate(),
                ),
              ),
            ),
          ),
          builder: (context, time, child) => AspectRatio(
            aspectRatio: 1.3,
            child: FittedBox(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(height: 12,),
                  child,
                  Text(
                    _timer(
                        m: _timeHHmmOnly(time),
                        toggle: () {
                          bool iscomplete = false;
                          if (_controller != null) {
                            iscomplete =
                                _controller.status == AnimationStatus.completed;
                            _controller.fling(
                                velocity: iscomplete ? -2: 2);
                          }
                        }),
                    style: GoogleFonts.pressStart2P(fontSize: 25,textStyle: TextStyle(color:accentColor1) ),
                  ),
                  SizedBox(height: 12,),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ClockPainter extends CustomPainter {
  ClockPainter({this.value});

  final double value;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt
      ..color = accentColor1;

    Paint spot = Paint()
      ..strokeWidth = 2.0
      ..style = PaintingStyle.fill
      ..color = accentColor1;

    canvas.save();
    canvas.translate(size.width * 0.5, size.height * 0.1);

    canvas.rotate(math.radians(value ?? 0));
    canvas.drawLine(Offset(0, 0), Offset(0, size.height * 0.46), paint);
    canvas.drawCircle(Offset(0, 0), size.width * 0.03, spot);
    canvas.drawCircle(Offset(0, size.width * 0.5), size.width * 0.08, spot);
    canvas.drawCircle(Offset(0, size.width * 0.35), size.width * 0.05, spot);
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return this != oldDelegate;
  }
}
