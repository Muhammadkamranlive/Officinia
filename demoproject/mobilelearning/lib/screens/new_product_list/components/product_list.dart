// widgets/product_list_view.dart

import 'package:flutter/material.dart';
import 'package:mobile_onboarding/screens/new_product_list/components/model/product_model.dart';

import 'product_card.dart';

class ProductListView extends StatelessWidget {
  final List<Product> products;

  ProductListView({required this.products});

  @override
  Widget build(BuildContext context) {
    // Calculate available height for cards
    final double availableHeight = MediaQuery.of(context).size.height;
    const double topRowHeight = 80.0; // Approximate height of TopRow
    final double cardHeight = (availableHeight - topRowHeight) * 0.60;

    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        return ProductCard(product: products[index]);
      },
    );
  }
}
