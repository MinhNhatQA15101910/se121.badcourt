import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/player/facility_detail/widgets/booking_widget_player.dart';
import 'package:frontend/models/court.dart';
import 'package:frontend/providers/court_provider.dart';
import 'package:provider/provider.dart';

class CourtExpandPlayer extends StatelessWidget {
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
          child: Consumer<CourtState>(
            builder: (context, courtState, child) {
              return ExpansionTile(
                title: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    court.name ?? '',
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
                    court.description ?? '',
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
                onExpansionChanged: (isExpanded) {
                  courtState.toggleExpanded();
                  if (onExpansionChanged != null) {
                    onExpansionChanged!(court);
                  }
                },
                children: [
                  BookingWidgetPlayer(
                    court: court,
                    currentDateTime: currentDateTime,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
