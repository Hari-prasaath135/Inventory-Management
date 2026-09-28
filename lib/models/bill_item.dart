
import 'product.dart';

class BillItem {
  final Product product;
  int quantity;

  BillItem({
    required this.product,
    required this.quantity,
  });

  double get subtotal => product.price * quantity;

  // Convert BillItem to Firestore Map
  Map<String, dynamic> toMap() {
    return {
      'productId': product.id,
      'productName': product.name,
      'price': product.price,
      'hsnCode': product.hsnCode,
      'gstRate': product.gstRate,
      'quantity': quantity,
      'subtotal': subtotal,
    };
  }

  // Convert Firestore Map to BillItem
  factory BillItem.fromMap(Map<String, dynamic> map) {
    final product = Product(
      id: map['productId'] as String,
      name: map['productName'] as String,
      price: (map['price'] as num).toDouble(),
      hsnCode: map['hsnCode'] as String,
      gstRate: (map['gstRate'] as num).toDouble(),
      stockQuantity: 0,
    );

    return BillItem(
      product: product,
      quantity: (map['quantity'] as num).toInt(),
    );
  }
}