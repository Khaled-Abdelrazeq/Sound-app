import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/material.dart';
import 'package:music_app/util/GlobalVariables.dart';
import 'MusicApp/AllSongs.dart';
import 'MusicApp/Home.dart';
import 'PlayingView.dart';

void main() {
  bool checkThemeDark = GlobalVariables.checkThemeDark;
//  runApp(
//      MaterialApp(
//    theme: GlobalVariables.themeData,
//    title: "Music Player",
//    debugShowCheckedModeBanner: false,
//  home: AllSongs()
//  ));
    runApp(Home(true));
}
