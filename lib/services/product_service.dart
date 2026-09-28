
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product.dart';

class ProductService {
  final CollectionReference<Map<String, dynamic>> _productsCollection =
      FirebaseFirestore.instance.collection('products');

  // Add a new product
  Future<void> addProduct(Product product) async {
    await _productsCollection.doc(product.id).set(product.toMap());
  }

  // Get all products
  Future<List<Product>> getProducts() async {
    final snapshot = await _productsCollection.get();

    return snapshot.docs.map((doc) {
      return Product.fromMap(doc.id, doc.data());
    }).toList();
  }

  // Update an existing product
  Future<void> updateProduct(Product product) async {
    await _productsCollection.doc(product.id).update(product.toMap());
  }

  // Delete a product
  Future<void> deleteProduct(String id) async {
    await _productsCollection.doc(id).delete();
  }
  
  // Reduce stock using a Firestore transaction
  Future<void> reduceStock({
    required String productId,
    required int quantity,
  }) async {
    final productRef = _productsCollection.doc(productId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(productRef);

      if (!snapshot.exists) {
        throw Exception('Product not found');
      }

      final data = snapshot.data();

      if (data == null) {
        throw Exception('Product data is missing');
      }

      final currentStock = (data['stockQuantity'] as num).toInt();

      if (currentStock < quantity) {
        throw Exception('Insufficient stock');
      }

      transaction.update(productRef, {
        'stockQuantity': currentStock - quantity,
      });
    });
  }

  // Restore stock using a Firestore transaction
  Future<void> restoreStock({
    required String productId,
    required int quantity,
  }) async {
    final productRef = _productsCollection.doc(productId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(productRef);

      if (!snapshot.exists) {
        throw Exception('Product not found');
      }

      final data = snapshot.data();

      if (data == null) {
        throw Exception('Product data is missing');
      }

      final currentStock = (data['stockQuantity'] as num).toInt();

      transaction.update(productRef, {
        'stockQuantity': currentStock + quantity,
      });
    });
  }
}