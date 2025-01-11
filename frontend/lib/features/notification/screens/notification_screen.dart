import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/notification/widgets/notification_item.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationScreen extends StatefulWidget {
  static const String routeName = '/notificationScreen';
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: GlobalVariables.green,
        title: Text(
          'Notification',
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
            NotificationItem(
              title: 'Thông báo đặt sân thành công',
              description:
                  'Sân của bạn đã được đặt tại địa điểm sân cầu lông nhật duy',
              createdAt: DateTime.now(),
            ),
            NotificationItem(
              title: 'Thông báo đặt sân thành công',
              description:
                  'Sân của bạn đã được đặt tại địa điểm sân cầu lông nhật duy',
              createdAt: DateTime.now(),
            ),
            NotificationItem(
              title: 'Thông báo đặt sân thành công',
              description:
                  'Sân của bạn đã được đặt tại địa điểm sân cầu lông nhật duy',
              createdAt: DateTime.now(),
            ),
            NotificationItem(
              title: 'Thông báo đặt sân thành công',
              description:
                  'Sân của bạn đã được đặt tại địa điểm sân cầu lông nhật duy',
              createdAt: DateTime.now(),
            ),
          ],
        ),
      ),
    );
  }
}
