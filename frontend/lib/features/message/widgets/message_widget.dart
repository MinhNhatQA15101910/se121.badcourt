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

  const MessageWidget({
    Key? key,
    required this.isSender,
    required this.message,
    required this.time,
    this.nextTime,
    this.imageUrls,
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

    final isDifferentDay = nextDate != null &&
        (currentDate.year != nextDate.year ||
            currentDate.month != nextDate.month ||
            currentDate.day != nextDate.day);

    return Column(
      crossAxisAlignment:
          isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Align(
          alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
          child: Column(
            crossAxisAlignment:
                isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (imageUrls != null && imageUrls!.isNotEmpty)
                const SizedBox(height: 12),
              if (imageUrls != null && imageUrls!.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: imageUrls!.map((url) {
                    return GestureDetector(
                      onTap: () {
                      },
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: url.startsWith('/data') ||
                                    url.startsWith('/storage')
                                ? FileImage(File(url))
                                : NetworkImage(url) as ImageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              if (message.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSender ? Colors.green[100] : Colors.grey[300],
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(isSender ? 12 : 0),
                      topRight: Radius.circular(isSender ? 0 : 12),
                      bottomLeft: const Radius.circular(12),
                      bottomRight: const Radius.circular(12),
                    ),
                  ),
                  child: Text(
                    message,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              if (!isSameMinute)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    formattedTime,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
            ],
          ),
        ),
        if (isDifferentDay)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                const Expanded(
                  child: Divider(
                    color: Colors.grey,
                    thickness: 1,
                    endIndent: 10,
                  ),
                ),
                Text(
                  DateFormat('MMM, dd, yyyy').format(currentDate),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey,
                  ),
                ),
                const Expanded(
                  child: Divider(
                    color: Colors.grey,
                    thickness: 1,
                    indent: 10,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}