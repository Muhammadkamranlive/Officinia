import 'package:client/AppColors/AppColors.dart';
import 'package:client/widgets/transaction_list.dart';
import 'package:flutter/material.dart';


class RecruiterPayment extends StatelessWidget {
  const RecruiterPayment({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Subscription'),
      ),
      backgroundColor: AppColors.background, // set white for body below gradient
      body: SafeArea(
        child:Column(
          children: [
            const SizedBox(height: 16),
             Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                 TransactionList(),
                ],
              ),
            ),
        ),
          ],
        ),
        
      ),
      
    );
  }
}

