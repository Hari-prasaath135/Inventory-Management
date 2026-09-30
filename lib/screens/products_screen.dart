import 'package:flutter/material.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';

class ProductsScreen extends StatefulWidget {
  final List<Product> products;
  final Function(Product) onAdd;
  final Function(Product) onUpdate;
  final Function(String) onDelete;

  const ProductsScreen({
    super.key,
    required this.products,
    required this.onAdd,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  void showProductForm({Product? product}) {
    final nameController = TextEditingController(text: product?.name ?? '');

    final priceController = TextEditingController(
      text: product?.price.toString() ?? '',
    );

    final hsnController = TextEditingController(
      text: product?.hsnCode ?? '4909',
    );

    final gstController = TextEditingController(
      text: product?.gstRate.toString() ?? '18',
    );

    final stockController = TextEditingController(
      text: product?.stockQuantity.toString() ?? '0',
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppTheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: const BorderSide(color: AppTheme.border),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 22, 24, 4),
          contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 4),
          actionsPadding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          title: Text(
            product == null ? 'Add Product' : 'Edit Product',
            style: const TextStyle(
              color: AppTheme.primary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 6),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Product Name',
                    prefixIcon: Icon(Icons.style_outlined),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: priceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Selling Price',
                    prefixIcon: Icon(Icons.currency_rupee),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: hsnController,
                  decoration: const InputDecoration(
                    labelText: 'HSN Code',
                    prefixIcon: Icon(Icons.qr_code_2),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: gstController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'GST Rate (%)',
                    prefixIcon: Icon(Icons.percent),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: stockController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Stock Quantity',
                    prefixIcon: Icon(Icons.inventory_2_outlined),
                  ),
                ),
              ],
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              style: TextButton.styleFrom(foregroundColor: AppTheme.primary),
              child: const Text('Cancel'),
            ),
            SizedBox(
              height: 44,
              child: ElevatedButton(
                child: Text(product == null ? 'Add' : 'Update'),
                onPressed: () {
                final name = nameController.text.trim();
                final price = double.tryParse(priceController.text);
                final gstRate = double.tryParse(gstController.text);
                final stock = int.tryParse(stockController.text);

                if (name.isEmpty ||
                    price == null ||
                    price <= 0 ||
                    gstRate == null ||
                    gstRate < 0 ||
                    gstRate > 100 ||
                    stock == null ||
                    stock < 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Enter valid product details'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: AppTheme.secondary,
                    ),
                  );
                  return;
                }

                final updatedProduct = Product(
                  id:
                      product?.id ??
                      DateTime.now().millisecondsSinceEpoch.toString(),

                  name: name,
                  price: price,
                  hsnCode: hsnController.text.trim(),
                  gstRate: gstRate,
                  stockQuantity: stock,
                );

                if (product == null) {
                  widget.onAdd(updatedProduct);
                } else {
                  widget.onUpdate(updatedProduct);
                }

                Navigator.pop(dialogContext);
              },
            ),
            ),
          ],
        );
      },
    );
  }

  void confirmDelete(Product product) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppTheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: const BorderSide(color: AppTheme.border),
          ),
          title: Text(
            'Delete Product?',
            style: const TextStyle(
            color: AppTheme.primary,
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
          ),
          content: Text('Remove ${product.name} from inventory?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              style: TextButton.styleFrom(foregroundColor: AppTheme.primary),
              child: const Text('Cancel'),
            ),
            SizedBox(
              height: 44,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.secondary,
                ),
                onPressed: () {
                widget.onDelete(product.id);
                Navigator.pop(dialogContext);
              },
            ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          'Products',
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        onPressed: () => showProductForm(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: widget.products.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 64,
                    color: AppTheme.primary.withValues(alpha: 0.35),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No products added yet.',
                    style: const TextStyle(
                      fontSize: 18,
                      color: AppTheme.secondary,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(14, 16, 14, 90),
              itemCount: widget.products.length,
              itemBuilder: (context, index) {
                final product = widget.products[index];
                final inStock = product.stockQuantity > 0;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
                      child: Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.primary,
                          ),
                          child: const Icon(
                            Icons.style_outlined,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppTheme.primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '₹${product.price.toStringAsFixed(2)} · '
                                'GST ${product.gstRate}% · HSN ${product.hsnCode}',
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _StockBadge(
                                text: inStock
                                    ? '${product.stockQuantity} in stock'
                                    : 'Out of stock',
                                available: inStock,
                              ),
                            ],
                          ),
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(
                            Icons.more_vert,
                            color: AppTheme.primary,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          onSelected: (value) {
                            if (value == 'edit') {
                              showProductForm(product: product);
                            } else if (value == 'delete') {
                              confirmDelete(product);
                            }
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.edit_outlined,
                                    size: 18,
                                    color: AppTheme.primary,
                                  ),
                                  SizedBox(width: 10),
                                  Text('Edit'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete_outline,
                                    size: 18,
                                    color: AppTheme.secondary,
                                  ),
                                  SizedBox(width: 10),
                                  Text('Delete'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                      ),
                    ),
                  ),
                );
              },
            ),
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
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}