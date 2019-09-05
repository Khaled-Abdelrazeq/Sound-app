import 'package:flutter/material.dart';
import 'package:music_app/util/GlobalVariables.dart';

import 'AllSongs.dart';
import 'Favourite.dart';

class Home extends StatefulWidget {
  bool check;
  Home(this.check);

  @override
  _HomeState createState() => _HomeState(check);
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {

  bool check;
  _HomeState(this.check);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: GlobalVariables.themeData,
      title: "Music Player",
      home: check? AllSongs() : Favourite()
    );
  }
}

