import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/material.dart';
import 'package:fluttery/gestures.dart';
import 'package:music_app/models/FavouriteModel.dart';
import 'package:music_app/util/DatabaseManager.dart';

import '../GlobalStateStore.dart';

class PlaySong extends StatefulWidget {
  int index;
  int check;
  PlaySong(this.index, this.check);

  @override
  _PlaySongState createState() => _PlaySongState(index, check);
}

class _PlaySongState extends State<PlaySong> with TickerProviderStateMixin {
  int _index;
  int checkSong;
  _PlaySongState(this._index, this.checkSong);

  GlobalStateStore _store = GlobalStateStore.ins;

  // ------------------------------- VARIABLES -------------------------------
  int tempM;
  int tempS;

  List<Song> _songs = List<Song>();
  MusicFinder audioPlayer;

  bool isPlaying = true;
  String _title, _album, _img, _url, _artist;
  int _duration;

  int minutes;
  int seconds;

  Timer _timer;
  var check = false;

  double _seekPercent = 0.0;
  PolarCoord _startDragCoord;
  double _startDragPercent;
  double _currentDragPercent;

  List<FavouriteModel> listSongs = List();
  DatabaseManager database = DatabaseManager();
  List<int> indexList = List();

  // To Play progress bas
  bool checkProgress = true;

  // ------------------------------- PREPARE SONGS -------------------------------
  initSongs() async {
    audioPlayer = MusicFinder();
    List<Song> songs = await MusicFinder.allSongs();
    songs = List.from(songs);

    await database.getAllSongs().then((songs) {
      setState(() {
        songs.forEach((song) {
          listSongs.add(FavouriteModel.fromMap(song));
          indexList.add(song['indexCol']);
        });
      });
    });

    setState(() {
      _songs = songs;
      initVariables(_index, isPlaying);
      _store.set("isPlaying", isPlaying);
    });

    print('listSongs ${listSongs[1].title}');
    print('listSongs ${indexList}');
  }

  Future _playLocal(String url) async {
    final result = await audioPlayer.play(url, isLocal: true);
    print('result $result');
  }

  pause() async {
    final result = await audioPlayer.pause();
    _timer.cancel();
  }

  stop() async {
    final result = await audioPlayer.stop();
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

  @override
  void didUpdateWidget(PlaySong oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    _store.set("isPlaying", isPlaying);
  }

  // ------------------------------- EXTRACT SONG'S DETAILS  -------------------------------
  initVariables(int index, bool check) {
    setState(() {
      if (_timer != null) _timer.cancel();

      _seekPercent = 0.0;
      stop();
      if (checkSong == 1) {
        _index = index;
        _title = _songs[index].title;
        _album = _songs[index].album;
        _img = _songs[index].albumArt;
        _url = _songs[index].uri;
        _artist = _songs[index].artist;
        _duration = _songs[index].duration;
      } else {
        var index2 = indexList.indexOf(index);
        print('listSongs index: $index2');
        _index = index2;
        _title = listSongs[index2].title;
        _album = listSongs[index2].album;
        _img = listSongs[index2].img;
        _url = listSongs[index2].url;
        _artist = listSongs[index2].artist;
        _duration = listSongs[index2].duration;
      }
      int dur = _duration ~/ 1000;
      print('Dur $dur');

      if (dur >= 60) {
        minutes = dur ~/ 60;
        seconds = dur - (minutes * 60);
      } else {
        seconds = dur;
        minutes = 0;
      }

      print('Seconds $seconds');

      tempM = minutes;
      tempS = seconds;

      isPlaying = check;
      checkPlaying();

      Future.delayed(Duration(seconds: 1));
      checkProgress = false;
    });
  }

  next() {
    setState(() {
      isPlaying = true;
      _seekPercent = 0.0;
      stop();
      if (checkSong == 1) {
        if (_index != _songs.length - 1)
          initVariables(_index + 1, isPlaying);
        else
          initVariables(0, isPlaying);
      } else {
        if (_index != listSongs.length - 1)
          initVariables(indexList[_index + 1], isPlaying);
        else
          initVariables(indexList.first, isPlaying);
      }
    });
  }

  previous() {
    setState(() {
      isPlaying = true;
      _seekPercent = 0.0;
      stop();
      if (checkSong == 1) {
        if (_index > 0)
          initVariables(_index - 1, isPlaying);
        else
          initVariables(_songs.length - 1, isPlaying);
      } else {
        if (indexList[_index] > indexList.first)
          initVariables(indexList[_index - 1], isPlaying);
        else
          initVariables(indexList.last, isPlaying);
      }
    });
  }

  checkPlaying() {
    setState(() {
      if (isPlaying) {
        _playLocal(_url);
        startTimer();
      } else {
        pause();
      }
      isPlaying = !isPlaying;
    });
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) => setState(
        () {
          if (tempS < 1) {
            if (tempM >= 1) {
              tempM -= 1;
              tempS += 59;
            } else {
              timer.cancel();
              isPlaying = true;
              _seekPercent = 0.0;
              if (_index == _songs.length - 1)
                initVariables(0, isPlaying);
              else
                initVariables(_index + 1, isPlaying);
              print('IsPlaying: $isPlaying');
            }
          } else {
            tempS = tempS - 1;
            var durationInSeconds = _duration / 1000;
            var seekPerSecond = 1 / durationInSeconds;
            if (!check) {
              _seekPercent = seekPerSecond;
              check = true;
            }
            _seekPercent += seekPerSecond;
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _timer.cancel();
    super.dispose();
  }

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
      //Seek Audio
      audioPlayer.seek(seekval);

      int durationInSeconds = _duration ~/ 1000;
      double currentDurationInSeconds = _seekPercent * durationInSeconds;
      int currentMinutes = currentDurationInSeconds ~/ 60;
      int currentSeconds =
          (currentDurationInSeconds - (currentMinutes * 60)).round();

      tempM = minutes;
      tempS = seconds;
      tempM -= currentMinutes;
      tempS -= currentSeconds;

      if (tempS < 0) {
        tempS += 60;
        tempM -= 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Music Player"),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: checkProgress
          ? Center(child: CircularProgressIndicator(),)
          : Stack(
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
                              child: RadialSeekBar(
                                //TODO
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
                              )),
                        ),
                      ),
                    )),

                    //
                    Container(
                        padding: const EdgeInsets.only(top: 40.0, bottom: 80.0),
                        child: Column(
                          children: <Widget>[
                            RichText(
                                text: TextSpan(
                                    text: tempM < 10
                                        ? tempS < 10
                                            ? '0$tempM:0$tempS'
                                            : '0$tempM:$tempS'
                                        : tempS < 10
                                            ? '$tempM:0$tempS'
                                            : '$tempM:$tempS',
                                    style: TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white))),
                            Padding(padding: const EdgeInsets.only(top: 12.0)),
                            Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: RichText(
                                    textAlign: TextAlign.center,
                                    text: TextSpan(
                                        text: _title,
                                        style: TextStyle(
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white)))),
                            Padding(padding: const EdgeInsets.only(top: 12.0)),
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: RichText(
                                  text: TextSpan(
                                      text: _artist,
                                      style: TextStyle(
                                          fontSize: 22.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white))),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 25.0),
                            ),
                            Row(
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
                                      padding:
                                          const EdgeInsets.only(bottom: 25.0),
                                      icon: Icon(
                                          isPlaying
                                              ? Icons.play_circle_filled
                                              : Icons.pause_circle_filled,
                                          size: 85.0,
                                          color: Colors.greenAccent),
                                      onPressed: () {
                                        checkPlaying();
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
          thumbPosition: widget.thumbPosition),
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

  RadialSeekBarPainter({
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
        thumbPaint = Paint()..color = thumbColor;

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
    canvas.drawCircle(center, radius, trackPaint);

// Paint the track
    canvas.drawCircle(
      center,
      radius2,
      Paint()
        ..color = Colors.grey.withOpacity(0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = trackWidth,
    );

    final progressAngle = 2 * pi * progressPercent;

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
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }
}
