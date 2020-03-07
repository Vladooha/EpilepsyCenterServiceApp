import 'package:crypted_preferences/crypted_preferences.dart';
import 'package:frontend/service/storage/storageService.dart';
import 'package:get_it/get_it.dart';
import 'package:localstorage/localstorage.dart';

class StorageServiceImpl implements StorageService {
  String _path = './state';
  int _timeoutMs;
  final LocalStorage storage = new LocalStorage('storage');

  StorageServiceImpl() {
    _timeoutMs = 100;
    GetIt.instance.registerSingleton<StorageService>(this, signalsReady: true);
  }

  @override
  void setTimeoutMs(int milliseconds) {
    _timeoutMs = milliseconds;
  }

  @override
  putInt(String key, int value) async {
    var prefs = await Preferences.preferences(path: _path);
    await prefs.setInt(key, value);
  }

  @override
  putBool(String key, bool value) async {
    var prefs = await Preferences.preferences(path: _path);
    await prefs.setBool(key, value);
  }

  @override
  putDouble(String key, double value) async {
    var prefs = await Preferences.preferences(path: _path);
    await prefs.setDouble(key, value);
  }

  @override
  putString(String key, String value) async {
    //var prefs = await Preferences.preferences(path: _path);
    bool isReady = await storage.ready;

    if (isReady) {
      await storage.setItem(key, value);
    }
  }

  @override
  putStringList(String key, List<String> value) async {
    var prefs = await Preferences.preferences(path: _path);
    await prefs.setStringList(key, value);
    print('$key is $value');
  }

  @override
  putIntAsync(String key, int value) async {
    var prefs = await Preferences.preferences(path: _path);
    prefs.setInt(key, value);
  }

  @override
  putBoolAsync(String key, bool value) async {
    var prefs = await Preferences.preferences(path: _path);
    prefs.setBool(key, value);
  }

  @override
  putDoubleAsync(String key, double value) async {
    var prefs = await Preferences.preferences(path: _path);
    prefs.setDouble(key, value);
  }

  @override
  putStringAsync(String key, String value) async {
    var prefs = await Preferences.preferences(path: _path);
    await prefs.setString(key, value).then((data) => print(data ? "Saved" : "Not saved"));
  }

  @override
  putStringListAsync(String key, List<String> value) async {
    var prefs = await Preferences.preferences(path: _path);
    prefs.setStringList(key, value);
  }

  @override
  int getInt(String key) {
    int result = null;
    Preferences.preferences(path: _path)
        .timeout(Duration(milliseconds: _timeoutMs))
        .then((prefs) => result = prefs.getInt(key));
    return result;
  }

  @override
  bool getBool(String key) {
    bool result = null;
    Preferences.preferences(path: _path)
        .timeout(Duration(milliseconds: _timeoutMs))
        .then((prefs) => result = prefs.getBool(key));
    return result;
  }

  @override
  double getDouble(String key) {
    double result = null;
    Preferences.preferences(path: _path)
        .timeout(Duration(milliseconds: _timeoutMs))
        .then((prefs) => result = prefs.getDouble(key));
    return result;
  }

  @override
  Future<String> getString(String key) async {
    //var prefs = await Preferences.preferences(path: _path);
    bool isReady = await storage.ready;

    if (isReady) {
      print(await storage.getItem(key));
      return storage.getItem(key);
    } else {
      return null;
    }
  }

  @override
  List<String> getStringList(String key) {
    List<String> result = null;
    Preferences.preferences(path: _path)
        .timeout(Duration(milliseconds: _timeoutMs))
        .then((prefs) {
          result = prefs.getStringList(key);
          print('$key: $result');

          return result;
        });
    return result;
  }

  @override
  dynamic get<T>(String key) async {
    var prefs = await Preferences.preferences(path: _path);
    return await prefs.get(key);
  }
}