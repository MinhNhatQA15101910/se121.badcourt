import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/message/widgets/message_widget.dart';
import 'package:frontend/models/message_dto.dart';
import 'package:google_fonts/google_fonts.dart';

class MessageListWidget extends StatefulWidget {
  final List<MessageDto> messages; // Changed from Map to MessageDto
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMorePages;
  final int currentPage;
  final int totalPages;
  final ScrollController scrollController;
  final VoidCallback onLoadMore;
  final String currentUserId; // Add currentUserId parameter

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
    required this.currentUserId,
  }) : super(key: key);

  @override
  State<MessageListWidget> createState() => _MessageListWidgetState();
}

class _MessageListWidgetState extends State<MessageListWidget> {
  bool _shouldAutoScroll = true;
  double _previousScrollPosition = 0;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);

    // Auto-scroll to bottom after initial load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom(animate: false);
    });
  }

  @override
  void didUpdateWidget(MessageListWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Only auto-scroll if new messages were added and user is near bottom
    if (oldWidget.messages.length < widget.messages.length &&
        _shouldAutoScroll) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom(animate: true);
      });
    }
  }

  void _onScroll() {
    if (widget.scrollController.hasClients) {
      final currentPosition = widget.scrollController.position.pixels;
      final maxScroll = widget.scrollController.position.maxScrollExtent;

      // Detect if user is scrolling up (manual scroll)
      if (currentPosition < _previousScrollPosition) {
        _shouldAutoScroll = false;
      }

      // If user scrolls near bottom, enable auto-scroll again
      if (maxScroll - currentPosition < 100) {
        _shouldAutoScroll = true;
      }

      _previousScrollPosition = currentPosition;

      // Load more messages when scrolling to the top
      if (currentPosition <= 0 &&
          widget.hasMorePages &&
          !widget.isLoadingMore) {
        widget.onLoadMore();
      }
    }
  }

  void _scrollToBottom({bool animate = true}) {
    if (widget.scrollController.hasClients) {
      if (animate) {
        widget.scrollController.animateTo(
          widget.scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else {
        widget.scrollController.jumpTo(
          widget.scrollController.position.maxScrollExtent,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading && widget.messages.isEmpty) {
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

    if (widget.messages.isEmpty) {
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

    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollInfo) {
                  // Load more messages when scrolling to the top (for older messages)
                  if (scrollInfo.metrics.pixels <= 0 &&
                      widget.hasMorePages &&
                      !widget.isLoadingMore) {
                    widget.onLoadMore();
                    return true;
                  }
                  return false;
                },
                child: ListView.builder(
                  controller: widget.scrollController,
                  reverse:
                      false, // Normal order - oldest at top, newest at bottom
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: widget.messages.length +
                      (widget.hasMorePages && widget.isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    // Show loading indicator at the top when loading more messages
                    if (index == 0 &&
                        widget.hasMorePages &&
                        widget.isLoadingMore) {
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
                    final messageIndex =
                        widget.hasMorePages && widget.isLoadingMore
                            ? index - 1
                            : index;
                    if (messageIndex < 0 ||
                        messageIndex >= widget.messages.length) {
                      return const SizedBox.shrink();
                    }

                    final message = widget.messages[messageIndex];
                    final nextMessage =
                        messageIndex < widget.messages.length - 1
                            ? widget.messages[messageIndex + 1]
                            : null;
                    final previousMessage = messageIndex > 0
                        ? widget.messages[messageIndex - 1]
                        : null;

                    // Check if this is the first message of the day
                    final bool isFirstMessageOfDay =
                        _isFirstMessageOfDay(message, previousMessage);

                    return Column(
                      children: [
                        // Show date separator if first message of day
                        if (isFirstMessageOfDay)
                          _buildDateSeparator(
                              message.messageSent.millisecondsSinceEpoch),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: MessageWidget(
                            isSender: message.senderId == widget.currentUserId,
                            message: message.content,
                            time: message.messageSent.millisecondsSinceEpoch,
                            nextTime:
                                nextMessage?.messageSent.millisecondsSinceEpoch,
                            mediaFiles: message
                                .resources, // Now directly pass List<FileDto>
                            isNextMessageFromSameSender:
                                nextMessage?.senderId == message.senderId,
                            isPreviousMessageFromSameSender:
                                previousMessage?.senderId == message.senderId,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  bool _isFirstMessageOfDay(MessageDto message, MessageDto? previousMessage) {
    if (previousMessage == null) return true;

    final DateTime currentMessageTime = message.messageSent;
    final DateTime previousMessageTime = previousMessage.messageSent;

    return currentMessageTime.year != previousMessageTime.year ||
        currentMessageTime.month != previousMessageTime.month ||
        currentMessageTime.day != previousMessageTime.day;
  }

  Widget _buildDateSeparator(int timestamp) {
    final DateTime messageTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final DateTime now = DateTime.now();
    final DateTime yesterday = DateTime.now().subtract(const Duration(days: 1));

    String dateText;
    if (messageTime.year == now.year &&
        messageTime.month == now.month &&
        messageTime.day == now.day) {
      dateText = 'Today';
    } else if (messageTime.year == yesterday.year &&
        messageTime.month == yesterday.month &&
        messageTime.day == yesterday.day) {
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

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }
}
