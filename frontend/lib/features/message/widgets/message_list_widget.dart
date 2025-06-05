import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/message/widgets/message_widget.dart';
import 'package:google_fonts/google_fonts.dart';

class MessageListWidget extends StatelessWidget {
  final List<Map<String, dynamic>> messages;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMorePages;
  final int currentPage;
  final int totalPages;
  final ScrollController scrollController;
  final VoidCallback onLoadMore;

  const MessageListWidget({
    Key? key,
    required this.messages,
    required this.isLoading,
    required this.isLoadingMore,
    required this.hasMorePages,
    required this.currentPage,
    required this.totalPages,
    required this.scrollController,
    required this.onLoadMore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading && messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                color: GlobalVariables.green,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading messages...',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: GlobalVariables.darkGreen,
              ),
            ),
          ],
        ),
      );
    }

    if (messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: GlobalVariables.lightGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chat_bubble_outline_rounded,
                size: 64,
                color: GlobalVariables.green,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No messages yet',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: GlobalVariables.darkGreen,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start the conversation!',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: GlobalVariables.darkGrey,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Pagination info
        if (totalPages > 1 && !isLoading)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'Page $currentPage of $totalPages',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        
        // Messages list
        Expanded(
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              // Tải thêm tin nhắn cũ khi cuộn lên đầu danh sách
              if (scrollInfo.metrics.pixels <= 0 &&
                  hasMorePages && !isLoadingMore) {
                onLoadMore();
                return true;
              }
              return false;
            },
            child: ListView.builder(
              controller: scrollController,
              reverse: false, // Không đảo ngược ListView
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: messages.length + (hasMorePages ? 1 : 0),
              itemBuilder: (context, index) {
                // Show loading indicator at the top when there are more pages
                if (index == 0 && hasMorePages && isLoadingMore) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: GlobalVariables.green,
                                strokeWidth: 2,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Loading more messages...',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: GlobalVariables.darkGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                // Adjust index for loading indicator
                final messageIndex = hasMorePages && isLoadingMore ? index - 1 : index;
                if (messageIndex < 0 || messageIndex >= messages.length) {
                  return const SizedBox.shrink();
                }

                final message = messages[messageIndex];
                final nextMessage = messageIndex < messages.length - 1
                    ? messages[messageIndex + 1]
                    : null;
                    
                // Kiểm tra xem tin nhắn có phải là tin nhắn đầu tiên của ngày không
                final bool isFirstMessageOfDay = _isFirstMessageOfDay(message, messageIndex > 0 ? messages[messageIndex - 1] : null);

                return Column(
                  children: [
                    // Hiển thị ngày nếu là tin nhắn đầu tiên của ngày
                    if (isFirstMessageOfDay)
                      _buildDateSeparator(message['time']),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: MessageWidget(
                        isSender: message['isSender'] ?? false,
                        message: message['message'] ?? '',
                        time: message['time'],
                        nextTime: nextMessage?['time'],
                        imageUrls: (message['resources'] as List<dynamic>?)
                            ?.map((e) => e.toString())
                            .toList(),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
  
  // Kiểm tra xem tin nhắn có phải là tin nhắn đầu tiên của ngày không
  bool _isFirstMessageOfDay(Map<String, dynamic> message, Map<String, dynamic>? previousMessage) {
    if (previousMessage == null) return true;
    
    final DateTime currentMessageTime = DateTime.fromMillisecondsSinceEpoch(message['time']);
    final DateTime previousMessageTime = DateTime.fromMillisecondsSinceEpoch(previousMessage['time']);
    
    return currentMessageTime.year != previousMessageTime.year ||
           currentMessageTime.month != previousMessageTime.month ||
           currentMessageTime.day != previousMessageTime.day;
  }
  
  // Hiển thị ngày
  Widget _buildDateSeparator(int timestamp) {
    final DateTime messageTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final DateTime now = DateTime.now();
    final DateTime yesterday = DateTime.now().subtract(const Duration(days: 1));
    
    String dateText;
    if (messageTime.year == now.year && messageTime.month == now.month && messageTime.day == now.day) {
      dateText = 'Today';
    } else if (messageTime.year == yesterday.year && messageTime.month == yesterday.month && messageTime.day == yesterday.day) {
      dateText = 'Yesterday';
    } else {
      dateText = '${messageTime.day}/${messageTime.month}/${messageTime.year}';
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: Colors.grey.shade300,
              thickness: 1,
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              dateText,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Divider(
              color: Colors.grey.shade300,
              thickness: 1,
            ),
          ),
        ],
      ),
    );
  }
}
