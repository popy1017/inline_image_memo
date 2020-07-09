import 'package:hive/hive.dart';

class DBHelper {
  DBHelper._internal();

  static final DBHelper dbHelper = DBHelper._internal();
  static final String boxName = 'noteBox';
  static Box box;

  Future<void> open() async {
    box = await Hive.openBox(boxName);
  }

  List<dynamic> getAllNotes() {
    final items = box.values;

    if (items != null) {
      return items.toList();
    }
    return [];
  }

  void add(String note) {
    box.add(note);
  }

  void update(int index, String note) {
    box.putAt(index, note);
  }
}
