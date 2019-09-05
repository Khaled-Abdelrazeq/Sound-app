import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/material.dart';
import 'package:fluttery/gestures.dart';

class HomeApp extends StatefulWidget {
  @override
  _HomeAppState createState() => _HomeAppState();
}

class _HomeAppState extends State<HomeApp> with TickerProviderStateMixin {
  AnimationController _animationController;

  int dur;

  String get timeString {
    Duration duration =
        _animationController.duration * _animationController.value;
    return '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  List<Song> _songs = List<Song>();
  MusicFinder audioPlayer;
  bool isPlaying = false;

  initSongs() async {
    audioPlayer = MusicFinder();
    List<Song> songs = await MusicFinder.allSongs();
    songs = List.from(songs);

    setState(() {
      _songs = songs;
//      print('songs: $songs');
      if (_index == null) {
        initVariables(0, isPlaying);
      }
    });
  }

  Future _playLocal(String url) async {
    final result = await audioPlayer.play(url, isLocal: true);
    print('result $result');
  }

  pause() async {
    final result = await audioPlayer.pause();
  }

  stop() async {
    final result = await audioPlayer.stop();
//    _timer.cancel();
  }

  // seek 5 seconds from the beginning
  seek() async {
    audioPlayer.seek(5.0);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initSongs();

  }

  String _title, _album, _img, _url, _artist;
  int _duration;

  int minutes;
  int seconds;

  int _index;

  initVariables(int index, bool check) {
    setState(() {
      _seekPercent = 0.0;
      stop();
      _index = index;
      _title = _songs[index].title;
      _album = _songs[index].album;
      _img = _songs[index].albumArt;
      _url = _songs[index].uri;
      _artist = _songs[index].artist;
      _duration = _songs[index].duration;

      dur = _duration ~/ 1000;

      _animationController =
          AnimationController(vsync: this, duration: Duration(seconds: dur));

      checkPlaying();
    });
  }

  checkPlaying() {
    setState(() {
      if (isPlaying){
        _playLocal(_url);
      }
      else {
        pause();
//        _timer.cancel();
      }
      isPlaying = !isPlaying;
    });
  }


  next() {
    setState(() {
      _seekPercent = 0.0;
      stop();
      if (_index != _songs.length - 1) initVariables(_index + 1, true);
//        print('${_index+1}');
    });
  }

  previous() {
    setState(() {
      _seekPercent = 0.0;
      stop();
      if (_index != 0) initVariables(_index - 1, true);
    });
  }



  var duration;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  double _seekPercent = 0.0;
  PolarCoord _startDragCoord;
  double _startDragPercent;
  double _currentDragPercent;

  _onRadialDragStart(PolarCoord coor) {
    _startDragCoord = coor;
    _startDragPercent = _seekPercent;
  }

  _onRadialDragUpdate(PolarCoord coor) {
    final dragAngle = coor.angle - _startDragCoord.angle;
    final dragPercent = dragAngle / (2 * pi);

    setState(() {
      _currentDragPercent = (_startDragPercent + dragPercent) % 1.0;
    });
  }

  _onRadialDragEnd() {
    setState(() {
      _seekPercent = _currentDragPercent;
      _currentDragPercent = null;
      _startDragCoord = null;
      _startDragPercent = 0.0;

      var seekval = (_seekPercent * (_duration / 1000));
      print('seekPercentage: $seekval');
      //Seek Audio
      audioPlayer.seek(seekval);

//      var dr = _duration /100000;
//
//      var durationInSeconds = dr * seekval ;
//      print('durationInSeconds2 $durationInSeconds');
//
//      if(durationInSeconds >= 60) {
//        minutes = durationInSeconds ~/ 60;
//        seconds = (durationInSeconds - (minutes * 60)) ~/ 1 ;
//      }else{
//        seconds = durationInSeconds ~/ 1;
//        minutes = 0;
//      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Music Player"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        elevation: 0.0,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          _img == null
              ? Image.asset("images/bg.jpg",
                  fit: BoxFit.fill,
                  color: Colors.black54,
                  colorBlendMode: BlendMode.darken)
              : Image.file(File(_img),
                  fit: BoxFit.fill,
                  color: Colors.black54,
                  colorBlendMode: BlendMode.darken),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              //

              Expanded(
                  child: RadialDragGestureDetector(
                onRadialDragStart: _onRadialDragStart,
                onRadialDragUpdate: _onRadialDragUpdate,
                onRadialDragEnd: _onRadialDragEnd,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.transparent,
                  child: Center(
                    child: Container(
                        width: 220.0,
                        height: 220.0,
                        child: AnimatedBuilder(
                            animation: _animationController,
                            builder: (BuildContext context, Widget child) {
                              return RadialSeekBar(
                                //TODO
                                animation: _animationController,
                                progressPercent:
                                    _currentDragPercent ?? _seekPercent,
                                thumbPosition:
                                    _currentDragPercent ?? _seekPercent,
                                child: ClipOval(
                                  clipper: CirlceClipper(),
                                  child: _img == null
                                      ? Image.asset(
                                          "images/bg.jpg",
                                          fit: BoxFit.fill,
                                        )
                                      : Image.file(
                                          File(_img),
                                          fit: BoxFit.fill,
                                        ),
                                ),
                              );
                            })),
                  ),
                ),
              )),
              AnimatedBuilder(animation: _animationController, builder: (BuildContext context, Widget child){
                return Text(timeString, style: TextStyle(fontSize: 35.0),);
              }),
              //
              Container(
                  padding: const EdgeInsets.only(top: 40.0, bottom: 80.0),
                  child: Column(
                    children: <Widget>[
                      RichText(
                          text: TextSpan(
                              text: '$minutes:$seconds',
                              style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white))),
                      Padding(padding: const EdgeInsets.only(top: 12.0)),
                      RichText(
                          text: TextSpan(
                              text: '$seconds',
                              style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white))),
                      Padding(padding: const EdgeInsets.only(top: 12.0)),

                      RichText(
                          text: TextSpan(
                              text: _title,
                              style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white))),
                      Padding(padding: const EdgeInsets.only(top: 12.0)),
                      RichText(
                          text: TextSpan(
                              text: _artist,
                              style: TextStyle(
                                  fontSize: 22.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white))),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 25.0),
                      ),

//                LinearProgressIndicator(
//                  value: animation.value?? 0.0 ,
//                ),

                      Row(
                        //                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Expanded(
                            child: IconButton(
                                padding: const EdgeInsets.only(top: 20.0),
                                icon: Icon(Icons.skip_previous,
                                    size: 40.0, color: Colors.white),
                                onPressed: () => previous()),
                          ),
                          Expanded(
                            child: IconButton(
                                padding: const EdgeInsets.only(bottom: 25.0),
                                icon: Icon(
                                    isPlaying
                                        ? Icons.play_circle_filled
                                        : Icons.pause_circle_filled,
                                    size: 85.0,
                                    color: Colors.greenAccent),
                                onPressed: () {
                                  //TODO PLAY BUTTON
//                            checkPlaying();
                                  if (_animationController.isAnimating)
                                    _animationController.stop();
                                  else
                                    _animationController.reverse(
                                        from: _animationController.value == 0.0
                                            ? 1.0
                                            : _animationController.value);
                                }),
                          ),
                          Expanded(
                            child: IconButton(
                                padding: const EdgeInsets.only(top: 25.0),
                                icon: Icon(Icons.skip_next,
                                    size: 40.0, color: Colors.white),
                                onPressed: () => next()),
                          ),
                        ],
                      ),
                    ],
                  )),
            ],
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView.builder(
          itemCount: _songs.length == null ? 0 : _songs.length,
          itemBuilder: (context, int index) {
            return ListTile(
                title: Text(_songs[index].title),
                leading: CircleAvatar(
                  child: Text(_songs[index].title[0]),
                  backgroundColor: Colors.deepPurple,
                ),
                onTap: () {
                  initVariables(index, true);
                  Navigator.pop(context);
                });
          },
        ),
      ),
    );
  }
}

class CirlceClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) {
    // TODO: implement getClip
    return Rect.fromCircle(
        center: Offset(size.width / 2, size.height / 2),
        radius: min(size.width, size.height) / 2);
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) {
    // TODO: implement shouldReclip
    return true;
  }
}

class RadialSeekBar extends StatefulWidget {
  final double trackWidth;
  final Color rackColor;
  final double progressWidth;
  final Color progressColor;
  final double progressPercent;
  final double thumbWidth;
  final Color thumbColor;
  final double thumbPosition;
  final Widget child;
  final Animation<double> animation;

  RadialSeekBar({
    this.trackWidth = 3.0,
    this.rackColor = Colors.grey,
    this.progressWidth = 5.0,
    this.progressColor = Colors.redAccent,
    this.progressPercent = 0.0,
    this.thumbWidth = 10.0,
    this.thumbColor = Colors.redAccent,
    this.thumbPosition = 0.0,
    this.child,
    this.animation,
  });

  @override
  _RadialSeekBarState createState() => _RadialSeekBarState();
}

class _RadialSeekBarState extends State<RadialSeekBar> {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      child: widget.child,
      foregroundPainter: RadialSeekBarPainter(
          trackWidth: widget.trackWidth,
          rackColor: widget.rackColor,
          progressWidth: widget.progressWidth,
          progressColor: widget.progressColor,
          progressPercent: widget.progressPercent,
          thumbWidth: widget.thumbWidth,
          thumbColor: widget.thumbColor,
          thumbPosition: widget.thumbPosition,
          animation: widget.animation),
    );
  }
}

class RadialSeekBarPainter extends CustomPainter {
  final double trackWidth;
  final Paint trackPaint;
  final double progressWidth;
  final Paint progressPaint;
  final double progressPercent;
  final double thumbWidth;
  final Paint thumbPaint;
  final double thumbPosition;
  final Animation<double> animation;

  RadialSeekBarPainter({
    @required this.animation,
    @required this.trackWidth,
    @required rackColor,
    @required this.progressWidth,
    @required progressColor,
    @required this.progressPercent,
    @required this.thumbWidth,
    @required thumbColor,
    @required this.thumbPosition,
  })  : trackPaint = Paint()
          ..color = rackColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = trackWidth,
        progressPaint = Paint()
          ..color = progressColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = progressWidth
          ..strokeCap = StrokeCap.round,
        thumbPaint = Paint()..color = thumbColor,
        super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    // Amount of space between container and seekBar
    final outerThickness = max(trackWidth, max(progressWidth, thumbWidth));
    Size constrainedSize = Size(
        size.width + 1.5 * outerThickness, size.height + 1.5 * outerThickness);

    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(constrainedSize.width, constrainedSize.height) / 2;
    final radius2 = min(size.width, size.height) / 2;

    // TODO: implement paint


    // Paint the track
    canvas.drawCircle(size.center(Offset.zero), size.width / 2.0, trackPaint);

// Paint the track
    canvas.drawCircle(
      center,
      radius2,
      Paint()
        ..color = Colors.grey.withOpacity(0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = trackWidth,
    );

    final progressAngle = 2 * pi * (1 - animation.value);

    // Paint the progress
    canvas.drawArc(
        //rect,
        Rect.fromCircle(
          center: center,
          radius: radius,
        ),
        -pi / 2, //startAngle,
        progressAngle, //sweepAngle,
        false,
        progressPaint);

    // ده الدايره الصغيره اللي هتدل ع الحركه
    // هتجيب الcenter عادي وتضضيف عليه الـ offset بتاع المكان اللى هو نص القطؤ بس ف انهي اتجاه بقي

    final thumbAngle = 2 * pi * thumbPosition - (pi / 2);
    final thumbX = cos(thumbAngle) * radius;
    final thumbY = sin(thumbAngle) * radius;
    final thumbCenter = Offset(thumbX, thumbY) + center;
    final thumbRadius = thumbWidth / 2;

    // Paint the thumb
    canvas.drawCircle(thumbCenter, thumbRadius, thumbPaint);
  }

  @override
  bool shouldRepaint(RadialSeekBarPainter old) {
    // TODO: implement shouldRepaint
    return animation.value != old.animation.value;
  }
}
