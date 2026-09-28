import 'package:flutter/material.dart';

import '../models/invoice.dart';
import 'invoice_detail_screen.dart';

class InvoiceHistoryScreen extends StatelessWidget {
  final List<Invoice> invoices;
  final Future<void> Function(Invoice) onCancelInvoice;

  const InvoiceHistoryScreen({
    super.key,
    required this.invoices,
    required this.onCancelInvoice,
  });

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Invoice History')),
      body: invoices.isEmpty
          ? const Center(
              child: Text(
                'No invoices generated yet',
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: invoices.length,
              itemBuilder: (context, index) {
                final invoice = invoices[index];

                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.receipt_long),
                    ),

                    title: Text(
                      invoice.invoiceNumber,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),

                    subtitle: Text(
                      '${formatDate(invoice.createdAt)}\n'
                      '${invoice.items.length} product line(s)',
                    ),

                    isThreeLine: true,

                    trailing: Text(
                      '₹${invoice.grandTotal.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),

                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InvoiceDetailScreen(
                            invoice: invoice,
                            onCancel: () {
                              onCancelInvoice(invoice);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
