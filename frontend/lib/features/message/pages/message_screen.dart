import 'package:flutter/material.dart';
import 'package:frontend/common/services/socket_service.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/message/services/message_service.dart';
import 'package:frontend/features/message/widgets/user_message_box.dart';
import 'package:frontend/models/message_room.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class MessageScreen extends StatefulWidget {
  static const String routeName = '/messageScreen';

  const MessageScreen({Key? key}) : super(key: key);

  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final TextEditingController _searchController = TextEditingController();
  final MessageService _messageService = MessageService();
  final SocketService _socketService = SocketService();

  List<MessageRoom> messages = [];
  List<dynamic> filteredMessages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMessageRooms();

    // Lắng nghe sự kiện messageRoomUpdate từ socket
    _socketService.onMessageRoomUpdate((updatedMessageRoom) {
      setState(() {
        // Cập nhật danh sách messages: thay thế hoặc thêm mới MessageRoom
        messages.removeWhere((room) => room.id == updatedMessageRoom.id);
        messages.add(updatedMessageRoom);

        // Cập nhật danh sách filteredMessages nếu cần
        filteredMessages = List.from(messages);
      });
    });
  }

  Future<void> _fetchMessageRooms() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final messageRooms =
          await _messageService.getMessageRooms(context: context);
      setState(() {
        messages = messageRooms;
        filteredMessages = messageRooms;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching messages: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: GlobalVariables.green,
        title: Text(
          'Message',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            decoration: TextDecoration.none,
            color: GlobalVariables.white,
          ),
        ),
      ),
      body: Container(
        color: GlobalVariables.defaultColor,
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Find recent user',
                  hintStyle: GoogleFonts.inter(
                    color: GlobalVariables.darkGrey,
                    fontSize: 16,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: GlobalVariables.lightGreen,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: GlobalVariables.lightGreen,
                    ),
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: GlobalVariables.darkGrey,
                  ),
                ),
                style: GoogleFonts.inter(
                  fontSize: 16,
                ),
              ),
            ),
            // Message list
            _isLoading
                ? const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
                      itemCount: filteredMessages.length,
                      itemBuilder: (context, index) {
                        final message = filteredMessages[index];

                        // Lấy thông tin user hiện tại
                        final currentUserId =
                            Provider.of<UserProvider>(context, listen: false)
                                .user
                                .id;

                        // Tìm user khác với user hiện tại
                        final user = message.users.firstWhere(
                          (u) => u.id != currentUserId,
                          orElse: () => User(
                            id: 'default',
                            username: 'Default User',
                            email: 'default@example.com',
                            imageUrl: '',
                            role: 'Unknown',
                          ),
                        );

                        return UserMessageBox(
                          userName: user.username,
                          lastMessage: message.lastMessage?.content ?? '',
                          timestamp: _formatTimestamp(
                              message.updatedAt.millisecondsSinceEpoch),
                          userImageUrl: user.imageUrl,
                          role: user.role,
                          userId: user.id,
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(int? timestamp) {
    if (timestamp == null) return '';
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
