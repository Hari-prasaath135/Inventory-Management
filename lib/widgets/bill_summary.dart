import 'package:flutter/material.dart';
import '../services/gst_service.dart';

class BillSummary extends StatelessWidget {
  final double subtotal;
  final GstResult gstResult;

  const BillSummary({
    super.key,
    required this.subtotal,
    required this.gstResult,
  });

  Widget billRow(String label, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label), Text('₹${amount.toStringAsFixed(2)}')],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            billRow('Subtotal', subtotal),

            if (gstResult.cgst > 0) billRow('CGST', gstResult.cgst),

            if (gstResult.sgst > 0) billRow('SGST', gstResult.sgst),

            if (gstResult.igst > 0) billRow('IGST', gstResult.igst),

            const Divider(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Grand Total',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  '₹${gstResult.grandTotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
