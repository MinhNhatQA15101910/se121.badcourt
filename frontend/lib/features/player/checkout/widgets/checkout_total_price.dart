import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class CheckoutTotalPrice extends StatelessWidget {
  final double promotionPrice;
  final double subTotalPrice;

  const CheckoutTotalPrice({
    super.key,
    required this.promotionPrice,
    required this.subTotalPrice,
  });

  @override
  Widget build(BuildContext context) {
    final totalPrice = subTotalPrice - promotionPrice;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: GlobalVariables.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.receipt_long,
                  color: GlobalVariables.green,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Payment Summary',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: GlobalVariables.blackGrey,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Price breakdown
          _buildPriceRow(
            'Subtotal',
            subTotalPrice,
            isSubtotal: true,
          ),
          
          const SizedBox(height: 12),
          
          if (promotionPrice > 0) ...[
            _buildPriceRow(
              'Promotion Discount',
              -promotionPrice,
              isDiscount: true,
            ),
            const SizedBox(height: 12),
          ],
          
          // Divider
          Container(
            height: 1,
            color: GlobalVariables.lightGrey,
            margin: const EdgeInsets.symmetric(vertical: 12),
          ),
          
          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Amount',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: GlobalVariables.blackGrey,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'VAT included',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: GlobalVariables.darkGrey,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: GlobalVariables.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${NumberFormat('#,###').format(totalPrice)} đ',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: GlobalVariables.green,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isSubtotal = false, bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: GlobalVariables.blackGrey,
          ),
        ),
        Text(
          '${isDiscount ? '-' : ''}${NumberFormat('#,###').format(amount.abs())} đ',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDiscount ? GlobalVariables.green : GlobalVariables.blackGrey,
          ),
        ),
      ],
    );
  }
}
