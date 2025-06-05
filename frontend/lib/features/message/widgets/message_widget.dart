import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class MessageWidget extends StatelessWidget {
  final bool isSender;
  final String message;
  final int time;
  final int? nextTime;
  final List<String>? imageUrls;
  final bool? isNextMessageFromSameSender;
  final bool? isPreviousMessageFromSameSender;

  const MessageWidget({
    Key? key,
    required this.isSender,
    required this.message,
    required this.time,
    this.nextTime,
    this.imageUrls,
    this.isNextMessageFromSameSender,
    this.isPreviousMessageFromSameSender,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentDate = DateTime.fromMillisecondsSinceEpoch(time);
    final nextDate = nextTime != null
        ? DateTime.fromMillisecondsSinceEpoch(nextTime!)
        : null;

    final formattedTime = DateFormat('HH:mm').format(currentDate);
    final isSameMinute =
        nextDate != null && currentDate.difference(nextDate).inMinutes == 0;

    // Determine spacing based on message grouping
    final bottomMargin = _getBottomMargin();

    return Column(
      children: [
        Align(
          alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: EdgeInsets.only(
              left: isSender ? 60 : 0,
              right: isSender ? 0 : 60,
              bottom: bottomMargin,
            ),
            child: Column(
              crossAxisAlignment:
                  isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (imageUrls != null && imageUrls!.isNotEmpty)
                  _buildImageGrid(),
                if (message.isNotEmpty) _buildTextBubble(context),
                if (!isSameMinute && !_shouldHideTimestamp()) 
                  _buildTimeStamp(formattedTime),
              ],
            ),
          ),
        ),
      ],
    );
  }

  double _getBottomMargin() {
    // If next message is from same sender and within 2 minutes, use smaller margin
    if (isNextMessageFromSameSender == true && 
        nextTime != null && 
        (time - nextTime!) < 120000) { // 2 minutes in milliseconds
      return 2.0;
    }
    return 8.0;
  }

  bool _shouldHideTimestamp() {
    // Hide timestamp if next message is from same sender and within 1 minute
    return isNextMessageFromSameSender == true && 
           nextTime != null && 
           (time - nextTime!) < 60000; // 1 minute in milliseconds
  }

  BorderRadius _getBorderRadius() {
    final isFirstInGroup = isPreviousMessageFromSameSender != true;
    final isLastInGroup = isNextMessageFromSameSender != true;
    
    if (isSender) {
      return BorderRadius.only(
        topLeft: const Radius.circular(20),
        topRight: Radius.circular(isFirstInGroup ? 20 : 6),
        bottomLeft: const Radius.circular(20),
        bottomRight: Radius.circular(isLastInGroup ? 20 : 6),
      );
    } else {
      return BorderRadius.only(
        topLeft: Radius.circular(isFirstInGroup ? 20 : 6),
        topRight: const Radius.circular(20),
        bottomLeft: Radius.circular(isLastInGroup ? 20 : 6),
        bottomRight: const Radius.circular(20),
      );
    }
  }

  Widget _buildImageGrid() {
    if (imageUrls == null || imageUrls!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ClipRRect(
        borderRadius: _getBorderRadius(),
        child: imageUrls!.length == 1
            ? _buildSingleImage(imageUrls!.first)
            : _buildMultipleImages(),
      ),
    );
  }

  Widget _buildSingleImage(String url) {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 250,
        maxHeight: 300,
      ),
      child: Image(
        image: url.startsWith('/data') || url.startsWith('/storage')
            ? FileImage(File(url))
            : NetworkImage(url) as ImageProvider,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildMultipleImages() {
    return SizedBox(
      width: 250,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: imageUrls!.length > 2 ? 2 : imageUrls!.length,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
        ),
        itemCount: imageUrls!.length > 4 ? 4 : imageUrls!.length,
        itemBuilder: (context, index) {
          if (index == 3 && imageUrls!.length > 4) {
            return _buildMoreImagesOverlay();
          }
          return Image(
            image: imageUrls![index].startsWith('/data') ||
                    imageUrls![index].startsWith('/storage')
                ? FileImage(File(imageUrls![index]))
                : NetworkImage(imageUrls![index]) as ImageProvider,
            fit: BoxFit.cover,
          );
        },
      ),
    );
  }

  Widget _buildMoreImagesOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Text(
          '+${imageUrls!.length - 3}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTextBubble(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isSender ? const Color(0xFF23C16B) : Colors.grey.shade200,
        borderRadius: _getBorderRadius(),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        message,
        style: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: isSender ? Colors.white : Colors.black87,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildTimeStamp(String formattedTime) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
      child: Text(
        formattedTime,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: Colors.grey.shade500,
        ),
      ),
    );
  }
}
