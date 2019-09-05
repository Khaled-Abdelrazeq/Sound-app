import 'dart:io';

import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/material.dart';

class PlayingView extends StatefulWidget {
  String title;
  String url;
  String artist;
  int duration;
  String img;

  PlayingView({this.title, this.url, this.artist, this.duration, this.img});

  @override
  _PlayingViewState createState() => _PlayingViewState(title: title, url: url, artist: artist, duration: duration, img: img);
}

class _PlayingViewState extends State<PlayingView> {

  String title;
  String url;
  String artist;
  int duration;
  String img;
  _PlayingViewState({this.title, this.url, this.artist, this.duration, this.img});

  MusicFinder audioPlayer;

  Future _playLocal(String url) async {
    final result = await audioPlayer.play(url, isLocal: true);
    print('result $result');
  }

  pause() async {
    final result = await audioPlayer.pause();
  }

  stop() async {
    final result = await audioPlayer.stop();
  }

  // seek 5 seconds from the beginning
  seek(double duration) async {
    audioPlayer.seek(duration);
  }

  File file;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    audioPlayer = MusicFinder();
    _playLocal(url);

   file = new File(img);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Title $title"),
            Text("URL $url"),
            Text("Artist $artist"),
            Text("Duration $duration"),
            Text("Album $img"),
            Image.file(file),
            Icon(Icons.playlist_play),
//            Image.network(img),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(icon: Icon(Icons.move_to_inbox), onPressed: () => seek(-5.0)),
                IconButton(icon: Icon(Icons.play_arrow), onPressed: () => _playLocal(url)),
                IconButton(icon: Icon(Icons.pause), onPressed: () => pause()),
                IconButton(icon: Icon(Icons.stop), onPressed: () => stop()),
                IconButton(icon: Icon(Icons.move_to_inbox), onPressed: () => seek(5.0)),

              ],
            )
          ],
        ),
      ),
    );
  }
}
