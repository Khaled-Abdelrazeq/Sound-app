import 'package:flutter/material.dart';
import 'dart:math';

class AppHome extends StatefulWidget {
  @override
  _AppHomeState createState() => _AppHomeState();
}

class _AppHomeState extends State<AppHome> with TickerProviderStateMixin{
  AnimationController _animationController;

  String get timeString{
    Duration duration = _animationController.duration * _animationController.value;
    return '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _animationController = AnimationController(vsync: this, duration: Duration(seconds: 20));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(padding: EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          Expanded(
            child: Align(
              alignment: FractionalOffset.center,
              child: AspectRatio(aspectRatio: 1.0,
              child: Stack(
                children: <Widget>[
                  Positioned.fill(child: AnimatedBuilder(animation: _animationController,
                      builder:(BuildContext context, Widget child){
                    return CustomPaint(
                      painter: TimerPainter(
                        animation: _animationController,
                        backgroundColor: Colors.white,
                        color: Colors.pinkAccent,
                      ),
                    );
                      }
                  )),
                  Align(
                    alignment: FractionalOffset.center,
                    child: Column(
                      children: <Widget>[
                        Padding(padding: EdgeInsets.only(top: 60.0)),
                        Text("CountDown",style:  TextStyle(fontSize: 20.0),),
                        Padding(padding: EdgeInsets.only(top: 150.0)),
                        AnimatedBuilder(animation: _animationController, builder: (BuildContext context, Widget child){
                          return Text(timeString, style: TextStyle(fontSize: 35.0),);
                        })
                      ],
                    ),
                  )
                ],
              ),),
            ),
          ),

          Container(
            margin: EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                FloatingActionButton(
                  child: AnimatedBuilder(animation: _animationController, builder: (BuildContext context, Widget child){
                    return Icon(_animationController.isAnimating? Icons.pause: Icons.play_circle_filled);
                  }),
                    onPressed: (){
                    if(_animationController.isAnimating)
                      _animationController.stop();
                    else
                      _animationController.reverse(from: _animationController.value == 0.0? 1.0: _animationController.value);
                    }
                )
              ],
            ),
          )

        ],
      ),),

    );
  }
}

class TimerPainter extends CustomPainter{

  TimerPainter({
    this.animation,
    this.backgroundColor,
    this.color,
}) : super(repaint: animation);

  final Animation<double> animation;
  final Color backgroundColor, color;


  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
        ..color = backgroundColor
        ..strokeWidth = 5.0
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
    
    canvas.drawCircle(size.center(Offset.zero), size.width / 2.0, paint);
    paint.color = color;
    double progress = (1.0 - animation.value) * 2 * pi;
    canvas.drawArc(Offset.zero & size, pi * 1.5, progress , false, paint);
  }

  @override
  bool shouldRepaint(TimerPainter old) {
    // TODO: implement shouldRepaint
    return animation.value != old.animation.value || color != old.color || backgroundColor != old.backgroundColor;
  }

}