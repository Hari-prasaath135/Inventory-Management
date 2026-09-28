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
          backgroundColor: AppTheme.panel,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 22, 24, 4),
          contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 4),
          actionsPadding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          title: Text(
            product == null ? 'Add Product' : 'Edit Product',
            style: AppTheme.serifStyle(size: 24),
          ),

          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 6),
                TextField(
                  controller: nameController,
                  decoration: AppTheme.input(
                    'Product Name',
                    icon: Icons.style_outlined,
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: priceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: AppTheme.input(
                    'Selling Price',
                    icon: Icons.currency_rupee,
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: hsnController,
                  decoration: AppTheme.input(
                    'HSN Code',
                    icon: Icons.qr_code_2,
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: gstController,
                  keyboardType: TextInputType.number,
                  decoration: AppTheme.input(
                    'GST Rate (%)',
                    icon: Icons.percent,
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: stockController,
                  keyboardType: TextInputType.number,
                  decoration: AppTheme.input(
                    'Stock Quantity',
                    icon: Icons.inventory_2_outlined,
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
              style: TextButton.styleFrom(foregroundColor: AppTheme.ink),
              child: const Text('Cancel'),
            ),
            PillButton(
              expand: false,
              label: product == null ? 'Add' : 'Update',
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
                      backgroundColor: AppTheme.danger,
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
          backgroundColor: AppTheme.panel,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            'Delete Product?',
            style: AppTheme.serifStyle(size: 22),
          ),
          content: Text('Remove ${product.name} from inventory?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              style: TextButton.styleFrom(foregroundColor: AppTheme.ink),
              child: const Text('Cancel'),
            ),
            PillButton(
              expand: false,
              label: 'Delete',
              icon: Icons.delete_outline,
              color: AppTheme.danger,
              onPressed: () {
                widget.onDelete(product.id);
                Navigator.pop(dialogContext);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cream,
      appBar: const ThemedAppBar(
        title: 'Products',
        subtitle: 'Sree Lakshmi Cards',
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.burgundy,
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
                    color: AppTheme.burgundy.withValues(alpha: 0.35),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No products added yet.',
                    style: AppTheme.serifStyle(
                      size: 18,
                      weight: FontWeight.normal,
                      color: Colors.black54,
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
                  child: ThemedCard(
                    padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
                    child: Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              center: Alignment(-0.3, -0.4),
                              colors: [Color(0xFFB02A3E), Color(0xFF7A1120)],
                            ),
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
                                  color: AppTheme.ink,
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
                              StatusBadge(
                                text: inStock
                                    ? '${product.stockQuantity} in stock'
                                    : 'Out of stock',
                                color: inStock
                                    ? AppTheme.success
                                    : AppTheme.danger,
                              ),
                            ],
                          ),
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(
                            Icons.more_vert,
                            color: AppTheme.burgundy,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
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
                                    color: AppTheme.burgundy,
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
                                    color: AppTheme.danger,
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
                );
              },
            ),
    );
  }
}