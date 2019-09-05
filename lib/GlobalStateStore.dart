class GlobalStateStore{
  final Map<dynamic, dynamic> _data = Map<dynamic, dynamic>();

  static GlobalStateStore ins = GlobalStateStore._();
  GlobalStateStore._();

  set(dynamic key, dynamic value) => _data[key] = value;
  get(dynamic key) => _data[key];
}