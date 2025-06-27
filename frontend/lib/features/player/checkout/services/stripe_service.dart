import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:frontend/constants/error_handling.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class StripeService {
  // Step 1: Create order and get client_secret
  Future<Map<String, dynamic>?> createOrder(
    BuildContext context,
    String courtId,
    DateTime startTime,
    DateTime endTime,
  ) async {
    final userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );

    final requestBody = {
      "courtId": courtId,
      "dateTimePeriod": {
        "hourFrom": startTime.toIso8601String(),
        "hourTo": endTime.toIso8601String(),
      },
      "timeZoneId": "SE Asia Standard Time"
    };

    try {
      final response = await http.post(
        Uri.parse('$uri/gateway/orders'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${userProvider.user.token}',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {
          'clientSecret': responseData['clientSecret'],
          'orderId': responseData['orderId'],
        };
      } else {
        throw Exception('Failed to create order: ${response.body}');
      }
    } catch (error) {
      IconSnackBar.show(
        context,
        label: 'Failed to create order: ${error.toString()}',
        snackBarType: SnackBarType.fail,
      );
      return null;
    }
  }

  // Step 2: Confirm payment with Stripe
  Future<PaymentIntent?> confirmPayment(
    String clientSecret,
    BuildContext context,
  ) async {
    try {
      // Initialize payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Court Booking App',
          style: ThemeMode.light,
        ),
      );

      // Present payment sheet
      await Stripe.instance.presentPaymentSheet();

      // If we reach here, payment was successful
      final paymentIntent = await Stripe.instance.retrievePaymentIntent(clientSecret);
      return paymentIntent;
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) {
        IconSnackBar.show(
          context,
          label: 'Payment cancelled',
          snackBarType: SnackBarType.fail,
        );
      } else {
        IconSnackBar.show(
          context,
          label: 'Payment failed: ${e.error.message}',
          snackBarType: SnackBarType.fail,
        );
      }
      return null;
    } catch (e) {
      IconSnackBar.show(
        context,
        label: 'Payment error: ${e.toString()}',
        snackBarType: SnackBarType.fail,
      );
      return null;
    }
  }

  // Removed: checkOrderStatus is no longer needed as per user request.
  // Future<Map<String, dynamic>?> checkOrderStatus(...) { ... }

  // Complete payment flow
  Future<bool> processPayment(
    BuildContext context,
    String courtId,
    DateTime startTime,
    DateTime endTime,
  ) async {
    try {
      // Step 1: Create order
      final orderData = await createOrder(context, courtId, startTime, endTime);
      if (orderData == null) return false;

      final clientSecret = orderData['clientSecret'];
      // final orderId = orderData['orderId']; // orderId is not used in this simplified flow

      // Step 2: Confirm payment with Stripe
      final paymentIntent = await confirmPayment(clientSecret, context);
      if (paymentIntent == null) {
        // Payment was cancelled or failed in Stripe UI
        return false;
      }

      // Payment is considered successful after confirmPayment completes
      IconSnackBar.show(
        context,
        label: 'Payment successful! Booking confirmed.',
        snackBarType: SnackBarType.success,
      );
      return true;
      
    } catch (e) {
      IconSnackBar.show(
        context,
        label: 'Payment process failed: ${e.toString()}',
        snackBarType: SnackBarType.fail,
      );
      return false;
    }
  }
}
