import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class FullScreenImageView2 extends StatefulWidget {
  static const String routeName = '/fullScreenImageView';
  final List<String> imageUrls;
  final int initialIndex;

  const FullScreenImageView2({
    Key? key,
    required this.imageUrls,
    required this.initialIndex,
  }) : super(key: key);

  @override
  _FullScreenImageView2State createState() => _FullScreenImageView2State();
}

class _FullScreenImageView2State extends State<FullScreenImageView2> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: PhotoViewGallery.builder(
        itemCount: widget.imageUrls.length,
        builder: (context, index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(widget.imageUrls[index]),
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Icon(
                  Icons.broken_image,
                  size: 50,
                  color: Colors.grey,
                ),
              );
            },
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2.0,
            heroAttributes:
                PhotoViewHeroAttributes(tag: widget.imageUrls[index]),
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

  const ImageItem({Key? key, required this.imageUrls, required this.index})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FullScreenImageView2(
              imageUrls: imageUrls,
              initialIndex: index,
            ),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        child: Image.network(
          imageUrls[index],
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey.shade200,
              child: Center(
                child: Icon(
                  Icons.broken_image,
                  color: Colors.grey,
                  size: 50,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
