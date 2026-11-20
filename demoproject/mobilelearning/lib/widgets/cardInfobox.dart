import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:mobile_onboarding/constants.dart';

class FinancialInfoCard extends StatelessWidget {
  final String annualFee;
  final String fed;
  final String spendingReversal;
  final String duration;

  const FinancialInfoCard({
    super.key,
    required this.annualFee,
    required this.fed,
    required this.spendingReversal,
    required this.duration,
  });

  Widget _buildInfoItemHeadings(String title, String title2) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: newSecondaryColor),
            ),
            const SizedBox(height: 4),
            Text(
              title2,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: newSecondaryColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItemValues(
      String anual, String fed, String sr, String duration) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              '${anual} + ${fed}',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${sr} in ${duration}',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatNumber(String value) {
    try {
      final number = double.parse(value.replaceAll(',', ''));
      return NumberFormat.decimalPattern().format(number);
    } catch (_) {
      return value; // return as-is if not a number
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 20, top: 5, bottom: 5),
      margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 2,
            offset: Offset(0, 0),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildInfoItemHeadings("Annual Fee + FED ", "Spending Reversal"),
              // _buildInfoItem("FED", fed),
            ],
          ),
          // SizedBox(height: 2.h),
          Row(
            children: [
              _buildInfoItemValues(_formatNumber(annualFee), fed,
                  _formatNumber(spendingReversal), duration)
              // _buildInfoItem("Spending Reversal", spendingReversal),
              // _buildInfoItem("Duration", duration),
            ],
          ),
        ],
      ),
    );
  }
}
