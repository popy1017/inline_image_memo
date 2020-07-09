import 'dart:io';

import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inline_image/helpers/db_helper.dart';
import 'package:inline_image/helpers/file_helper.dart';
import 'package:inline_image/models/image_span_builder.dart';

class NoteEditView extends StatefulWidget {
  NoteEditView({this.note, this.noteIndex});

  String note;
  int noteIndex;

  @override
  State<StatefulWidget> createState() {
    return _NoteEditViewState();
  }
}

class _NoteEditViewState extends State<NoteEditView> {
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final FileHelper _fileHelper = FileHelper.fileHelper;

  List<PickedFile> _images = <PickedFile>[];

  @override
  void initState() {
    super.initState();

    if (isUpdateMode) {
      final String textWithAbsolutePath =
          _replaceRelativePathWithAbsolutePath(widget.note);
      insertText(textWithAbsolutePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                ExtendedTextField(
                  keyboardType: TextInputType.multiline,
                  autofocus: true,
                  maxLines: 100,
                  specialTextSpanBuilder: ImageSpanBuilder(
                    showAtBackground: true,
                  ),
                  controller: _controller,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: Colors.grey[350],
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: InkWell(
                      child: Icon(Icons.camera_alt),
                      onTap: () {},
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      child: Icon(Icons.photo),
                      onTap: getImage,
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Container(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Builder(
        builder: (BuildContext context) => FloatingActionButton.extended(
          icon: Icon(Icons.save),
          label: Text('保存'),
          onPressed: _saveNote,
        ),
      ),
    );
  }

  bool get isUpdateMode {
    return widget.note != null && widget.noteIndex != null;
  }

  Future getImage() async {
    print(_controller.text);

    final PickedFile pickedFile =
        await _picker.getImage(source: ImageSource.gallery);

    if (pickedFile == null) {
      SystemChannels.textInput.invokeMethod('TextInput.show');
      return;
    }

    setState(() {
      insertText(
          '<img src=\'${pickedFile.path}\' width=\'300\' height=\'300\'/>\n');
      _images.add(pickedFile);
    });
  }

  void insertText(String text) {
    final TextEditingValue value = _controller.value;
    final int start = value.selection.baseOffset;
    int end = value.selection.extentOffset;
    if (value.selection.isValid) {
      String newText = '';
      if (value.selection.isCollapsed) {
        if (end > 0) {
          newText += value.text.substring(0, end);
        }
        newText += text;
        if (value.text.length > end) {
          newText += value.text.substring(end, value.text.length);
        }
      } else {
        newText = value.text.replaceRange(start, end, text);
        end = start;
      }

      _controller.value = value.copyWith(
          text: newText,
          selection: value.selection.copyWith(
              baseOffset: end + text.length, extentOffset: end + text.length));
    } else {
      _controller.value = TextEditingValue(
        text: text,
        selection: TextSelection.fromPosition(
          TextPosition(offset: text.length),
        ),
      );
    }
  }

  String _replaceRelativePathWithAbsolutePath(String text) {
    String newText = text;
    List<String> relativeImageNames = _fileHelper.findImageNames(text);

    for (int i = 0; i < relativeImageNames.length; i++) {
      final String absoluteImageName =
          _fileHelper.relativePathToAbsolutePath(relativeImageNames[i]);
      newText = newText.replaceAll(relativeImageNames[i], absoluteImageName);
    }
    return newText;
  }

  String _replateAbsolutePathWithRelativePath(String text) {
    String newText = text;
    List<String> absoluteImageNames = _fileHelper.findImageNames(text);

    for (int i = 0; i < absoluteImageNames.length; i++) {
      final String relativePath =
          _fileHelper.absolutePathToRelativePath(absoluteImageNames[i]);
      newText = newText.replaceAll(absoluteImageNames[i], relativePath);
    }
    return newText;
  }

  Future<void> _saveNote() async {
    String _currentText = _controller.text;

    // 現在 指定している画像パスは一時的な領域にあるものなのでアプリ領域に画像を保存する
    for (int i = 0; i < _images.length; i++) {
      if (_currentText.contains(_images[i].path)) {
        await _fileHelper.saveImage(File(_images[i].path));
      }
    }

    _currentText = _replateAbsolutePathWithRelativePath(_currentText);

    if (isUpdateMode) {
      DBHelper.dbHelper.update(widget.noteIndex, _currentText);
    } else {
      DBHelper.dbHelper.add(_currentText);
    }

    Navigator.pop(context);
  }
}
