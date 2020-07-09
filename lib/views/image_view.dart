import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageView extends StatelessWidget {
  ImageView(this.files);

  List<PickedFile> files;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ExtendedImageGesturePageView.builder(
        itemCount: files.length,
        itemBuilder: (BuildContext context, int index) {
          return ExtendedImage.asset(files[index].path);
        },
      ),
    );
  }
}
