import 'dart:ui';

import 'package:frontend/constants/global_variables.dart';

enum FacilityState {
  none,
  pending,
  approved,
  rejected,
}

extension FacilityStateExtension on FacilityState {
  String get displayName {
    switch (this) {
      case FacilityState.none:
        return 'None';
      case FacilityState.pending:
        return 'Pending';
      case FacilityState.approved:
        return 'Approved';
      case FacilityState.rejected:
        return 'Rejected';
    }
  }

  Color get badgeColor {
    switch (this) {
      case FacilityState.none:
        return GlobalVariables.lightGrey;
      case FacilityState.pending:
        return GlobalVariables.lightYellow;
      case FacilityState.approved:
        return GlobalVariables.lightGreen;
      case FacilityState.rejected:
        return GlobalVariables.lightRed;
    }
  }

  Color get textColor {
    switch (this) {
      case FacilityState.none:
        return GlobalVariables.grey;
      case FacilityState.pending:
        return GlobalVariables.darkYellow;
      case FacilityState.approved:
        return GlobalVariables.darkGreen;
      case FacilityState.rejected:
        return GlobalVariables.darkRed;
    }
  }

  String get apiValue {
    switch (this) {
      case FacilityState.none:
        return 'none';
      case FacilityState.pending:
        return 'pending';
      case FacilityState.approved:
        return 'approved';
      case FacilityState.rejected:
        return 'rejected';
    }
  }

  static FacilityState fromString(String state) {
    switch (state.toLowerCase()) {
      case 'pending':
        return FacilityState.pending;
      case 'approved':
        return FacilityState.approved;
      case 'rejected':
        return FacilityState.rejected;
      case 'none':
      default:
        return FacilityState.none;
    }
  }
}