import 'package:flutter/material.dart';
import 'package:frontend/features/player/facility_detail/widgets/booking_widget.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:provider/provider.dart';

class CourtDetailScreen extends StatelessWidget {
  const CourtDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BookingWidget(),
    );
  }
}
