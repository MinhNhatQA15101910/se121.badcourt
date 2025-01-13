import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:http/http.dart' as http;

void httpErrorHandler({
  required http.Response response,
  required BuildContext context,
  required VoidCallback onSuccess,
}) {
  switch (response.statusCode) {
    case 200:
      onSuccess();
      break;
    case 201:
      onSuccess();
      break;
    case 204:
      onSuccess();
      break;
    case 400:
      IconSnackBar.show(
        context,
        label: jsonDecode(response.body)['msg'],
        snackBarType: SnackBarType.alert,
      );
      break;
    case 500:
      IconSnackBar.show(
        context,
        label: jsonDecode(response.body)['msg'],
        snackBarType: SnackBarType.fail,
      );
      break;
    default:
      IconSnackBar.show(
        context,
        label: response.body,
        snackBarType: SnackBarType.alert,
      );
      break;
  }
}
