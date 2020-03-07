abstract class StorageService {
  void setTimeoutMs(int milliseconds);

  void putInt(String key, int value);
  void putBool(String key, bool value);
  void putDouble(String key, double value);
  void putString(String key, String value);
  void putStringList(String key, List<String> value);

  void putIntAsync(String key, int value);
  void putBoolAsync(String key, bool value);
  void putDoubleAsync(String key, double value);
  void putStringAsync(String key, String value);
  void putStringListAsync(String key, List<String> value);

  int getInt(String key);
  bool getBool(String key);
  double getDouble(String key);
  Future<String> getString(String key);
  List<String> getStringList(String key);
  dynamic get<T>(String key);
}