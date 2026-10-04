import 'package:app/models/invoice.dart';
import 'package:flutter/material.dart';

import '../models/product.dart';
import '../models/bill_item.dart';
import '../services/gst_service.dart';

import '../widgets/bill_summary.dart';
import '../theme/app_theme.dart';

class BillingScreen extends StatefulWidget {
  final List<Product> products;
  final Function(Invoice) onInvoiceCreated;
  final Future<void> Function(List<BillItem>) onSaleComplete;

  const BillingScreen({
    super.key,
    required this.products,
    required this.onSaleComplete,
    required this.onInvoiceCreated,
  });

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  final quantityController = TextEditingController(text: '1');

  final List<BillItem> billItems = [];

  Product? selectedProduct;

  bool isInterstate = false;

  double get subtotal {
    return billItems.fold(0, (sum, item) => sum + item.subtotal);
  }

  // This version assumes all products use the same GST rate.
  // We'll support different GST rates per item in a later update.
  double get gstRate {
    if (billItems.isEmpty) return 18.0;

    return billItems.first.product.gstRate;
  }

  GstResult get gstResult {
    double totalCgst = 0;
    double totalSgst = 0;
    double totalIgst = 0;

    for (final item in billItems) {
      final result = GstService.calculate(
        subtotal: item.subtotal,
        gstRate: item.product.gstRate,
        isInterstate: isInterstate,
      );

      totalCgst += result.cgst;
      totalSgst += result.sgst;
      totalIgst += result.igst;
    }

    final totalGst = totalCgst + totalSgst + totalIgst;
    final grandTotal = subtotal + totalGst;

    return GstResult(
      cgst: totalCgst,
      sgst: totalSgst,
      igst: totalIgst,
      totalGst: totalGst,
      grandTotal: grandTotal,
    );
  }

  void addItem() {
    if (selectedProduct == null) {
      showMessage('Please select a product');
      return;
    }

    final quantity = int.tryParse(quantityController.text);

    if (quantity == null || quantity <= 0) {
      showMessage('Enter a valid quantity');
      return;
    }

    final product = selectedProduct!;

    // Find existing product in the current bill.
    final existingIndex = billItems.indexWhere(
      (item) => item.product.id == product.id,
    );

    // Calculate the quantity already added.
    int existingQuantity = 0;

    if (existingIndex != -1) {
      existingQuantity = billItems[existingIndex].quantity;
    }

    final totalQuantity = existingQuantity + quantity;

    // Check available stock.
    if (totalQuantity > product.stockQuantity) {
      showMessage('Only ${product.stockQuantity} units available');
      return;
    }

    setState(() {
      if (existingIndex != -1) {
        // Merge with the existing bill item.
        billItems[existingIndex].quantity = totalQuantity;
      } else {
        // Add a new bill item.
        billItems.add(BillItem(product: product, quantity: quantity));
      }

      selectedProduct = null;
      quantityController.clear();
    });
  }

  void removeItem(int index) {
    setState(() {
      billItems.removeAt(index);
    });
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.primary,
      ),
    );
  }

  Future<void> generateInvoice() async {
    if (billItems.isEmpty) {
      showMessage('Please add products first');
      return;
    }

    final now = DateTime.now();

    final invoice = Invoice(
      id: now.millisecondsSinceEpoch.toString(),
      invoiceNumber: 'SLK-${now.millisecondsSinceEpoch}',
      createdAt: now,
      items: List.from(billItems),
      subtotal: subtotal,
      cgst: gstResult.cgst,
      sgst: gstResult.sgst,
      igst: gstResult.igst,
      totalGst: gstResult.totalGst,
      grandTotal: gstResult.grandTotal,
    );

    try {
      await widget.onSaleComplete(billItems);
      await widget.onInvoiceCreated(invoice);

      if (!mounted) return;

      setState(() {
        billItems.clear();
        selectedProduct = null;
        quantityController.clear();
      });

      showMessage('Invoice saved successfully');
    } catch (error) {
      showMessage('Failed to complete sale: $error');
    }
  }

  @override
  void dispose() {
    quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          'Billing',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.primary,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                'Sree Lakshmi Cards & Bags',
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
            // ---------------------------------------------- Add product
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _SectionHeader(
                      icon: Icons.add_shopping_cart,
                      title: 'Add Product to Bill',
                    ),
                  const SizedBox(height: 16),
                    DropdownButtonFormField<Product>(
                      initialValue: selectedProduct,
                      decoration: const InputDecoration(
                        labelText: 'Choose Wedding Card',
                        prefixIcon: Icon(Icons.style_outlined),
                      ),
                    items: widget.products.map((product) {
                      return DropdownMenuItem<Product>(
                        value: product,
                        child: Text('${product.name} - ₹${product.price}'),
                      );
                    }).toList(),
                    onChanged: (product) {
                      setState(() {
                        selectedProduct = product;
                      });
                    },
                  ),
                    if (selectedProduct != null) ...[
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: _StockBadge(
                          text:
                              '${selectedProduct!.stockQuantity} in stock',
                          available: selectedProduct!.stockQuantity > 0,
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    TextField(
                      controller: quantityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                        prefixIcon: Icon(Icons.numbers),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: addItem,
                        icon: const Icon(Icons.add),
                        label: const Text('Add to Bill'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            // ---------------------------------------------- Sale type
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _SectionHeader(
                      icon: Icons.swap_horiz,
                      title: 'Sale Type',
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      activeColor: AppTheme.primary,
                    title: const Text(
                      'Inter-state Sale',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(isInterstate ? 'IGST' : 'CGST + SGST'),
                    value: isInterstate,
                    onChanged: (value) {
                      setState(() {
                        isInterstate = value;
                      });
                    },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            // ---------------------------------------------- Bill items
            Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const _SectionHeader(
                          icon: Icons.list_alt,
                          title: 'Bill Items',
                        ),
                        const Spacer(),
                        if (billItems.isNotEmpty)
                          TextButton.icon(
                            onPressed: () => setState(billItems.clear),
                            icon: const Icon(
                              Icons.delete_sweep_outlined,
                              size: 18,
                              color: AppTheme.primary,
                            ),
                            label: const Text(
                              'Clear All',
                              style: TextStyle(color: AppTheme.primary),
                            ),
                          ),
                      ],
                    ),
                  const SizedBox(height: 8),
                  if (billItems.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          'No items added yet.',
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                    )
                  else
                    ...billItems.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;

                      return _BillItemTile(
                        index: index + 1,
                        name: item.product.name,
                        quantity: item.quantity,
                        price: item.product.price,
                        subtotal: item.subtotal,
                        onDelete: () => removeItem(index),
                      );
                    }),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            ),
            
            const SizedBox(height: 18),
            
            // ---------------------------------------------- Summary
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: BillSummary(
                  subtotal: subtotal,
                  gstResult: gstResult,
                ),
              ),
            ),

            const SizedBox(height: 18),

            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: generateInvoice,
                icon: const Icon(Icons.receipt_long),
                label: const Text('Generate Invoice'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
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
        Icon(icon, size: 21, color: AppTheme.primary),
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

class _StockBadge extends StatelessWidget {
  const _StockBadge({
    required this.text,
    required this.available,
  });

  final String text;
  final bool available;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.background,
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: available ? AppTheme.primary : AppTheme.secondary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _BillItemTile extends StatelessWidget {
  const _BillItemTile({
    required this.index,
    required this.name,
    required this.quantity,
    required this.price,
    required this.subtotal,
    required this.onDelete,
  });

  final int index;
  final String name;
  final int quantity;
  final double price;
  final double subtotal;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppTheme.background,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$index',
              style: const TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
                ),
                Text(
                  '$quantity × ₹${price.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 12.5, color: Colors.black54),
                ),
              ],
            ),
          ),
          Text(
            '₹${subtotal.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.primary,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppTheme.primary),
            onPressed: onDelete,
            splashRadius: 20,
          ),
        ],
      ),
    );
  }
}