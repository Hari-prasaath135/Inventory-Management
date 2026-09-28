import 'package:flutter/material.dart';
import '../services/invoice_pdf_service.dart';
import '../models/invoice.dart';
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
      backgroundColor: AppTheme.cream,
      appBar: const ThemedAppBar(
        title: 'Invoice Details',
        subtitle: 'Sree Lakshmi Cards',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ------------------------------------------------- summary
            ThemedCard(
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
                                color: AppTheme.burgundy,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                letterSpacing: 1.4,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              invoice.invoiceNumber,
                              style: AppTheme.serifStyle(size: 26),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  size: 14,
                                  color: Colors.black54,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  dateText,
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (invoice.isCancelled)
                        const StatusBadge(
                          text: 'CANCELLED',
                          color: AppTheme.danger,
                        )
                      else
                        const StatusBadge(
                          text: 'PAID',
                          color: AppTheme.success,
                        ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // ------------------------------------------------- products
            ThemedCard(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SectionHeader(
                    icon: Icons.style_outlined,
                    title: 'Products',
                  ),
                  const SizedBox(height: 8),
                  ...invoice.items.map((item) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFF1E3E0)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 34,
                            decoration: BoxDecoration(
                              color: AppTheme.burgundy,
                              borderRadius: BorderRadius.circular(4),
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
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.ink,
                                  ),
                                ),
                                Text(
                                  'Qty ${item.quantity} × '
                                  '₹${item.product.price.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '₹${item.subtotal.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.darkBurgundy,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // ------------------------------------------------- totals
            ThemedCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SectionHeader(
                    icon: Icons.calculate_outlined,
                    title: 'Bill Summary',
                  ),
                  const SizedBox(height: 6),
                  const Divider(color: AppTheme.border),
                  AmountRow(label: 'Subtotal', amount: invoice.subtotal),
                  if (invoice.cgst > 0)
                    AmountRow(label: 'CGST', amount: invoice.cgst),
                  if (invoice.sgst > 0)
                    AmountRow(label: 'SGST', amount: invoice.sgst),
                  if (invoice.igst > 0)
                    AmountRow(label: 'IGST', amount: invoice.igst),
                  AmountRow(
                    label: 'Total Tax Amount',
                    amount: invoice.totalGst,
                    highlight: true,
                  ),
                  const Divider(color: AppTheme.border),
                  AmountRow(
                    label: 'Grand Total',
                    amount: invoice.grandTotal,
                    emphasize: true,
                    highlight: true,
                  ),
                ],
              ),
            ),

          const SizedBox(height: 26),

// ------------------------------------------------- generate PDF

PillButton(
  label: 'Generate PDF',
  icon: Icons.picture_as_pdf_outlined,
  color: AppTheme.burgundy,
  onPressed: () async {
    try {
      await InvoicePdfService.generateInvoicePdf(invoice);
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to generate PDF: $e',
          ),
        ),
      );
    }
  },
),

const SizedBox(height: 12),

// ------------------------------------------------- cancel

if (!invoice.isCancelled)
              PillButton(
                label: 'Cancel Invoice',
                icon: Icons.cancel_outlined,
                color: AppTheme.danger,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (dialogContext) {
                      return AlertDialog(
                        backgroundColor: AppTheme.panel,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        title: Text(
                          'Cancel Invoice?',
                          style: AppTheme.serifStyle(size: 22),
                        ),
                        content: const Text(
                          'This will restore the sold products to stock.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(dialogContext);
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: AppTheme.ink,
                            ),
                            child: const Text('No'),
                          ),
                          PillButton(
                            expand: false,
                            label: 'Yes, Cancel',
                            color: AppTheme.danger,
                            onPressed: () {
                              Navigator.pop(dialogContext);
                              onCancel();
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              )
            else
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.block,
                      color: AppTheme.danger.withValues(alpha: 0.7),
                      size: 30,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'This invoice has been cancelled',
                      style: AppTheme.serifStyle(
                        size: 16,
                        weight: FontWeight.normal,
                        color: AppTheme.danger,
                        style: FontStyle.italic,
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
}