class Product {
  final String id; // Add this line
  final String title;
  final String description;
  final String base64Image;
  final List<dynamic> itemDetailList;
  final bool isRequired;

  Product({
    required this.id, // Add this line
    required this.title,
    required this.description,
    required this.base64Image,
    required this.itemDetailList,
    required this.isRequired,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id']?.toString() ?? '', // Ensure id is a String
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? 'No Description',
      base64Image: json['imageBase64'] ?? '',
      itemDetailList: json['itemsDetails'] ?? [],
      isRequired: json['isRequired'] ?? false,
    );
  }
}
