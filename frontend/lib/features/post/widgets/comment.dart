import 'package:flutter/material.dart';
import 'package:frontend/common/widgets/custom_avatar.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/image_view/screens/full_screen_image_view.dart';

class CommentWidget extends StatefulWidget {
  final String profileImageUrl;
  final String username;
  final String userId;
  final String commentText;
  final String date;
  final int initialLikesCount;
  final List<dynamic> resources;

  const CommentWidget({
    Key? key,
    required this.profileImageUrl,
    required this.username,
    required this.userId,
    required this.commentText,
    required this.date,
    required this.initialLikesCount,
    required this.resources,
  }) : super(key: key);

  @override
  _CommentWidgetState createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  bool _isLiked = false;
  int _likesCount = 0;

  @override
  void initState() {
    super.initState();
    _likesCount = widget.initialLikesCount;
  }

  void _toggleLike() {
    setState(() {
      if (_isLiked) {
        _likesCount--;
      } else {
        _likesCount++;
      }
      _isLiked = !_isLiked;
    });
  }

  // Extract image URLs from resources
  List<String> get imageUrls {
    return widget.resources
        .where((resource) =>
            resource is Map<String, dynamic> && resource['url'] != null)
        .map<String>((resource) => resource['url'] as String)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final hasImages = imageUrls.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User profile info (avatar + name + date in a row)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar
              CustomAvatar(
                radius: 16,
                imageUrl: widget.profileImageUrl,
                userId: widget.userId,
              ),
              const SizedBox(width: 8),

              // Name and date in a column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.username,
                      style: const TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                    ),
                    Text(
                      widget.date,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[500],
                      ),
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Comment content container
          Container(
            margin: const EdgeInsets.only(left: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Comment text (only show if not empty)
                if (widget.commentText.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: GlobalVariables.lightGreen,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.commentText,
                      style: TextStyle(
                        fontSize: 13,
                        color: GlobalVariables.darkGrey,
                      ),
                    ),
                  ),

                // Space between text and images (only if both exist)
                if (widget.commentText.isNotEmpty && hasImages)
                  const SizedBox(height: 8),

                // Images grid section
                if (hasImages) _buildImageGrid(),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Post metadata (likes, comments) - Improved design
          Padding(
            padding: const EdgeInsets.only(left: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Like button with improved design
                GestureDetector(
                  onTap: _toggleLike,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: _isLiked
                          ? GlobalVariables.green.withOpacity(0.1)
                          : Colors.transparent,
                      border: Border.all(
                        color: _isLiked
                            ? GlobalVariables.green
                            : Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isLiked
                              ? Icons.thumb_up_alt
                              : Icons.thumb_up_alt_outlined,
                          size: 14,
                          color: _isLiked
                              ? GlobalVariables.green
                              : GlobalVariables.darkGrey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Like',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: _isLiked
                                ? GlobalVariables.green
                                : GlobalVariables.darkGrey,
                          ),
                        ),
                        if (_likesCount > 0) ...[
                          const SizedBox(width: 4),
                          Text(
                            '• $_likesCount',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: _isLiked
                                  ? GlobalVariables.green
                                  : GlobalVariables.darkGrey,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGrid() {
    final imageCount = imageUrls.length;
    const double imageSize = 80.0; // Fixed size for square images
    const double spacing = 6.0; // Spacing between images
    const int maxImagesPerRow = 3; // Maximum images per row

    // Calculate how many rows we need
    final int rows = (imageCount / maxImagesPerRow).ceil();

    return Column(
      children: List.generate(rows, (rowIndex) {
        final int startIndex = rowIndex * maxImagesPerRow;
        final int endIndex =
            (startIndex + maxImagesPerRow).clamp(0, imageCount);
        final List<String> rowImages = imageUrls.sublist(startIndex, endIndex);

        return Padding(
          padding: EdgeInsets.only(bottom: rowIndex < rows - 1 ? spacing : 0),
          child: Row(
            children: [
              ...rowImages.asMap().entries.map((entry) {
                final int imageIndex = startIndex + entry.key;
                final String imageUrl = entry.value;

                return Padding(
                  padding: EdgeInsets.only(
                    right: entry.key < rowImages.length - 1 ? spacing : 0,
                  ),
                  child: _buildSquareImage(imageUrl, imageIndex, imageSize),
                );
              }).toList(),

              // Show "+X more" overlay on last visible image if there are more images
              if (rowIndex == rows - 1 &&
                  imageCount > maxImagesPerRow * rows &&
                  rowImages.length == maxImagesPerRow) ...[
                Padding(
                  padding: const EdgeInsets.only(left: spacing),
                  child: _buildMoreImagesOverlay(
                      imageCount - (maxImagesPerRow * rows), imageSize),
                ),
              ],
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSquareImage(String imageUrl, int index, double size) {
    return GestureDetector(
      onTap: () => _openFullScreenImage(index),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey.shade200,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            width: size,
            height: size,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: size,
                height: size,
                color: Colors.grey.shade200,
                child: const Center(
                  child: Icon(
                    Icons.broken_image,
                    color: Colors.grey,
                    size: 24,
                  ),
                ),
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                width: size,
                height: size,
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMoreImagesOverlay(int remainingCount, double size) {
    return GestureDetector(
      onTap: () => _openFullScreenImage(0), // Open gallery from first image
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.black54,
        ),
        child: Center(
          child: Text(
            '+$remainingCount',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  void _openFullScreenImage(int initialIndex) {
    Navigator.of(context).pushNamed(
      FullScreenImageView.routeName,
      arguments: {
        'imageUrls': imageUrls,
        'initialIndex': initialIndex,
      },
    );
  }
}
