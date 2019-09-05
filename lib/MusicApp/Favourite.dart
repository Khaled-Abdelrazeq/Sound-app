import 'dart:io';
import 'dart:math';

import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/material.dart';
import 'package:music_app/models/FavouriteModel.dart';
import 'package:music_app/util/DatabaseManager.dart';
import 'package:music_app/util/GlobalVariables.dart';
import 'package:music_app/util/MySlide.dart';

import '../GlobalStateStore.dart';
import 'AllSongs.dart';
import 'Home.dart';
import 'PlaySong.dart';

class Favourite extends StatefulWidget {
  @override
  _FavouriteState createState() => _FavouriteState();
}

class _FavouriteState extends State<Favourite> {
  // ------------------------------- VARIABLES -------------------------------

  MusicFinder audioPlayer;

  int _index;
  String _title, _album, _img, _url, _artist;
  int _duration;

  bool isPlayingCheck;
  GlobalStateStore _store = GlobalStateStore.ins;

  bool added;
  List<FavouriteModel> listSongs = List();
  DatabaseManager database = DatabaseManager();
  List<int> indexList = List();

  bool isCheckSwitch = GlobalVariables.checkThemeDark;
  bool progressIndeicatorcheck = false;
  // ------------------------------- PREPARE SONGS -------------------------------
  initSongs() async {
    audioPlayer = MusicFinder();
    await database.getAllSongs().then((songs) {
      setState(() {
        songs.forEach((song) {
          listSongs.add(FavouriteModel.fromMap(song));
          indexList.add(song['indexCol']);
        });
      });
    });
  }



  // ------------------------------- GOING TO PLAY SONG ACTIVITY -------------------------------
  _onClick(int index) {
    Route route = MySlideDuration2(widget: PlaySong(index, 2));
    Navigator.push(context, route);
  }


  void _deleteSong(BuildContext context, FavouriteModel favouriteModel, int index) async{
    setState(() async {
      var index2 = await indexList.elementAt(index);
      await database.deleteSong(favouriteModel.index).then((songs) {
        setState(() {
          indexList.remove(index2);
          listSongs.removeAt(index);
        });
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initSongs();
  }

  @override
  void didUpdateWidget(Favourite oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    if (_store.get("isPlaying") != null)
      isPlayingCheck = _store.get("isPlaying");
    else
      isPlayingCheck = false;

    print('isPlaying: $isPlayingCheck');
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Favourite"),
        centerTitle: true,
      ),
      body: Container(
        child: listSongs.length == 0
            ? Center(child: Text("Favourite is empty!"))
            : ListView.builder(
          itemCount: listSongs.length == null ? 0 : listSongs.length,
          itemBuilder: (context, int index) {
            return Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: ListTile(
                        title: Text(listSongs[index].title),
                        onTap: ()
                        {
                          var index2 = indexList[index];
                          _onClick(index2);
                        },
                        leading: ClipOval(
                          clipper: CirlceClipper(),
                          child: listSongs[index].img == null
                              ? Image.asset(
                            "images/bg.jpg",
                            fit: BoxFit.fill,
                            height: 50.0,
                            width: 50.0,
                          )
                              : Image.file(
                            File(listSongs[index].img),
                            fit: BoxFit.fill,
                            height: 50.0,
                            width: 50.0,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                        icon: Icon(Icons.favorite),
                        onPressed: () {
                          _deleteSong(context, listSongs[index], index);
                        }
                    ),
                  ],
                ),
                Divider(
                  height: 15.0,
                ),
              ],
            );
          },
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[

            UserAccountsDrawerHeader(
              accountName: Text("Songs app"),
              accountEmail: null,
              currentAccountPicture: ClipOval(
                  clipper: CirlceClipper(),
                  child:  Image.asset(
                    "images/bg.jpg",
                    fit: BoxFit.fill,
                    height: 50.0,
                    width: 50.0,
                  )
              ),

            ),
            ListTile(
              title: Text("All Songs"),
              leading: Icon(Icons.library_music),
              selected: false,
              onTap: () {
                Navigator.pop(context);
                Navigator.pop(context);

              }
            ),
            ListTile(
              title: Text("Favourite"),
              leading: Icon(Icons.favorite),
              selected: true,
            ),
            Divider(height: 15.0,),
            Padding(padding: EdgeInsets.only(top: 20.0)),
            IconButton(
              icon: progressIndeicatorcheck? Center(child: CircularProgressIndicator(),) : Icon( GlobalVariables.checkThemeDark? Icons.brightness_2: Icons.brightness_5),
              onPressed: onPressedButton,
            )
          ],
        ),
      ),
    );
  }

  onPressedButton(){
    setState(() {
      progressIndeicatorcheck = true;
      isCheckSwitch = !isCheckSwitch;
      GlobalVariables.checkThemeDark = isCheckSwitch;
      if(isCheckSwitch)
        GlobalVariables.themeData = ThemeData.dark();
      else
        GlobalVariables.themeData = ThemeData.light();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> Home(false)));
    });
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
