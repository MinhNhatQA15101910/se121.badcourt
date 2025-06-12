import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
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
  // Thêm state để theo dõi tin nhắn mới
  bool _hasNewMessage = false;

  @override
  void initState() {
    super.initState();
    // Kết nối GroupHub khi widget được khởi tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeGroupHub();
      _setupNewMessageListener();
    });
  }

  // Thêm method để lắng nghe tin nhắn mới
  void _setupNewMessageListener() {
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    
    // Lắng nghe thay đổi trong GroupProvider
    groupProvider.addListener(() {
      if (mounted) {
        final newUnreadCount = groupProvider.unreadMessageCount;
        if (newUnreadCount > 0 && !_hasNewMessage) {
          setState(() {
            _hasNewMessage = true;
          });
          
          // Tự động ẩn thông báo sau 3 giây
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) {
              setState(() {
                _hasNewMessage = false;
              });
            }
          });
        }
      }
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
        
        // Set current user ID and calculate unread count after initialization
        if (userProvider.user.id.isNotEmpty) {
          groupProvider.setCurrentUserId(userProvider.user.id);
        }
        
        print('[MessageButton] GroupHub initialized');
      } catch (e) {
        print('[MessageButton] Error initializing GroupHub: $e');
      }
    } else if (groupProvider.isConnected && userProvider.user.id.isNotEmpty) {
      // Already connected, just set user ID
      groupProvider.setCurrentUserId(userProvider.user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<GroupProvider, UserProvider>(
      builder: (context, groupProvider, userProvider, _) {
        // Ensure current user ID is set
        if (userProvider.user.id.isNotEmpty && groupProvider.isConnected) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            groupProvider.setCurrentUserId(userProvider.user.id);
          });
        }
        
        final unreadCount = groupProvider.unreadMessageCount;
        
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: _hasNewMessage ? [
              BoxShadow(
                color: GlobalVariables.green.withOpacity(0.5),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ] : null,
          ),
          child: Stack(
            children: [
              IconButton(
                onPressed: () {
                  // Reset new message indicator
                  setState(() {
                    _hasNewMessage = false;
                  });
                  
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
                icon: Icon(
                  _hasNewMessage ? Icons.message : Icons.message_outlined,
                  color: _hasNewMessage ? GlobalVariables.yellow : Colors.white,
                ),
              ),
              
              // Badge hiển thị số tin nhắn chưa đọc
              if (unreadCount > 0)
                Positioned(
                  right: 5,
                  top: 5,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: _hasNewMessage ? GlobalVariables.yellow : Colors.red,
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
                      style: TextStyle(
                        color: _hasNewMessage ? Colors.black : Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                
              // Hiệu ứng pulse khi có tin nhắn mới
              if (_hasNewMessage)
                Positioned.fill(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 1000),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: GlobalVariables.green.withOpacity(0.6),
                        width: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
