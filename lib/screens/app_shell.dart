import 'dart:math' as math;
import '../widgets/user_avatar.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Which tab is currently selected in the shell.
enum AppSection { home, billing, products, invoices }

/// Persistent shell: a burgundy sidebar (wide screens) or drawer (narrow
/// screens) that stays mounted while [body] swaps between Home, Billing,
/// Products and Invoices. Individual screens must NOT add their own bottom
/// navigation — all tab navigation lives here.
class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.section,
    required this.onSectionSelected,
    required this.body,
    this.onLogout,
    this.user,
  });

  final AppSection section;
  final ValueChanged<AppSection> onSectionSelected;

  /// Whatever should currently fill the content area (HomeContent,
  /// BillingScreen, ProductsScreen, InvoiceHistoryScreen, ...).
  final Widget body;

  final VoidCallback? onLogout;
  final User? user;

  // ---------------------------------------------------------------- palette
  static const Color burgundy = Color(0xFF8D1725);
  static const Color darkBurgundy = Color(0xFF5F0D18);
  static const Color cream = Color(0xFFFFFBF8);
  static const Color gold = Color(0xFFC99A3D);
  static const Color navy = Color(0xFF172957);
  static const Color ink = Color(0xFF2B3045);

  static const String serif = 'Georgia';
  static const List<String> serifFallback = [
    'Times New Roman',
    'Noto Serif',
    'serif',
  ];

  static TextStyle serifStyle({
    required double size,
    FontWeight weight = FontWeight.bold,
    Color color = darkBurgundy,
    FontStyle style = FontStyle.normal,
    double? height,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: serif,
      fontFamilyFallback: serifFallback,
      fontSize: size,
      fontWeight: weight,
      fontStyle: style,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 900;
    final profile = Profile.fromUser(user);

    final navItems = <_NavItem>[
      _NavItem(
        Icons.home_rounded,
        'Home',
        () => onSectionSelected(AppSection.home),
        selected: section == AppSection.home,
      ),
      _NavItem(
        Icons.shopping_cart,
        'Billing',
        () => onSectionSelected(AppSection.billing),
        selected: section == AppSection.billing,
      ),
      _NavItem(
        Icons.inventory_2_outlined,
        'Products',
        () => onSectionSelected(AppSection.products),
        selected: section == AppSection.products,
      ),
      _NavItem(
        Icons.description_outlined,
        'Invoices',
        () => onSectionSelected(AppSection.invoices),
        selected: section == AppSection.invoices,
      ),
    ];

    if (isWide) {
      return Scaffold(
        backgroundColor: cream,
        body: Row(
          children: [
            _Sidebar(items: navItems),
            Expanded(child: body),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: cream,
      appBar: AppBar(
        backgroundColor: darkBurgundy,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Sree Lakshmi Cards',
          style: serifStyle(size: 20, color: Colors.white),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ProfileChip(profile: profile, onLogout: onLogout, compact: true),
          ),
        ],
      ),
      drawer: Drawer(
        width: 268,
        backgroundColor: darkBurgundy,
        shape: const RoundedRectangleBorder(),
        child: Builder(
          builder: (ctx) => _Sidebar(
            width: 268,
            items: navItems,
            onItemTapped: () => Navigator.of(ctx).pop(),
          ),
        ),
      ),
      body: body,
    );
  }
}

// ============================================================ data classes

class _NavItem {
  const _NavItem(this.icon, this.label, this.onTap, {this.selected = false});

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;
}

/// Public so [AppShell] and Home content can both build a profile chip.
class Profile {
  const Profile({
    required this.name,
    required this.email,
    this.photoUrl,
    this.user,
  });

  final String name;
  final String email;
  final String? photoUrl;
  final User? user;

  factory Profile.fromUser(User? user) {
    final name = user?.displayName?.trim();

    return Profile(
      name: (name != null && name.isNotEmpty) ? name : 'User',
      email: user?.email ?? '',
      photoUrl: user?.photoURL,
      user: user,
    );
  }
}
// ================================================================== sidebar

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.items,
    this.width = 236,
    this.onItemTapped,
  });

  final List<_NavItem> items;
  final double width;
  final VoidCallback? onItemTapped;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF6A0E1B), Color(0xFF7D1322)],
        ),
      ),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, c) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: c.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 28),
                    Center(
                      child: CustomPaint(
                        size: const Size(96, 68),
                        painter: LotusPainter(
                          color: Colors.white.withValues(alpha: 0.92),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Sree Lakshmi\nCards',
                      textAlign: TextAlign.center,
                      style: AppShell.serifStyle(
                        size: 27,
                        color: Colors.white,
                        height: 1.12,
                      ),
                    ),
                    const SizedBox(height: 34),
                    for (final item in items)
                      _SidebarTile(item: item, onTapped: onItemTapped),
                    const Spacer(),
                    const SizedBox(height: 24),
                    const Center(
                      child: Flourish(
                        width: 110,
                        height: 14,
                        color: Color(0xCCFFFFFF),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Cards for\nEvery Occasion',
                      textAlign: TextAlign.center,
                      style: AppShell.serifStyle(
                        size: 24,
                        weight: FontWeight.normal,
                        style: FontStyle.italic,
                        color: Colors.white.withValues(alpha: 0.92),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Center(
                      child: Flourish(
                        width: 110,
                        height: 14,
                        color: Color(0xCCFFFFFF),
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SidebarTile extends StatelessWidget {
  const _SidebarTile({required this.item, this.onTapped});

  final _NavItem item;
  final VoidCallback? onTapped;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      child: Material(
        color: item.selected
            ? Colors.white.withValues(alpha: 0.16)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          hoverColor: Colors.white.withValues(alpha: 0.07),
          splashColor: Colors.white.withValues(alpha: 0.12),
          onTap: () {
            onTapped?.call();
            item.onTap();
          },
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 15, 16, 15),
                child: Row(
                  children: [
                    Icon(item.icon, color: Colors.white, size: 26),
                    const SizedBox(width: 22),
                    Expanded(
                      child: Text(
                        item.label,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight:
                              item.selected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (item.selected)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(width: 5, color: const Color(0xFFF2B8C0)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================ profile chip

class ProfileChip extends StatelessWidget {
  const ProfileChip({
    super.key,
    required this.profile,
    this.onLogout,
    this.compact = false,
  });

  final Profile profile;
  final VoidCallback? onLogout;
  final bool compact;

  @override
  Widget build(BuildContext context) {
   final avatar = Container(
  padding: const EdgeInsets.all(2),
  decoration: const BoxDecoration(
    shape: BoxShape.circle,
    color: Colors.white,
    boxShadow: [
      BoxShadow(
        color: Color(0x22000000),
        blurRadius: 8,
        offset: Offset(0, 3),
      ),
    ],
  ),
  child: UserAvatar(
    user: profile.user,
    radius: compact ? 18 : 27,
  ),
);

    return PopupMenuButton<String>(
      tooltip: 'Account',
      offset: const Offset(0, 56),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) {
        if (value == 'logout') {
          if (onLogout != null) {
            onLogout!();
          } else {
            FirebaseAuth.instance.signOut();
          }
        }
      },
      itemBuilder: (context) => [
        if (profile.email.isNotEmpty)
          PopupMenuItem<String>(
            enabled: false,
            child: Text(
              profile.email,
              style: const TextStyle(color: Colors.black54, fontSize: 13),
            ),
          ),
        const PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, size: 20, color: AppShell.burgundy),
              SizedBox(width: 10),
              Text('Sign out'),
            ],
          ),
        ),
      ],
      child: compact
          ? avatar
          : Container(
              padding: const EdgeInsets.fromLTRB(22, 4, 0, 4),
              decoration: const BoxDecoration(
                border: Border(left: BorderSide(color: Color(0xFFE0C4C4))),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  avatar,
                  const SizedBox(width: 12),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 150),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF17213B),
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Administrator',
                          style: TextStyle(color: Colors.black54, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    color: AppShell.darkBurgundy,
                  ),
                ],
              ),
            ),
    );
  }
}

// =========================================================== small widgets

class Diamond extends StatelessWidget {
  const Diamond({super.key, required this.color, this.size = 7});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: math.pi / 4,
      child: Container(width: size, height: size, color: color),
    );
  }
}

class Flourish extends StatelessWidget {
  const Flourish({
    super.key,
    required this.width,
    required this.height,
    required this.color,
  });

  final double width;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(painter: FlourishPainter(color)),
    );
  }
}

// ================================================================ painters

/// Horizontal ornamental divider: centre diamond with curling flourishes.
class FlourishPainter extends CustomPainter {
  const FlourishPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final w = size.width;
    final h = size.height;

    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round;
    final fill = Paint()..color = color;

    final d = h * 0.3;
    canvas.drawPath(
      Path()
        ..moveTo(cx, cy - d)
        ..lineTo(cx + d, cy)
        ..lineTo(cx, cy + d)
        ..lineTo(cx - d, cy)
        ..close(),
      fill,
    );

    for (final s in const [-1.0, 1.0]) {
      final path = Path()
        ..moveTo(cx + s * d * 1.7, cy)
        ..cubicTo(
          cx + s * w * 0.12, cy - h * 0.5,
          cx + s * w * 0.2, cy - h * 0.5,
          cx + s * w * 0.26, cy,
        )
        ..cubicTo(
          cx + s * w * 0.32, cy + h * 0.45,
          cx + s * w * 0.38, cy + h * 0.3,
          cx + s * w * 0.44, cy,
        )
        ..lineTo(cx + s * w * 0.485, cy);
      canvas.drawPath(path, stroke);
      canvas.drawCircle(Offset(cx + s * w * 0.485, cy), 1.5, fill);
    }
  }

  @override
  bool shouldRepaint(covariant FlourishPainter old) => old.color != color;
}

/// Seven-petal lotus (outlined, optionally filled).
class LotusPainter extends CustomPainter {
  const LotusPainter({
    required this.color,
    this.filled = false,
    this.fillColor,
    this.strokeWidth = 1.4,
  });

  final Color color;
  final bool filled;
  final Color? fillColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final base = Offset(size.width / 2, size.height * 0.9);
    final maxLen = size.height * 0.86;

    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    final fill = Paint()
      ..color = fillColor ?? color.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    const petals = <List<double>>[
      [-78, 0.58],
      [78, 0.58],
      [-52, 0.80],
      [52, 0.80],
      [-26, 0.95],
      [26, 0.95],
      [0, 1.0],
    ];

    for (final p in petals) {
      final len = maxLen * p[1];
      final w = len * 0.24;
      final path = Path()
        ..moveTo(0, 0)
        ..cubicTo(-w * 1.5, -len * 0.3, -w * 1.2, -len * 0.78, 0, -len)
        ..cubicTo(w * 1.2, -len * 0.78, w * 1.5, -len * 0.3, 0, 0);

      canvas.save();
      canvas.translate(base.dx, base.dy);
      canvas.rotate(p[0] * math.pi / 180);
      if (filled) canvas.drawPath(path, fill);
      canvas.drawPath(path, stroke);
      canvas.restore();
    }

    final bowl = Path()
      ..moveTo(size.width * 0.28, base.dy)
      ..quadraticBezierTo(
        size.width / 2,
        size.height * 1.02,
        size.width * 0.72,
        base.dy,
      );
    canvas.drawPath(bowl, stroke);
  }

  @override
  bool shouldRepaint(covariant LotusPainter old) =>
      old.color != color ||
      old.filled != filled ||
      old.fillColor != fillColor ||
      old.strokeWidth != strokeWidth;
}

/// Faint leafy branch used as a background watermark.
class BranchPainter extends CustomPainter {
  const BranchPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p0 = Offset(size.width * 0.30, size.height);
    final p1 = Offset(size.width * 0.05, size.height * 0.5);
    final p2 = Offset(size.width * 0.62, size.height * 0.02);

    final fill = Paint()..color = color;
    final stem = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.2, size.width * 0.012);

    canvas.drawPath(
      Path()
        ..moveTo(p0.dx, p0.dy)
        ..quadraticBezierTo(p1.dx, p1.dy, p2.dx, p2.dy),
      stem,
    );

    Offset at(double t) => Offset(
          (1 - t) * (1 - t) * p0.dx + 2 * (1 - t) * t * p1.dx + t * t * p2.dx,
          (1 - t) * (1 - t) * p0.dy + 2 * (1 - t) * t * p1.dy + t * t * p2.dy,
        );

    double angleAt(double t) {
      final dx = 2 * (1 - t) * (p1.dx - p0.dx) + 2 * t * (p2.dx - p1.dx);
      final dy = 2 * (1 - t) * (p1.dy - p0.dy) + 2 * t * (p2.dy - p1.dy);
      return math.atan2(dy, dx);
    }

    void leaf(Offset origin, double angle, double len) {
      final wid = len * 0.36;
      final path = Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(len * 0.5, -wid, len, 0)
        ..quadraticBezierTo(len * 0.5, wid, 0, 0);
      canvas.save();
      canvas.translate(origin.dx, origin.dy);
      canvas.rotate(angle);
      canvas.drawPath(path, fill);
      canvas.restore();
    }

    for (var i = 0; i < 6; i++) {
      final t = 0.12 + i * 0.15;
      final o = at(t);
      final a = angleAt(t);
      final len = size.height * (0.26 - i * 0.022);
      leaf(o, a - 0.85, len);
      leaf(o, a + 0.85, len);
    }
    leaf(p2, angleAt(1), size.height * 0.16);
  }

  @override
  bool shouldRepaint(covariant BranchPainter old) => old.color != color;
}