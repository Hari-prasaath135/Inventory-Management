import 'package:flutter/material.dart';

import '../models/invoice.dart';
import '../services/invoice_pdf_service.dart';
import '../theme/app_theme.dart';

class InvoiceDetailScreen extends StatelessWidget {
  final Invoice invoice;
  final VoidCallback onCancel;

  const InvoiceDetailScreen({
    super.key,
    required this.invoice,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final date = invoice.createdAt;
    final dateText =
        '${date.day.toString().padLeft(2, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.year}';

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          'Invoice Details',
          style: TextStyle(
            color: AppTheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                'Sree Lakshmi Cards',
                style: TextStyle(
                  color: AppTheme.secondary,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Invoice summary
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'TAX INVOICE',
                                style: TextStyle(
                                  color: AppTheme.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.4,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                invoice.invoiceNumber,
                                style: const TextStyle(
                                  color: AppTheme.primary,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today_outlined,
                                    size: 14,
                                    color: AppTheme.secondary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    dateText,
                                    style: const TextStyle(
                                      color: AppTheme.secondary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        _StatusBadge(
                          text: invoice.isCancelled ? 'CANCELLED' : 'PAID',
                          color: invoice.isCancelled
                              ? AppTheme.secondary
                              : AppTheme.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            // Products
            Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _SectionHeader(
                      icon: Icons.style_outlined,
                      title: 'Products',
                    ),
                    const SizedBox(height: 10),
                    ...invoice.items.map(
                      (item) => Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          border: Border.all(color: AppTheme.border),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 38,
                              decoration: BoxDecoration(
                                color: AppTheme.primary,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.name,
                                    style: const TextStyle(
                                      color: AppTheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    'Qty ${item.quantity} × '
                                    '₹${item.product.price.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: AppTheme.secondary,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '₹${item.subtotal.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            // Bill summary
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _SectionHeader(
                      icon: Icons.calculate_outlined,
                      title: 'Bill Summary',
                    ),
                    const SizedBox(height: 6),
                    const Divider(color: AppTheme.border),
                    _AmountRow(
                      label: 'Subtotal',
                      amount: invoice.subtotal,
                    ),
                    if (invoice.cgst > 0)
                      _AmountRow(
                        label: 'CGST',
                        amount: invoice.cgst,
                      ),
                    if (invoice.sgst > 0)
                      _AmountRow(
                        label: 'SGST',
                        amount: invoice.sgst,
                      ),
                    if (invoice.igst > 0)
                      _AmountRow(
                        label: 'IGST',
                        amount: invoice.igst,
                      ),
                    _AmountRow(
                      label: 'Total Tax Amount',
                      amount: invoice.totalGst,
                      highlight: true,
                    ),
                    const Divider(color: AppTheme.border),
                    _AmountRow(
                      label: 'Grand Total',
                      amount: invoice.grandTotal,
                      emphasize: true,
                      highlight: true,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 26),

            // Generate PDF
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () async {
                  try {
                    await InvoicePdfService.generateInvoicePdf(invoice);
                  } catch (e) {
                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to generate PDF: $e'),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.picture_as_pdf_outlined),
                label: const Text('Generate PDF'),
              ),
            ),

            const SizedBox(height: 12),

            // Cancel invoice
            if (!invoice.isCancelled)
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () => _showCancelDialog(context),
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Cancel Invoice'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.secondary,
                    foregroundColor: Colors.white,
                  ),
                ),
              )
            else
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    Icon(
                      Icons.block_outlined,
                      color: AppTheme.secondary,
                      size: 30,
                    ),
                    SizedBox(height: 6),
                    Text(
                      'This invoice has been cancelled',
                      style: TextStyle(
                        color: AppTheme.secondary,
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppTheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: const BorderSide(color: AppTheme.border),
          ),
          title: const Text(
            'Cancel Invoice?',
            style: TextStyle(
              color: AppTheme.primary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'This will restore the sold products to stock.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primary,
              ),
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                onCancel();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Yes, Cancel'),
            ),
          ],
        );
      },
    );
  }
}


class _AmountRow extends StatelessWidget {
  const _AmountRow({
    required this.label,
    required this.amount,
    this.highlight = false,
    this.emphasize = false,
  });

  final String label;
  final double amount;
  final bool highlight;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: emphasize
                    ? AppTheme.primary
                    : AppTheme.secondary,
                fontSize: emphasize ? 15 : 14,
                fontWeight: emphasize || highlight
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            ),
          ),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: AppTheme.primary,
              fontSize: emphasize ? 16 : 14,
              fontWeight: emphasize || highlight
                  ? FontWeight.bold
                  : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
  });

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 21,
          color: AppTheme.primary,
        ),
        const SizedBox(width: 9),
        Text(
          title,
          style: const TextStyle(
            color: AppTheme.primary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.text,
    required this.color,
  });

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppTheme.background,
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
