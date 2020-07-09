import 'dart:io';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';

import 'package:path_provider/path_provider.dart';

class FileHelper {
  FileHelper._internal();

  static final FileHelper fileHelper = FileHelper._internal();

  String _localPath;
  String get localPath => _localPath;

  Future<void> loadLocalPath() async {
    final directory = await getApplicationDocumentsDirectory();
    _localPath = directory.path;

    print('localPath: $localPath');
  }

  String relativePathToAbsolutePath(String relativePath) {
    return '$_localPath/$relativePath';
  }

  String absolutePathToRelativePath(String absolutePath) {
    return this.extractFileName(absolutePath);
  }

  Future<File> saveImage(File image) async {
    final String fileName = this.extractFileName(image.path);
    final String absolutePath = this.relativePathToAbsolutePath(fileName);
    return await image.copy(absolutePath);
  }

  String extractFileName(String fullPath) {
    final RegExp exp = RegExp('[^/]+\$');
    final Match match = exp.firstMatch(fullPath);

    return match != null ? match.group(0) : fullPath;
  }

  List<String> findImageNames(String text) {
    final List<String> imageNames = <String>[];

    final dom.Document html = parse(text);
    final List<dom.Element> tags = html.getElementsByTagName('img');

    if (tags == null || tags.length == 0) {
      return imageNames;
    }

    for (int i = 0; i < tags.length; i++) {
      final dom.Element imgTag = tags[i];

      if (imgTag != null) {
        final String src = imgTag.attributes['src'];
        imageNames.add(src);
      }
    }

    return imageNames;
  }

  String getRemovedImageTagsText(String originalText) {
    final dom.Document html = parse(originalText);
    final List<dom.Element> tags = html.getElementsByTagName('img');

    for (int i = 0; i < tags.length; i++) {
      tags[i].remove();
    }

    return html.body.text ?? "";
  }
}
