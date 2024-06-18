import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/manager/datetime_management/widgets/booking_widget.dart';

class CourtExpand extends StatefulWidget {
  final String titleText;
  final String descriptionText;

  const CourtExpand(
      {Key? key, required this.titleText, required this.descriptionText})
      : super(key: key);

  @override
  State<CourtExpand> createState() => _CourtExpandState();
}

class _CourtExpandState extends State<CourtExpand> {
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
                widget.titleText,
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
                widget.descriptionText,
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
