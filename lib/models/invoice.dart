import 'bill_item.dart';

class Invoice {
  final String id;
  final String invoiceNumber;
  final DateTime createdAt;

  // Customer / Bill To details
  final String customerName;

  final List<BillItem> items;

  final double subtotal;
  final double cgst;
  final double sgst;
  final double igst;
  final double totalGst;
  final double grandTotal;
  final bool isCancelled;

  Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.createdAt,
    required this.customerName,
    required this.items,
    required this.subtotal,
    required this.cgst,
    required this.sgst,
    required this.igst,
    required this.totalGst,
    required this.grandTotal,
    this.isCancelled = false,
  });

  // Convert Invoice to Firestore Map
  Map<String, dynamic> toMap() {
    return {
      'invoiceNumber': invoiceNumber,
      'createdAt': createdAt.toIso8601String(),

      // Bill To
      'customerName': customerName,

      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'cgst': cgst,
      'sgst': sgst,
      'igst': igst,
      'totalGst': totalGst,
      'grandTotal': grandTotal,
      'isCancelled': isCancelled,
    };
  }

  // Convert Firestore Map to Invoice
  factory Invoice.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    final itemList = (map['items'] as List<dynamic>? ?? []);

    return Invoice(
      id: id,
      invoiceNumber: map['invoiceNumber'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),

      // Defaults to empty string so older invoices
      // without customerName can still be opened.
      customerName: map['customerName'] as String? ?? '',

      items: itemList
          .map(
            (item) => BillItem.fromMap(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),

      subtotal: (map['subtotal'] as num).toDouble(),
      cgst: (map['cgst'] as num).toDouble(),
      sgst: (map['sgst'] as num).toDouble(),
      igst: (map['igst'] as num).toDouble(),
      totalGst: (map['totalGst'] as num).toDouble(),
      grandTotal: (map['grandTotal'] as num).toDouble(),

      isCancelled: map['isCancelled'] as bool? ?? false,
    );
  }

  Invoice copyWith({
    bool? isCancelled,
    String? customerName,
  }) {
    return Invoice(
      id: id,
      invoiceNumber: invoiceNumber,
      createdAt: createdAt,
      customerName: customerName ?? this.customerName,
      items: items,
      subtotal: subtotal,
      cgst: cgst,
      sgst: sgst,
      igst: igst,
      totalGst: totalGst,
      grandTotal: grandTotal,
      isCancelled: isCancelled ?? this.isCancelled,
    );
  }
}