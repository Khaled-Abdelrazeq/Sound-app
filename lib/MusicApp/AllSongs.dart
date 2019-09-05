import 'dart:io';
import 'dart:math';

import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/material.dart';
import 'package:music_app/models/FavouriteModel.dart';
import 'package:music_app/util/DatabaseManager.dart';
import 'package:music_app/util/GlobalVariables.dart';

import '../GlobalStateStore.dart';
import 'Favourite.dart';
import 'Home.dart';
import 'PlaySong.dart';

import 'package:music_app/util/MySlide.dart';

class AllSongs extends StatefulWidget {
  @override
  _AllSongsState createState() => _AllSongsState();
}

class _AllSongsState extends State<AllSongs> {
  // ------------------------------- VARIABLES -------------------------------
  List<Song> _songs = List<Song>();
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

  // ------------------------------- PREPARE SONGS -------------------------------
  initSongs() async {
    audioPlayer = MusicFinder();
    List<Song> songs = await MusicFinder.allSongs();
    songs = List.from(songs);
    setState(() {
      _songs = songs;
    });


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
    Route route = MySlideDuration2(widget: PlaySong(index, 1));
    Navigator.push(context, route);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initSongs();
  }

  @override
  void didUpdateWidget(AllSongs oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    if (_store.get("isPlaying") != null)
      isPlayingCheck = _store.get("isPlaying");
    else
      isPlayingCheck = false;

    print('isPlaying: $isPlayingCheck');
  }

  addSong(int index){
    setState(() {
      print('AddSong');
    database
        .addSong(FavouriteModel(
      index,
      _songs[index].title,
      _songs[index].album,
      _songs[index].uri,
      _songs[index].albumArt,
      _songs[index].artist,
      _songs[index].duration,
       )
    ).then((_) {
     indexList.add(index);
    });
    });
  }


  deleteSong(BuildContext context, FavouriteModel favouriteModel, int index) {
    setState(()  async {
      await database.deleteSong(favouriteModel.index).then((songs) {
        setState(() {
          indexList.remove(index);
        });
      });
    });
  }

  void printdd(BuildContext context, FavouriteModel favouriteModel, int index){
    print('indexee $index');
    print('indexee ${favouriteModel.index}');
  }

  @override
  Widget build(BuildContext context) {
    return
      Scaffold(
      appBar: AppBar(
        title: Text("All Songs"),
        centerTitle: true,
      ),

      body: Container(
        child: ListView.builder(
          itemCount: _songs.length == null ? 0 : _songs.length,
          itemBuilder: (context, int index) {
            return Column(
              children: <Widget>[
                Row(children: <Widget>[
                  Expanded(child: ListTile(
                    title: Text(_songs[index].title),
                    onTap: () {
                      _onClick(index);
                    },
                    leading: ClipOval(
                      clipper: CirlceClipper(),
                      child: _songs[index].albumArt == null
                          ? Image.asset(
                        "images/bg.jpg",
                        fit: BoxFit.fill,
                        height: 50.0,
                        width: 50.0,
                      )
                          : Image.file(
                        File(_songs[index].albumArt),
                        fit: BoxFit.fill,
                        height: 50.0,
                        width: 50.0,
                      ),
                    ),
                  ),),
                  Padding(padding: const EdgeInsets.only(left: 12.0), child:  indexList.contains(index)
//                      ? InkWell(child: Icon(Icons.favorite,), onTap: addSong(index),)
                      ? IconButton(icon: Icon(Icons.favorite),
                      onPressed: () {
                        var index2 = indexList.indexOf(index);
                        deleteSong(context, listSongs[index2], index);
                      }
                  )
                      : IconButton(icon: Icon(Icons.favorite_border,), onPressed: () => addSong(index),),),

                ],),
                Divider(height: 15.0,)
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
              selected: true,
            ),
            ListTile(
              title: Text("Favourite"),
              leading: Icon(Icons.favorite),
              selected: false,
              onTap: (){
                Route route = MySlideDuration(widget: Favourite());
                Navigator.pop(context);
                Navigator.push(context, route);
              },
            ),
            Divider(height: 15.0,),
            Padding(padding: EdgeInsets.only(top: 20.0)),
            IconButton(
              icon: Icon(GlobalVariables.checkThemeDark? Icons.brightness_2: Icons.brightness_5),
              onPressed: onPressedButton,
            )
          ],
        ),
      ),
    );
  }

  onPressedButton(){
    setState(() {
      isCheckSwitch = !isCheckSwitch;
      GlobalVariables.checkThemeDark = isCheckSwitch;
      if(isCheckSwitch)
        GlobalVariables.themeData = ThemeData.dark();
      else
        GlobalVariables.themeData = ThemeData.light();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> Home(true)));
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
