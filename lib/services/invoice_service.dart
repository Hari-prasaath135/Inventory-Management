

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/invoice.dart';

class InvoiceService {
  final CollectionReference<Map<String, dynamic>> _invoicesCollection =
      FirebaseFirestore.instance.collection('invoices');

  // Save invoice to Firestore
  Future<void> addInvoice(Invoice invoice) async {
    await _invoicesCollection.doc(invoice.id).set(invoice.toMap());
  }

  // Get all invoices from Firestore
  Future<List<Invoice>> getInvoices() async {
    final snapshot = await _invoicesCollection
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      return Invoice.fromMap(doc.id, doc.data());
    }).toList();
  }

  // Update invoice in Firestore
  Future<void> updateInvoice(Invoice invoice) async {
    await _invoicesCollection.doc(invoice.id).update(invoice.toMap());
  }

  // Delete invoice from Firestore
  Future<void> deleteInvoice(String id) async {
    await _invoicesCollection.doc(id).delete();
  }
  
  // Cancel invoice and restore stock atomically
  Future<void> cancelInvoiceAndRestoreStock(
    Invoice invoice,
  ) async {
    final firestore = FirebaseFirestore.instance;

    final invoiceRef = _invoicesCollection.doc(invoice.id);

    await firestore.runTransaction((transaction) async {
      final invoiceSnapshot = await transaction.get(invoiceRef);

      if (!invoiceSnapshot.exists) {
        throw Exception('Invoice not found');
      }

      final invoiceData = invoiceSnapshot.data();

      if (invoiceData == null) {
        throw Exception('Invoice data is missing');
      }

      // Prevent duplicate cancellation
      final alreadyCancelled =
          invoiceData['isCancelled'] as bool? ?? false;

      if (alreadyCancelled) {
        throw Exception('Invoice is already cancelled');
      }

      // Restore stock for each product
      for (final item in invoice.items) {
        final productRef = firestore
            .collection('products')
            .doc(item.product.id);

        final productSnapshot = await transaction.get(productRef);

        if (!productSnapshot.exists) {
          throw Exception(
            'Product not found: ${item.product.name}',
          );
        }

        final productData = productSnapshot.data();

        if (productData == null) {
          throw Exception('Product data is missing');
        }

        final currentStock =
            (productData['stockQuantity'] as num).toInt();

        transaction.update(productRef, {
          'stockQuantity': currentStock + item.quantity,
        });
      }

      // Mark invoice as cancelled
      transaction.update(invoiceRef, {
        'isCancelled': true,
      });
    });
  }
}