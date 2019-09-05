class FavouriteModel{
  int _index;
  String _title;
  String _album;
  String _url;
  String _img;
  String _artist;
  int _duration;

  FavouriteModel(this._index, this._title, this._album, this._url, this._img,
      this._artist, this._duration);

  FavouriteModel.map(dynamic obj){
    this._index = obj['indexCol'];
    this._title = obj['title'];
    this._album = obj['album'];
    this._url = obj['url'];
    this._img = obj['img'];
    this._artist = obj['artist'];
    this._duration = obj['duration'];
  }

  int get index => _index;
  String get title => _title;
  String get album => _album;
  String get url => _url;
  String get img => _img;
  String get artist => _artist;
  int get duration => _duration;

  Map<String, dynamic> toMap(){
    var map = Map<String, dynamic>();
    map['indexCol']= _index;
    map['title'] = _title;
    map['album'] = _album;
    map['url'] = _url;
    map['img'] = _img;
    map['artist'] = _artist;
    map['duration'] = _duration;

    return map;
  }

  FavouriteModel.fromMap(Map<String, dynamic>map){
    this._index = map['indexCol'];
    this._title = map['title'];
    this._album = map['album'];
    this._url = map['url'];
    this._img = map['img'];
    this._artist = map['artist'];
    this._duration = map['duration'];
  }

}