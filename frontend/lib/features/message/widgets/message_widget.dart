import 'package:flutter/material.dart';

class MessageWidget extends StatelessWidget {
  final bool isSender;
  final String message;
  final String time;
  final String? imageUrl;

  const MessageWidget({
    Key? key,
    required this.isSender,
    required this.message,
    required this.time,
    this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (imageUrl != null)
            Container(
              margin: EdgeInsets.only(bottom: 8),
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
            margin: EdgeInsets.only(bottom: 8),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSender ? Colors.green[100] : Colors.grey[300],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(isSender ? 12 : 0),
                topRight: Radius.circular(isSender ? 0 : 12),
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Text(message),
          ),
          Text(
            time,
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
