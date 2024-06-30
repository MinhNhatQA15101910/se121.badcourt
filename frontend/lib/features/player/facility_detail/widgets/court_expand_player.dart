import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/manager/datetime_management/widgets/booking_widget.dart';
import 'package:frontend/models/court.dart';
import 'package:frontend/models/facility.dart';

class CourtExpandPlayer extends StatefulWidget {
  final Court court;

  const CourtExpandPlayer({Key? key, required this.court}) : super(key: key);

  @override
  State<CourtExpandPlayer> createState() => _CourtExpandPlayerState();
}

class _CourtExpandPlayerState extends State<CourtExpandPlayer> {
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData().copyWith(
        dividerColor: Colors.transparent,
      ),
      child: Padding(
        padding: EdgeInsets.only(
          top: 12,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: GlobalVariables.darkGrey,
              width: 0.5,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: ExpansionTile(
            title: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                widget.court.name,
                style: const TextStyle(
                  color: GlobalVariables.blackGrey,
                  fontSize: 20,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                widget.court.description,
                textAlign: TextAlign.start,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: GlobalVariables.darkGrey,
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            children: const [
              BookingWidget(),
              BookingWidget(),
              BookingWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
