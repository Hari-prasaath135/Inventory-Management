
class Product {
  final String id;
  final String name;
  final double price;
  final String hsnCode;
  final double gstRate;
  final int stockQuantity;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.hsnCode,
    required this.gstRate,
    required this.stockQuantity,
  });

  // Convert Product object to Firestore Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'hsnCode': hsnCode,
      'gstRate': gstRate,
      'stockQuantity': stockQuantity,
    };
  }

  // Convert Firestore Map to Product object
  factory Product.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return Product(
      id: id,
      name: map['name'] as String,
      price: (map['price'] as num).toDouble(),
      hsnCode: map['hsnCode'] as String,
      gstRate: (map['gstRate'] as num).toDouble(),
      stockQuantity: (map['stockQuantity'] as num).toInt(),
    );
  }

  Product copyWith({
    String? name,
    double? price,
    String? hsnCode,
    double? gstRate,
    int? stockQuantity,
  }) {
    return Product(
      id: id,
      name: name ?? this.name,
      price: price ?? this.price,
      hsnCode: hsnCode ?? this.hsnCode,
      gstRate: gstRate ?? this.gstRate,
      stockQuantity: stockQuantity ?? this.stockQuantity,
    );
  }
}