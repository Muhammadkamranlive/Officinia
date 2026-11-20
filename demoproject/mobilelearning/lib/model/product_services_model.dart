class ProductsData {
  bool isRequired;
  String type;
  String title;
  String description;
  String imageURL;
  List<ProductsData> itemsDetails;

  ProductsData(this.isRequired, this.type, this.title, this.description,
      this.imageURL, this.itemsDetails);

  factory ProductsData.fromJson(dynamic json) {
    if (json['ItemsDetails'] != null) {
      var itemsObjsJson = json['ItemsDetails'] as List;
      List<ProductsData> _itemDetails = itemsObjsJson
          .map((tagJson) => ProductsData.fromJson(tagJson))
          .toList();

      return ProductsData(
          json['isRequired'] as bool,
          json['Type'] as String,
          json['ImageURL'] as String,
          json['Title'] as String,
          json['Description'] as String,
          _itemDetails);
    } else {
      List<ProductsData> _itemDetails = [];
      return ProductsData(
          json['isRequired'] as bool,
          json['Type'] as String,
          json['ImageURL'] as String,
          json['Title'] as String,
          json['Description'] as String,
          _itemDetails);
    }
  }
}
