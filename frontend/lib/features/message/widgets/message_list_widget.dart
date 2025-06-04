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
            CircularProgressIndicator(
              color: GlobalVariables.green,
            ),
            SizedBox(height: 16),
            Text(
              'Loading messages...',
              style: GoogleFonts.inter(fontSize: 16),
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
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: GlobalVariables.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No messages yet',
              style: GoogleFonts.inter(
                fontSize: 18,
                color: GlobalVariables.grey,
              ),
            ),
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
        if (totalPages > 1)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Page $currentPage of $totalPages',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ),
        
        // Messages list
        Expanded(
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent &&
                  hasMorePages && !isLoadingMore) {
                onLoadMore();
                return true;
              }
              return false;
            },
            child: ListView.builder(
              controller: scrollController,
              reverse: true,
              itemCount: messages.length + (hasMorePages ? 1 : 0),
              itemBuilder: (context, index) {
                // Show loading indicator at the bottom when there are more pages
                if (index == messages.length) {
                  return isLoadingMore
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: GlobalVariables.green,
                              strokeWidth: 2,
                            ),
                          ),
                        )
                      : const SizedBox.shrink();
                }

                final message = messages[index];
                final nextMessage = index > 0 ? messages[index - 1] : null;

                return Container(
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
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
