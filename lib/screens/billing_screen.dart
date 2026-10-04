import 'package:flutter/material.dart';

import '../models/invoice.dart';
import '../models/product.dart';
import '../models/bill_item.dart';
import '../services/gst_service.dart';
import '../widgets/bill_summary.dart';
import '../theme/app_theme.dart';

class BillingScreen extends StatefulWidget {
  final Function(Invoice) onInvoiceCreated;

 const BillingScreen({
  super.key,
  required this.onInvoiceCreated,
});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  final quantityController = TextEditingController(text: '1');
  final priceController = TextEditingController();

  final customerNameController = TextEditingController();

  final List<BillItem> billItems = [];

  Product? selectedProduct;
  double selectedGstRate = 18.0;

  bool isInterstate = false;
  bool isGeneratingInvoice = false;

  // Fixed Products & Services available directly from the billing screen.
  // Prices are entered by the user for each bill item.
  final List<String> productServiceNames = const [
    'Wedding Cards',
    'Wedding Bags',
    'Screen Printing',
    'Off-set Printing',
  ];

  double get subtotal {
    return billItems.fold(
      0,
      (sum, item) => sum + item.subtotal,
    );
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

  bool get canGenerateInvoice {
    return billItems.isNotEmpty &&
        customerNameController.text.trim().isNotEmpty &&
        !isGeneratingInvoice;
  }

  Product _createBillingProduct({
    required String name,
    required double price,
    required double gstRate,
  }) {
    final id = name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');

    return Product(
      id: id,
      name: name,
      price: price,
      hsnCode: '',
      gstRate: gstRate,
      stockQuantity: 999999,
    );
  }

 void selectProduct(String? name) {
  if (name == null) {
    setState(() {
      selectedProduct = null;
      priceController.clear();
    });
    return;
  }

  setState(() {
    selectedProduct = _createBillingProduct(
      name: name,
      price: 0,
      gstRate: selectedGstRate,
    );

    priceController.clear();
  });
}

  void addItem() {
    if (selectedProduct == null) {
      showMessage('Please select a product or service');
      return;
    }

    final quantity = int.tryParse(quantityController.text.trim());

    if (quantity == null || quantity <= 0) {
      showMessage('Enter a valid quantity');
      return;
    }

    final price = double.tryParse(priceController.text.trim());

    if (price == null || price <= 0) {
      showMessage('Enter a valid unit price');
      return;
    }

    final product = _createBillingProduct(
      name: selectedProduct!.name,
      price: price,
      gstRate: selectedGstRate,
    );

    final item = BillItem(
      product: product,
      quantity: quantity,
    );

    setState(() {
      billItems.add(item);

      selectedProduct = null;
      priceController.clear();
      quantityController.text = '1';
      selectedGstRate = 18.0;
    });
  }

  void removeItem(int index) {
    setState(() {
      billItems.removeAt(index);
    });
  }

  void clearBill() {
    setState(() {
      billItems.clear();
      selectedProduct = null;
      priceController.clear();
      quantityController.text = '1';
      selectedGstRate = 18.0;
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
      showMessage('Please add products or services to the bill first');
      return;
    }

    final customerName = customerNameController.text.trim();

    if (customerName.isEmpty) {
      showMessage('Please enter the Bill To name');
      return;
    }

    setState(() {
      isGeneratingInvoice = true;
    });

    final now = DateTime.now();

  final invoice = Invoice(
  id: now.millisecondsSinceEpoch.toString(),
  invoiceNumber: 'SLK-${now.millisecondsSinceEpoch}',
  createdAt: now,
  customerName: customerName,
  items: List.from(billItems),
  subtotal: subtotal,
  cgst: gstResult.cgst,
  sgst: gstResult.sgst,
  igst: gstResult.igst,
  totalGst: gstResult.totalGst,
  grandTotal: gstResult.grandTotal,
);

    try {
    
      await widget.onInvoiceCreated(invoice);

      if (!mounted) return;

      setState(() {
        billItems.clear();
        selectedProduct = null;
        priceController.clear();
        quantityController.text = '1';
        selectedGstRate = 18.0;
        customerNameController.clear();
      });

      showMessage('Invoice generated successfully');
    } catch (error) {
      if (!mounted) return;

      showMessage('Failed to generate invoice: $error');
    } finally {
      if (mounted) {
        setState(() {
          isGeneratingInvoice = false;
        });
      }
    }
  }

  @override
  void dispose() {
    quantityController.dispose();
    priceController.dispose();
    customerNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          'Products & Billing',
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
            // ---------------------------------------------------------
            // ADD PRODUCT / SERVICE
            // ---------------------------------------------------------
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _SectionHeader(
                      icon: Icons.add_shopping_cart,
                      title: 'Add Product to Bill',
                    ),

                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      initialValue: selectedProduct?.name,
                      decoration: const InputDecoration(
                        labelText: 'Choose Product or Service',
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                      items: productServiceNames.map((name) {
                        return DropdownMenuItem<String>(
                          value: name,
                          child: Text(name),
                        );
                      }).toList(),
                      onChanged: selectProduct,
                    ),

                    const SizedBox(height: 14),

                    TextField(
                      controller: quantityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                        prefixIcon: Icon(Icons.numbers),
                      ),
                    ),

                    const SizedBox(height: 14),

                    TextField(
                      controller: priceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Unit Price (₹)',
                        prefixIcon: Icon(Icons.currency_rupee),
                      ),
                    ),

                    const SizedBox(height: 14),

                    DropdownButtonFormField<double>(
                      initialValue: selectedGstRate,
                      decoration: const InputDecoration(
                        labelText: 'GST Rate',
                        prefixIcon: Icon(Icons.percent),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 5,
                          child: Text('5%'),
                        ),
                        DropdownMenuItem(
                          value: 6,
                          child: Text('6%'),
                        ),
                        DropdownMenuItem(
                          value: 7,
                          child: Text('7%'),
                        ),
                        DropdownMenuItem(
                          value: 8,
                          child: Text('8%'),
                        ),
                        DropdownMenuItem(
                          value: 9,
                          child: Text('9%'),
                        ),
                        DropdownMenuItem(
                          value: 10,
                          child: Text('10%'),
                        ),
                        DropdownMenuItem(
                          value: 11,
                          child: Text('11%'),
                        ),
                        DropdownMenuItem(
                          value: 12,
                          child: Text('12%'),
                        ),
                        DropdownMenuItem(
                          value: 13,
                          child: Text('13%'),
                        ),
                        DropdownMenuItem(
                          value: 14,
                          child: Text('14%'),
                        ),
                        DropdownMenuItem(
                          value: 15,
                          child: Text('15%'),
                        ),
                        DropdownMenuItem(
                          value: 16,
                          child: Text('16%'),
                        ),
                        DropdownMenuItem(
                          value: 17,
                          child: Text('17%'),
                        ),
                        DropdownMenuItem(
                          value: 18,
                          child: Text('18%'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;

                        setState(() {
                          selectedGstRate = value;
                        });
                      },
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

            // ---------------------------------------------------------
            // SALE TYPE
            // ---------------------------------------------------------
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _SectionHeader(
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
                      subtitle: Text(
                        isInterstate ? 'IGST' : 'CGST + SGST',
                      ),
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

            // ---------------------------------------------------------
            // BILL ITEMS
            // ---------------------------------------------------------
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
                            onPressed: clearBill,
                            icon: const Icon(
                              Icons.delete_sweep_outlined,
                              size: 18,
                              color: AppTheme.primary,
                            ),
                            label: const Text(
                              'Clear All',
                              style: TextStyle(
                                color: AppTheme.primary,
                              ),
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
                            style: TextStyle(
                              color: Colors.black54,
                            ),
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
                          gstRate: item.product.gstRate,
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

            // ---------------------------------------------------------
            // BILL TO NAME
            // Appears only after at least one item is added.
            // ---------------------------------------------------------
            if (billItems.isNotEmpty) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _SectionHeader(
                        icon: Icons.person_outline,
                        title: 'Bill To',
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: customerNameController,
                        textCapitalization: TextCapitalization.words,
                        onChanged: (_) {
                          setState(() {});
                        },
                        decoration: const InputDecoration(
                          labelText: 'Bill To Name',
                          hintText: 'Enter customer name',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),
            ],

            // ---------------------------------------------------------
            // SUMMARY
            // ---------------------------------------------------------
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

            // ---------------------------------------------------------
            // GENERATE INVOICE
            // ---------------------------------------------------------
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: canGenerateInvoice
                    ? generateInvoice
                    : null,
                icon: isGeneratingInvoice
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.receipt_long),
                label: Text(
                  isGeneratingInvoice
                      ? 'Generating Invoice...'
                      : 'Generate Invoice',
                ),
              ),
            ),

            if (billItems.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Center(
                  child: Text(
                    'Add at least one item to the bill to enable invoice generation.',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else if (customerNameController.text.trim().isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Center(
                  child: Text(
                    'Enter the Bill To name to generate the invoice.',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
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

class _BillItemTile extends StatelessWidget {
  const _BillItemTile({
    required this.index,
    required this.name,
    required this.quantity,
    required this.price,
    required this.gstRate,
    required this.subtotal,
    required this.onDelete,
  });

  final int index;
  final String name;
  final int quantity;
  final double price;
  final double gstRate;
  final double subtotal;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: AppTheme.border,
        ),
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
                const SizedBox(height: 3),
                Text(
                  '$quantity × ₹${price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'GST ${gstRate.toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
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
            icon: const Icon(
              Icons.delete_outline,
              color: AppTheme.primary,
            ),
            onPressed: onDelete,
            splashRadius: 20,
          ),
        ],
      ),
    );
  }
}
