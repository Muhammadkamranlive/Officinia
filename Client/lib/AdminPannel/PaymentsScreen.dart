import 'package:flutter/material.dart';

class Payment {
  final String name;
  final String amount;
  final String date;
  final String method;

  Payment({
    required this.name,
    required this.amount,
    required this.date,
    required this.method,
  });
}


class PaymentsScreen extends StatelessWidget {
  final List<Payment> payments;

  const PaymentsScreen({super.key, required this.payments});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recent Payments'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: payments.isEmpty
            ? const Center(
                child: Text(
                  'No payments found.',
                  style: TextStyle(fontSize: 16),
                ),
              )
            : ListView.separated(
                itemCount: payments.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final payment = payments[index];
                  return _paymentRow(
                      payment.name,
                      payment.amount,
                      payment.date,
                      payment.method);
                },
              ),
      ),
    );
  }

  Widget _paymentRow(
      String pharmacy, String amount, String date, String method) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(pharmacy,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 4),
              Text(date),
              const SizedBox(height: 2),
              Text(method),
            ],
          ),
          Text(amount,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.green)),
        ],
      ),
    );
  }
}
