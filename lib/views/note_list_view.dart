import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:inline_image/helpers/db_helper.dart';
import 'package:inline_image/helpers/file_helper.dart';
import 'package:inline_image/views/note_edit_view.dart';

class NoteListView extends StatelessWidget {
  final FileHelper _fileHelper = FileHelper.fileHelper;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Note List View'),
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box(DBHelper.boxName).listenable(),
        builder: (BuildContext context, Box box, Widget widget) {
          final _items = DBHelper.dbHelper.getAllNotes();
          return ListView.builder(
            itemCount: _items.length,
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (BuildContext context) {
                        return NoteEditView(
                          note: _items[index],
                          noteIndex: index,
                        );
                      },
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: ListTile(
                    leading: SizedBox(
                      width: 100,
                      height: 100,
                      child: _noteImage(_items[index]),
                    ),
                    title: Text('Note: $index'),
                    subtitle: _textWithoutImageTag(_items[index]),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: Builder(
        builder: (BuildContext context) {
          return FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext context) {
                    return NoteEditView();
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _noteImage(String text) {
    List<String> imageNames = _fileHelper.findImageNames(text);

    if (imageNames.length > 0) {
      // 絶対パスに変換する
      final String absolutePath =
          _fileHelper.relativePathToAbsolutePath(imageNames[0]);

      // Image widgetを返す
      return Image.file(
        File(absolutePath),
        fit: BoxFit.cover,
      );
    }

    return Image.network(
      'https://cafe-ajara.com/wp/wp-content/themes/ajara-new/images/no-image.png',
      fit: BoxFit.cover,
    );
  }

  Widget _textWithoutImageTag(String text) {
    final String textWithoutImageTag =
        _fileHelper.getRemovedImageTagsText(text);

    return Text(
      textWithoutImageTag,
      maxLines: 3,
    );
  }
}
