import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class MessageWidget extends StatelessWidget {
  final bool isSender;
  final String message;
  final int time; // Timestamp in milliseconds
  final int? nextTime; // Timestamp of the next message
  final String? imageUrl;

  const MessageWidget({
    Key? key,
    required this.isSender,
    required this.message,
    required this.time,
    this.nextTime,
    this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formattedTime =
        DateFormat('HH:mm').format(DateTime.fromMillisecondsSinceEpoch(time));

    final currentDate = DateTime.fromMillisecondsSinceEpoch(time);
    final nextDate = nextTime != null
        ? DateTime.fromMillisecondsSinceEpoch(nextTime!)
        : null;

    final isSameMinute = nextDate != null &&
        currentDate.year == nextDate.year &&
        currentDate.month == nextDate.month &&
        currentDate.day == nextDate.day &&
        currentDate.hour == nextDate.hour &&
        currentDate.minute == nextDate.minute;

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
              if (imageUrl != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  width: 200,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: NetworkImage(imageUrl!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              Container(
                margin: EdgeInsets.only(top: 4),
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
                child: Text(message),
              ),
              if (!isSameMinute)
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 8,
                  ),
                  child: Text(
                    formattedTime,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
            ],
          ),
        ),
        if (nextTime == null) const SizedBox(height: 12),
        if (isDifferentDay)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                // Left divider
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 64,
                    ),
                    child: Divider(
                      color: Colors.grey,
                      thickness: 1,
                      endIndent: 10,
                    ),
                  ),
                ),
                // Centered date text
                Text(
                  DateFormat('MMM, dd, yyyy')
                      .format(currentDate), // e.g., Aug, 12, 2024
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey,
                  ),
                ),
                // Right divider
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: 64,
                    ),
                    child: Divider(
                      color: Colors.grey,
                      thickness: 1,
                      indent: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
