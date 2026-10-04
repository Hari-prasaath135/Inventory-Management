import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

import 'models/invoice.dart';

import 'repositories/invoice_repository.dart';

import 'screens/app_shell.dart';
import 'screens/home_page.dart';
import 'screens/billing_screen.dart';
import 'screens/google_login_screen.dart';
import 'screens/invoice_history_screen.dart';

import 'services/invoice_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (kIsWeb) {
    await FirebaseAuth.instance.setPersistence(
      Persistence.LOCAL,
    );
  }

  runApp(const AuthGate());
}

// ============================================================
// AUTH GATE
// ============================================================

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
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
          debugShowCheckedModeBanner: false,
          home: GoogleLoginScreen(),
        );
      },
    );
  }
}

// ============================================================
// MAIN APPLICATION
// ============================================================

class WeddingCardApp extends StatefulWidget {
  const WeddingCardApp({super.key});

  @override
  State<WeddingCardApp> createState() =>
      _WeddingCardAppState();
}

// ============================================================
// APPLICATION STATE
// ============================================================

class _WeddingCardAppState extends State<WeddingCardApp> {
  final List<Invoice> invoices = [];

  AppSection currentSection = AppSection.home;

  final InvoiceService invoiceService =
      InvoiceService();

  final InvoiceRepository invoiceRepository =
      InvoiceRepository();

  bool isLoadingInvoices = true;

  final GlobalKey<ScaffoldMessengerState>
      scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  // ==========================================================
  // INITIALIZATION
  // ==========================================================

  @override
  void initState() {
    super.initState();

    loadInvoices();
  }

  // ==========================================================
  // LOAD INVOICES
  // ==========================================================

  Future<void> loadInvoices() async {
    try {
      final loadedInvoices =
          await invoiceService.getInvoices();

      if (!mounted) return;

      setState(() {
        invoices.clear();
        invoices.addAll(loadedInvoices);

        for (final invoice in loadedInvoices) {
          invoiceRepository.addInvoice(invoice);
        }

        isLoadingInvoices = false;
      });

      debugPrint(
        'Invoices loaded from Firestore',
      );
    } catch (error) {
      debugPrint(
        'Failed to load invoices: $error',
      );

      if (!mounted) return;

      setState(() {
        isLoadingInvoices = false;
      });
    }
  }

  // ==========================================================
  // SAVE INVOICE
  // ==========================================================

  Future<void> saveInvoice(
    Invoice invoice,
  ) async {
    try {
      // Save to Firestore
      await invoiceService.addInvoice(invoice);

      if (!mounted) return;

      // Update local list
      setState(() {
        invoices.add(invoice);
      });

      // Update local repository
      invoiceRepository.addInvoice(invoice);

      // PDF is NOT generated here.
      // User generates it from Invoice Detail screen.

      scaffoldMessengerKey.currentState
          ?.showSnackBar(
        const SnackBar(
          content: Text(
            'Invoice saved successfully',
          ),
        ),
      );
    } catch (error) {
      debugPrint(
        'Failed to save invoice: $error',
      );

      if (!mounted) return;

      scaffoldMessengerKey.currentState
          ?.showSnackBar(
        SnackBar(
          content: Text(
            'Failed to save invoice: $error',
          ),
        ),
      );
    }
  }

  // ==========================================================
  // CANCEL INVOICE
  // ==========================================================

  Future<void> cancelInvoice(
    Invoice invoice,
  ) async {
    if (invoice.isCancelled) {
      return;
    }

    try {
      final cancelledInvoice =
          invoice.copyWith(
        isCancelled: true,
      );

      // Cancel invoice in Firestore
      await invoiceService.cancelInvoice(
        cancelledInvoice,
      );

      if (!mounted) return;

      final invoiceIndex =
          invoices.indexWhere(
        (item) => item.id == invoice.id,
      );

      if (invoiceIndex == -1) {
        return;
      }

      setState(() {
        invoices[invoiceIndex] =
            cancelledInvoice;
      });

      invoiceRepository.updateInvoice(
        cancelledInvoice,
      );

      scaffoldMessengerKey.currentState
          ?.showSnackBar(
        const SnackBar(
          content: Text(
            'Invoice cancelled successfully',
          ),
        ),
      );
    } catch (error) {
      debugPrint(
        'Failed to cancel invoice: $error',
      );

      if (!mounted) return;

      scaffoldMessengerKey.currentState
          ?.showSnackBar(
        SnackBar(
          content: Text(
            'Cancellation failed: $error',
          ),
        ),
      );
    }
  }

  // ==========================================================
  // BODY FOR SELECTED SECTION
  // ==========================================================

  Widget _bodyForSection(
    AppSection section,
  ) {
    switch (section) {
      // --------------------------------------------------------
      // DASHBOARD
      // --------------------------------------------------------

      case AppSection.home:
        return HomeContent(
          user: FirebaseAuth.instance.currentUser,

          onBilling: () {
            setState(() {
              currentSection =
                  AppSection.billing;
            });
          },

          onInvoices: () {
            setState(() {
              currentSection =
                  AppSection.invoices;
            });
          },
        );

      // --------------------------------------------------------
      // PRODUCTS & BILLING
      // --------------------------------------------------------

      case AppSection.billing:
        return BillingScreen(
          onInvoiceCreated: saveInvoice,
        );

      // --------------------------------------------------------
      // INVOICES
      // --------------------------------------------------------

      case AppSection.invoices:
        return InvoiceHistoryScreen(
          invoices: invoices,
          onCancelInvoice: cancelInvoice,
        );
    }
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      scaffoldMessengerKey:
          scaffoldMessengerKey,

      title: 'Wedding Card Billing',

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
        useMaterial3: true,
      ),

      home: isLoadingInvoices
          ? const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : AppShell(
              section: currentSection,

              onSectionSelected: (section) {
                setState(() {
                  currentSection = section;
                });
              },

              body: _bodyForSection(
                currentSection,
              ),

              user: FirebaseAuth
                  .instance
                  .currentUser,
            ),
    );
  }
}