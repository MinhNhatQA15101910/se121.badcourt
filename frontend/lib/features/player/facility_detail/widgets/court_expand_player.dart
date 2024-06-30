import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/player/facility_detail/widgets/booking_widget_player.dart';
import 'package:frontend/models/court.dart';

class CourtExpandPlayer extends StatefulWidget {
  final Court court;
  final DateTime currentDateTime;
  final Function(Court)? onExpansionChanged;

  const CourtExpandPlayer({
    Key? key,
    required this.court,
    required this.currentDateTime,
    this.onExpansionChanged,
  }) : super(key: key);

  @override
  State<CourtExpandPlayer> createState() => _CourtExpandPlayerState();
}

class _CourtExpandPlayerState extends State<CourtExpandPlayer> {
  bool _isExpanded = false;

  void _handleExpansion(bool isExpanded) {
    setState(() {
      _isExpanded = isExpanded;
    });
    if (widget.onExpansionChanged != null) {
      widget.onExpansionChanged!(widget.court);
    }
  }

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
                widget.court.name ?? '',
                style: TextStyle(
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
                widget.court.description ?? '',
                textAlign: TextAlign.start,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: GlobalVariables.darkGrey,
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            onExpansionChanged: _handleExpansion,
            children: [
              BookingWidgetPlayer(
                court: widget.court,
                currentDateTime: widget.currentDateTime,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
