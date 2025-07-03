import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/message/screens/message_screen.dart';
import 'package:frontend/providers/group_provider.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:provider/provider.dart';

class MessageButton extends StatefulWidget {
  final String userId;
  final VoidCallback? onMessageButtonPressed;

  const MessageButton({
    Key? key,
    required this.userId,
    this.onMessageButtonPressed,
  }) : super(key: key);

  @override
  State<MessageButton> createState() => _MessageButtonState();
}

class _MessageButtonState extends State<MessageButton> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeGroupHub();
    });
  }

  Future<void> _initializeGroupHub() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);

    if (userProvider.user.token.isNotEmpty && !groupProvider.isConnected) {
      try {
        await groupProvider.initializeGroupHub(userProvider.user.token);
        if (userProvider.user.id.isNotEmpty) {
          groupProvider.setCurrentUserId(userProvider.user.id);
        }
        print('[MessageButton] GroupHub initialized');
      } catch (e) {
        print('[MessageButton] Error initializing GroupHub: $e');
      }
    } else if (groupProvider.isConnected && userProvider.user.id.isNotEmpty) {
      groupProvider.setCurrentUserId(userProvider.user.id);
    }
  }

  Future<void> _handleMessagePressed() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.onMessageButtonPressed != null) {
        widget.onMessageButtonPressed!();
      }

      await Navigator.pushNamed(context, MessageScreen.routeName);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<GroupProvider, UserProvider>(
      builder: (context, groupProvider, userProvider, _) {
        if (userProvider.user.id.isNotEmpty && groupProvider.isConnected) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            groupProvider.setCurrentUserId(userProvider.user.id);
          });
        }

        final unreadCount = groupProvider.unreadMessageCount;
        final hasNewMessage = unreadCount > 0;

        return Stack(
          children: [
            IconButton(
              onPressed: _handleMessagePressed,
              icon: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(
                      Icons.message_outlined,
                      color: Colors.white,
                    ),
            ),

            // Dấu chấm nhỏ + số
            if (hasNewMessage)
              Positioned(
                left: 26,
                top: 6,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: GlobalVariables.white, width: 0.5)),
                  constraints: const BoxConstraints(
                    minWidth: 12,
                    minHeight: 12,
                  ),
                  child: Text(
                    unreadCount > 99 ? '99' : unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
