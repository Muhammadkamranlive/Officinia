import 'package:mobile_onboarding/model/product_services_model.dart';

class ProductsDetails {
  final List<ProductsData> categoriesData;
  final List<ProductsData> accountData;
  final List<ProductsData> productData;

  ProductsDetails({
    required this.categoriesData,
    required this.accountData,
    required this.productData,
  });

  factory ProductsDetails.fromJson(dynamic json) {
    return ProductsDetails(
      categoriesData: json['fields_categories'] as List<ProductsData>,
      accountData: json['fields_accounts'] as List<ProductsData>,
      productData: json['fields_products'] as List<ProductsData>,
    );
  }

  @override
  String toString() {
    return '{ ${this.categoriesData.length}, ${this.accountData.length}, ${this.productData.length} }';
  }
}
