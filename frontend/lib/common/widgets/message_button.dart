import 'package:flutter/material.dart';
import 'package:frontend/features/message/pages/message_screen.dart';
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
  @override
  void initState() {
    super.initState();
    // Kết nối GroupHub khi widget được khởi tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeGroupHub();
    });
  }

  // Khởi tạo kết nối GroupHub
  Future<void> _initializeGroupHub() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    
    if (userProvider.user.token.isNotEmpty && !groupProvider.isConnected) {
      try {
        await groupProvider.initializeGroupHub(
          userProvider.user.token,
        );
        print('[MessageButton] GroupHub initialized');
      } catch (e) {
        print('[MessageButton] Error initializing GroupHub: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GroupProvider>(
      builder: (context, groupProvider, _) {
        final unreadCount = groupProvider.unreadMessageCount;
        
        return Stack(
          children: [
            IconButton(
              onPressed: () {
                // Gọi callback nếu có
                if (widget.onMessageButtonPressed != null) {
                  widget.onMessageButtonPressed!();
                }
                
                // Chuyển đến màn hình tin nhắn
                Navigator.pushNamed(
                  context, 
                  MessageScreen.routeName,
                );
              },
              icon: const Icon(
                Icons.message_outlined,
                color: Colors.white,
              ),
            ),
            
            // Badge hiển thị số tin nhắn chưa đọc
            if (unreadCount > 0)
              Positioned(
                right: 5,
                top: 5,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white,
                      width: 1,
                    ),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Text(
                    unreadCount > 99 ? '99+' : unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
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
