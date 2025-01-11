import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:dio/dio.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'dart:typed_data';

class FullScreenImageView2 extends StatelessWidget {
  final String imageUrl;

  const FullScreenImageView2({Key? key, required this.imageUrl})
      : super(key: key);

  Future<void> _saveImage(BuildContext context) async {
    try {
      Uint8List imageData;

      if (imageUrl.startsWith('/data') || imageUrl.startsWith('/storage')) {
        final file = File(imageUrl);
        imageData = await file.readAsBytes();
      } else {
        final response = await Dio().get(
          imageUrl,
          options: Options(responseType: ResponseType.bytes),
        );
        imageData = Uint8List.fromList(response.data);
      }

      final result = await ImageGallerySaver.saveImage(
        imageData,
        name: imageUrl.split('/').last,
      );

      if (result['isSuccess']) {
        IconSnackBar.show(
          context,
          label: 'Image saved successfully!',
          snackBarType: SnackBarType.success,
        );
      } else {
        throw Exception('Save failed');
      }
    } catch (e) {
      IconSnackBar.show(
        context,
        label: 'Failed to save image!',
        snackBarType: SnackBarType.fail,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.download, color: Colors.white),
            onPressed: () => _saveImage(context),
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: PhotoView(
          imageProvider:
              imageUrl.startsWith('/data') || imageUrl.startsWith('/storage')
                  ? FileImage(File(imageUrl))
                  : NetworkImage(imageUrl) as ImageProvider,
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 2.0,
        ),
      ),
    );
  }
}