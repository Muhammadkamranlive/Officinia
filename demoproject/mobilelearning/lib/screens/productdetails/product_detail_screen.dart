import 'package:flutter/material.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/screen_arguments.dart';
import '../productdetails/components/body.dart';

class ProductsDetailScreen extends StatelessWidget {
  static String routeName = "/product_details";

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as ScreenArguments;

    return Scaffold(
      //appBar: buildAppBar(context, "Product Details"),
      appBar: CustomAppBar(true, false),
      body: Body(args.itemDetails),
    );
  }
}
