import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/invoice_service.dart';
import 'firebase_options.dart';
import 'models/bill_item.dart';
import 'models/invoice.dart';
import 'models/product.dart';
import 'repositories/invoice_repository.dart';
import 'screens/home_page.dart';
import 'services/invoice_pdf_service.dart';

import 'screens/billing_screen.dart';
import 'screens/google_login_screen.dart';
import 'screens/invoice_history_screen.dart';
import 'screens/products_screen.dart';

import 'services/product_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Log out the previous account whenever the app starts
  await FirebaseAuth.instance.signOut();

  runApp(const AuthGate());
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        if (snapshot.hasData) {
          return const WeddingCardApp();
        }

        return const MaterialApp(
          home: GoogleLoginScreen(),
        );
      },
    );
  }
}

enum AppSection { home, billing, products, invoices }

class AppShell extends StatelessWidget {
  final AppSection section;
  final ValueChanged<AppSection> onSectionSelected;
  final Widget body;

  const AppShell({
    super.key,
    required this.section,
    required this.onSectionSelected,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final isHome = section == AppSection.home;

    const sections = [
      AppSection.billing,
      AppSection.products,
      AppSection.invoices,
    ];

    return Scaffold(
      body: body,
      bottomNavigationBar: isHome
          ? null
          : NavigationBar(
              selectedIndex: sections.indexOf(section),
              onDestinationSelected: (i) => onSectionSelected(sections[i]),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.receipt_long),
                  label: 'Billing',
                ),
                NavigationDestination(
                  icon: Icon(Icons.inventory_2),
                  label: 'Products',
                ),
                NavigationDestination(
                  icon: Icon(Icons.history),
                  label: 'Invoices',
                ),
              ],
            ),
    );
  }
}

class WeddingCardApp extends StatefulWidget {
  const WeddingCardApp({super.key});

  @override
  State<WeddingCardApp> createState() => _WeddingCardAppState();
}

class _WeddingCardAppState extends State<WeddingCardApp> {
  final List<Product> products = [];
  final List<Invoice> invoices = [];

  AppSection currentSection = AppSection.home;

  final InvoiceService invoiceService = InvoiceService();

  bool isLoadingInvoices = true;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  final ProductService productService = ProductService();
  final InvoiceRepository invoiceRepository = InvoiceRepository();

  bool isLoadingProducts = true;

  @override
  void initState() {
    super.initState();

    loadProducts();
    loadInvoices();
  }

  Future<void> loadInvoices() async {
    try {
      final loadedInvoices = await invoiceService.getInvoices();

      if (!mounted) return;

      setState(() {
        invoices.clear();
        invoices.addAll(loadedInvoices);

        for (final invoice in loadedInvoices) {
          invoiceRepository.addInvoice(invoice);
        }

        isLoadingInvoices = false;
      });

      debugPrint('✅ Invoices loaded from Firestore');
    } catch (error) {
      debugPrint('❌ Failed to load invoices: $error');

      if (!mounted) return;

      setState(() {
        isLoadingInvoices = false;
      });
    }
  }

  // Load products from Firestore
  Future<void> loadProducts() async {
    try {
      final loadedProducts = await productService.getProducts();

      if (!mounted) return;

      setState(() {
        products.clear();
        products.addAll(loadedProducts);
        isLoadingProducts = false;
      });

      debugPrint('✅ Products loaded from Firestore');
    } catch (error) {
      debugPrint('❌ Failed to load products: $error');

      if (!mounted) return;

      setState(() {
        isLoadingProducts = false;
      });
    }
  }

  // Add product to Firestore
  void addProduct(Product product) async {
    try {
      await productService.addProduct(product);

      if (!mounted) return;

      setState(() {
        products.add(product);
      });

      debugPrint('✅ Product added to Firestore');

      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text('Product added successfully'),
        ),
      );
    } catch (error) {
      debugPrint('❌ Failed to add product: $error');

      if (!mounted) return;

      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text('Product added successfully'),
        ),
      );
    }
  }

  // Update product in Firestore
  void updateProduct(Product product) async {
    try {
      await productService.updateProduct(product);

      if (!mounted) return;

      setState(() {
        final index = products.indexWhere(
          (item) => item.id == product.id,
        );

        if (index != -1) {
          products[index] = product;
        }
      });

      debugPrint('✅ Product updated in Firestore');

      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text('Product added successfully'),
        ),
      );
    } catch (error) {
      debugPrint('❌ Failed to update product: $error');

      if (!mounted) return;

      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text('Product added successfully'),
        ),
      );
    }
  }

  // Delete product from Firestore
  void deleteProduct(String id) async {
    try {
      await productService.deleteProduct(id);

      if (!mounted) return;

      setState(() {
        products.removeWhere(
          (item) => item.id == id,
        );
      });

      debugPrint('✅ Product deleted from Firestore');

      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text('Product added successfully'),
        ),
      );
    } catch (error) {
      debugPrint('❌ Failed to delete product: $error');

      if (!mounted) return;

      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text('Product added successfully'),
        ),
      );
    }
  }

  // Save invoice in local memory
Future<void> saveInvoice(Invoice invoice) async {
  try {
    // STEP 1: Save to Firestore
    await invoiceService.addInvoice(invoice);

    // STEP 2: Update local invoice list
    setState(() {
      invoices.add(invoice);
    });

    // STEP 3: Generate / open printable invoice
    await InvoicePdfService.generateInvoicePdf(invoice);

    // STEP 4: Success message
    scaffoldMessengerKey.currentState?.showSnackBar(
      const SnackBar(
        content: Text('Invoice saved successfully'),
      ),
    );
  } catch (e) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text('Failed to save invoice: $e'),
      ),
    );
  }
}

  // Cancel invoice and restore stock
  Future<void> cancelInvoice(Invoice invoice) async {
    if (invoice.isCancelled) {
      return;
    }

    try {
      await invoiceService.cancelInvoiceAndRestoreStock(invoice);

      if (!mounted) return;

      final invoiceIndex = invoices.indexWhere(
        (item) => item.id == invoice.id,
      );

      if (invoiceIndex == -1) {
        return;
      }

      final cancelledInvoice = invoices[invoiceIndex].copyWith(
        isCancelled: true,
      );

      setState(() {
        invoices[invoiceIndex] = cancelledInvoice;

        invoiceRepository.updateInvoice(cancelledInvoice);

        // Update local stock after Firestore succeeds
        for (final item in invoice.items) {
          final productIndex = products.indexWhere(
            (product) => product.id == item.product.id,
          );

          if (productIndex != -1) {
            final product = products[productIndex];

            products[productIndex] = product.copyWith(
              stockQuantity: product.stockQuantity + item.quantity,
            );
          }
        }
      });

      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text('Invoice cancelled and stock restored'),
        ),
      );
    } catch (error) {
      debugPrint('❌ Failed to cancel invoice: $error');

      if (!mounted) return;

      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text('Cancellation failed: $error'),
        ),
      );
    }
  }

  // Reduce stock after completing a sale
  Future<void> reduceStock(List<BillItem> billItems) async {
    try {
      for (final item in billItems) {
        await productService.reduceStock(
          productId: item.product.id,
          quantity: item.quantity,
        );
      }

      if (!mounted) return;

      // Update local stock after Firestore succeeds
      setState(() {
        for (final item in billItems) {
          final index = products.indexWhere(
            (product) => product.id == item.product.id,
          );

          if (index != -1) {
            final product = products[index];

            products[index] = product.copyWith(
              stockQuantity: product.stockQuantity - item.quantity,
            );
          }
        }
      });

      debugPrint('✅ Stock reduced in Firestore');
    } catch (error) {
      debugPrint('❌ Failed to reduce stock: $error');
      rethrow;
    }
  }

  Widget _bodyForSection(AppSection section) {
    switch (section) {
      case AppSection.home:
        return HomeContent(
          user: FirebaseAuth.instance.currentUser,
          onBilling: () => setState(() => currentSection = AppSection.billing),
          onProducts: () => setState(() => currentSection = AppSection.products),
          onInvoices: () => setState(() => currentSection = AppSection.invoices),
          onLogout: () => FirebaseAuth.instance.signOut(),
        );
      case AppSection.billing:
        return BillingScreen(
          products: products,
          onSaleComplete: reduceStock,
          onInvoiceCreated: saveInvoice,
        );
      case AppSection.products:
        return ProductsScreen(
          products: products,
          onAdd: addProduct,
          onUpdate: updateProduct,
          onDelete: deleteProduct,
        );
      case AppSection.invoices:
        return InvoiceHistoryScreen(
          invoices: invoices,
          onCancelInvoice: cancelInvoice,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: scaffoldMessengerKey,
      title: 'Wedding Card Billing',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
        useMaterial3: true,
      ),
      home: isLoadingProducts || isLoadingInvoices
          ? const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : AppShell(
              section: currentSection,
              onSectionSelected: (s) => setState(() => currentSection = s),
              body: _bodyForSection(currentSection),
            ),
    );
  }
}