import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:dio/dio.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'dart:typed_data';

class FullScreenImageView extends StatefulWidget {
  static const String routeName = '/fullScreenImageView';
  final List<String> imageUrls;
  final int initialIndex;

  const FullScreenImageView({
    Key? key,
    required this.imageUrls,
    required this.initialIndex,
  }) : super(key: key);

  @override
  _FullScreenImageViewState createState() => _FullScreenImageViewState();
}

class _FullScreenImageViewState extends State<FullScreenImageView> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  Future<void> _saveImage(BuildContext context) async {
    try {
      // Lấy URL ảnh hiện tại
      final imageUrl = widget.imageUrls[_currentIndex];

      // Tải ảnh từ URL dưới dạng byte
      final response = await Dio().get(
        imageUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      // Lưu ảnh vào thư viện
      final result = await ImageGallerySaver.saveImage(
        Uint8List.fromList(response.data),
        name: imageUrl.split('/').last,
      );

      if (result['isSuccess']) {
        // Hiển thị thông báo thành công
        IconSnackBar.show(
          context,
          label: 'Saved image to gallery!',
          snackBarType: SnackBarType.success,
        );
      } else {
        throw Exception('Save failed');
      }
    } catch (e) {
      // Hiển thị thông báo lỗi
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
        actions: [
          IconButton(
            icon: const Icon(Icons.download, color: Colors.white),
            onPressed: () => _saveImage(context),
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: PhotoViewGallery.builder(
        itemCount: widget.imageUrls.length,
        builder: (context, index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(widget.imageUrls[index]),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2.0,
            heroAttributes: PhotoViewHeroAttributes(tag: widget.imageUrls[index]),
          );
        },
        pageController: PageController(initialPage: widget.initialIndex),
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundDecoration: const BoxDecoration(color: Colors.black),
      ),
    );
  }
}

class ImageItem extends StatelessWidget {
  final List<String> imageUrls;
  final int index;

  const ImageItem({Key? key, required this.imageUrls, required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FullScreenImageView(
              imageUrls: imageUrls,
              initialIndex: index,
            ),
          ),
        );
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(
            Radius.circular(10),
          ),
          image: DecorationImage(
            image: NetworkImage(imageUrls[index]),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
