import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/invoice.dart';

class InvoiceService {
  final CollectionReference<Map<String, dynamic>>
      _invoicesCollection =
      FirebaseFirestore.instance.collection('invoices');

  // ============================================================
  // SAVE INVOICE
  // ============================================================

  Future<void> addInvoice(Invoice invoice) async {
    await _invoicesCollection
        .doc(invoice.id)
        .set(invoice.toMap());
  }

  // ============================================================
  // GET ALL INVOICES
  // ============================================================

  Future<List<Invoice>> getInvoices() async {
    final snapshot = await _invoicesCollection
        .orderBy(
          'createdAt',
          descending: true,
        )
        .get();

    return snapshot.docs.map((doc) {
      return Invoice.fromMap(
        doc.id,
        doc.data(),
      );
    }).toList();
  }

  // ============================================================
  // UPDATE INVOICE
  // ============================================================

  Future<void> updateInvoice(
    Invoice invoice,
  ) async {
    await _invoicesCollection
        .doc(invoice.id)
        .update(invoice.toMap());
  }

  // ============================================================
  // CANCEL INVOICE
  // ============================================================
  //
  // New billing architecture:
  //
  // Cancel invoice
  //       ↓
  // isCancelled = true
  //       ↓
  // Firestore
  //
  // No stock restoration.
  // ============================================================

  Future<void> cancelInvoice(
    Invoice invoice,
  ) async {
    await _invoicesCollection
        .doc(invoice.id)
        .update({
      'isCancelled': true,
    });
  }

  // ============================================================
  // DELETE INVOICE
  // ============================================================

  Future<void> deleteInvoice(
    String id,
  ) async {
    await _invoicesCollection
        .doc(id)
        .delete();
  }
}