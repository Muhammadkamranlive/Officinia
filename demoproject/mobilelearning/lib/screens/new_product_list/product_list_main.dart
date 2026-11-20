// screens/product_list_screen.dart

import 'package:flutter/material.dart';
import 'package:mobile_onboarding/constants.dart';
import 'package:mobile_onboarding/screens/new_product_list/components/api_service/products_json.dart';
import 'package:mobile_onboarding/screens/new_product_list/components/product_list.dart';
import 'package:mobile_onboarding/screens/new_product_list/components/top_row.dart';
import 'package:provider/provider.dart';

class NewProductListScreen extends StatefulWidget {
  static const routeName = '/newProductList';

  @override
  _NewProductListScreenState createState() => _NewProductListScreenState();
}

class _NewProductListScreenState extends State<NewProductListScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      FocusScope.of(context).unfocus(); // Ensures keyboard is closed on entry
    });
    // Fetch data when the screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ApiService>(context, listen: false).fetchData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final apiService = Provider.of<ApiService>(context);

    return Scaffold(
      backgroundColor: ScaffoldBackground,
      body: Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
            TopRow(),
            Expanded(
              child: apiService.products.isNotEmpty
                  ? ProductListView(products: apiService.products)
                  : Center(child: CircularProgressIndicator()),
            ),
          ],
        ),
      ),
    );
  }
}
