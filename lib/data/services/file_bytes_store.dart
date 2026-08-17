import 'dart:typed_data';

class FileBytesStore {
  FileBytesStore._();

  static final Map<String, Uint8List> _cache = {};

  static void store(String id, Uint8List bytes) {
    _cache[id] = bytes;
  }

  static Uint8List? retrieve(String id) {
    return _cache[id];
  }

  static void remove(String id) {
    _cache.remove(id);
  }

  static void clear() {
    _cache.clear();
  }
}
