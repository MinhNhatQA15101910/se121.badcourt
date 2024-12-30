import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/message/widgets/user_message_box.dart';
import 'package:google_fonts/google_fonts.dart';

class MessageScreen extends StatefulWidget {
  static const String routeName = '/messageScreen';
  const MessageScreen({Key? key}) : super(key: key);

  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> messages = [
    {
      'userName': 'Nhật Duy',
      'lastMessage': 'Chào bạn, mình muốn thuê sân',
      'timestamp': '29/03/2024',
      'userImageUrl': 'https://via.placeholder.com/150',
    },
    {
      'userName': 'Nhật Duy',
      'lastMessage': 'Mình muốn đặt sân này',
      'timestamp': '29/03/2024',
      'userImageUrl': 'https://via.placeholder.com/150',
    },
    // Add more messages here
  ];
  List<Map<String, String>> filteredMessages = [];

  @override
  void initState() {
    super.initState();
    filteredMessages =
        messages; // Initialize filtered messages with all messages
  }

  void _filterMessages(String query) {
    setState(() {
      filteredMessages = messages
          .where((message) =>
              message['userName']!
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              message['lastMessage']!
                  .toLowerCase()
                  .contains(query.toLowerCase()))
          .toList();
    });
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
            Expanded(
              child: ListView.builder(
                itemCount: filteredMessages.length,
                itemBuilder: (context, index) {
                  final message = filteredMessages[index];
                  return UserMessageBox(
                    userName: message['userName']!,
                    lastMessage: message['lastMessage']!,
                    timestamp: message['timestamp']!,
                    userImageUrl: message['userImageUrl']!,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
