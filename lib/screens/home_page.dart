import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'app_shell.dart';

class HomeContent extends StatelessWidget {
 const HomeContent({
  super.key,
  required this.onBilling,
  required this.onInvoices,
  this.user,
});

  final VoidCallback onBilling;

  final VoidCallback onInvoices;
  final User? user;

  @override
  Widget build(BuildContext context) {
    final profile = Profile.fromUser(user);

    return Container(
      color: AppShell.background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --------------------------------------------------
            // DASHBOARD HEADER
            // --------------------------------------------------

            Text(
              'Dashboard',
              style: AppShell.serifStyle(
                size: 28,
                color: AppShell.darkText,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'Welcome back, ${profile.name}',
              style: const TextStyle(
                fontSize: 14,
                color: AppShell.secondaryText,
              ),
            ),

            const SizedBox(height: 28),

            // --------------------------------------------------
            // SUMMARY CARDS
            // --------------------------------------------------

            LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 700;

             final cards = [
                _DashboardCard(
                  icon: Icons.point_of_sale_outlined,
                  title: 'Products & Billing',
                  value: 'Create Bill',
                  onTap: onBilling,
                ),
                _DashboardCard(
                  icon: Icons.receipt_long_outlined,
                  title: 'Invoices',
                  value: 'View',
                  onTap: onInvoices,
                ),
              ];

                if (compact) {
                  return Column(
                    children: [
                      for (int i = 0; i < cards.length; i++) ...[
                        cards[i],
                        if (i != cards.length - 1)
                          const SizedBox(height: 12),
                      ],
                    ],
                  );
                }

              return Row(
  children: [
    Expanded(child: cards[0]),
    const SizedBox(width: 16),
    Expanded(child: cards[1]),
  ],
);
              },
            ),

            const SizedBox(height: 32),

            // --------------------------------------------------
            // QUICK ACTIONS
            // --------------------------------------------------

            Text(
              'Quick Actions',
              style: AppShell.serifStyle(
                size: 20,
                color: AppShell.darkText,
              ),
            ),

            const SizedBox(height: 14),

          Row(
  children: [
    Expanded(
      child: _ActionButton(
        icon: Icons.add_shopping_cart_outlined,
        title: 'New Bill',
        onTap: onBilling,
      ),
    ),

    const SizedBox(width: 12),

    Expanded(
      child: _ActionButton(
        icon: Icons.receipt_long_outlined,
        title: 'Invoices',
        onTap: onInvoices,
      ),
    ),
  ],
),

            const SizedBox(height: 32),

            // --------------------------------------------------
            // RECENT PRODUCTS
            // --------------------------------------------------

            Text(
              'Recent Products',
              style: AppShell.serifStyle(
                size: 20,
                color: AppShell.darkText,
              ),
            ),

            const SizedBox(height: 14),

            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppShell.surface,
                border: Border.all(
                  color: AppShell.borderColor,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _TableHeader(),

                  const Divider(
                    height: 1,
                    color: AppShell.borderColor,
                  ),

                  _ProductRow(
                    product: 'Card A',
                    quantity: '120',
                    price: '₹50',
                    status: 'In Stock',
                    statusColor: Colors.green,
                  ),

                  _ProductRow(
                    product: 'Card B',
                    quantity: '12',
                    price: '₹80',
                    status: 'Low Stock',
                    statusColor: Colors.orange,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// DASHBOARD CARD
// ============================================================

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppShell.surface,
          border: Border.all(
            color: AppShell.borderColor,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppShell.selectedBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: AppShell.primaryBlue,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppShell.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppShell.darkText,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: AppShell.secondaryText,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// QUICK ACTION
// ============================================================

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(
        icon,
        size: 18,
      ),
      label: Text(title),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppShell.primaryBlue,
        side: const BorderSide(
          color: AppShell.borderColor,
        ),
        padding: const EdgeInsets.symmetric(
          vertical: 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

// ============================================================
// TABLE HEADER
// ============================================================

class _TableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              'Product',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppShell.darkText,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Qty',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppShell.darkText,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Price',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppShell.darkText,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Status',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppShell.darkText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// PRODUCT ROW
// ============================================================

class _ProductRow extends StatelessWidget {
  const _ProductRow({
    required this.product,
    required this.quantity,
    required this.price,
    required this.status,
    required this.statusColor,
  });

  final String product;
  final String quantity;
  final String price;
  final String status;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(product),
          ),
          Expanded(
            child: Text(quantity),
          ),
          Expanded(
            child: Text(price),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: statusColor,
                  ),
                ),
                const SizedBox(width: 6),
                Text(status),
              ],
            ),
          ),
        ],
      ),
    );
  }
}