import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:inline_image/helpers/db_helper.dart';
import 'package:inline_image/helpers/file_helper.dart';
import 'package:inline_image/views/note_list_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FileHelper.fileHelper.loadLocalPath();

  await Hive.initFlutter();
  await DBHelper.dbHelper.open();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: NoteListView(),
    );
  }
}
