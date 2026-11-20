class Product_new {
  final String label;
  final int value;
  final String attribute;
  final String minAmount;
  final String maxAmount;
  final String annualFee;
  final String productCode;
  final String imageBase64;
  final String? description;
  final String fed;
  final String spendingReversal;
  final String duration;

  Product_new({
    required this.label,
    required this.value,
    required this.attribute,
    required this.minAmount,
    required this.maxAmount,
    required this.annualFee,
    required this.productCode,
    required this.imageBase64,
    this.description,
    required this.fed,
    required this.spendingReversal,
    required this.duration,
  });

  factory Product_new.fromJson(Map<String, dynamic> json) {
    return Product_new(
      label: json['label'] as String,
      value: json['value'] as int,
      attribute: json['attribute'] as String,
      minAmount: json['minAmount'] as String,
      maxAmount: json['maxAmount'] as String,
      annualFee: json['annualFee'] as String,
      productCode: json['productCode'] as String,
      imageBase64: json['image'] as String,
      description: json['discription'] as String?,
      fed: json['fed'] as String,
      spendingReversal: json['spendingReversal'] as String,
      duration: json['duration'] as String,
    );
  }
}
