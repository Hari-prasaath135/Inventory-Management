import 'package:flutter/material.dart';

/// Shared look & feel for Sree Lakshmi Cards screens.
/// Matches the palette used on HomePage (burgundy / cream / gold, serif
/// headings) so Billing, Products and Invoice Detail feel like one app.
class AppTheme {
  AppTheme._();

  static const Color burgundy = Color(0xFF8D1725);
  static const Color darkBurgundy = Color(0xFF5F0D18);
  static const Color cream = Color(0xFFFFFBF8);
  static const Color panel = Color(0xFFFFFCFA);
  static const Color gold = Color(0xFFC99A3D);
  static const Color navy = Color(0xFF172957);
  static const Color ink = Color(0xFF2B3045);
  static const Color border = Color(0xFFEBD8D3);
  static const Color danger = Color(0xFFB3261E);
  static const Color success = Color(0xFF2E7D32);

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
  }) {
    return TextStyle(
      fontFamily: serif,
      fontFamilyFallback: serifFallback,
      fontSize: size,
      fontWeight: weight,
      fontStyle: style,
      color: color,
      height: height,
    );
  }

  static InputDecoration input(String label, {IconData? icon, String? prefix}) {
    return InputDecoration(
      labelText: label,
      prefixText: prefix,
      prefixIcon: icon != null ? Icon(icon, color: burgundy, size: 20) : null,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: burgundy, width: 1.6),
      ),
    );
  }
}

/// Burgundy AppBar with a serif title, used on every screen.
class ThemedAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ThemedAppBar({
    super.key,
    required this.title,
    this.actions,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.darkBurgundy,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      iconTheme: const IconThemeData(color: Colors.white),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: AppTheme.serifStyle(size: 21, color: Colors.white),
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 11.5,
                color: Colors.white.withValues(alpha: 0.75),
                letterSpacing: 0.4,
              ),
            ),
        ],
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(subtitle == null ? kToolbarHeight : kToolbarHeight + 8);
}

/// Small inline ornament, e.g. "✦  ❖  ✦", used under section headers.
class Flourish extends StatelessWidget {
  const Flourish({super.key, this.color = AppTheme.gold, this.size = 16});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Text(
      '✦  ❖  ✦',
      style: TextStyle(color: color, fontSize: size),
    );
  }
}

/// Section header: burgundy circular icon + serif title, optional trailing.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.icon,
    required this.title,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.burgundy,
          ),
          child: Icon(icon, color: Colors.white, size: 19),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(title, style: AppTheme.serifStyle(size: 21)),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// Cream/white rounded card used for every section on every screen.
class ThemedCard extends StatelessWidget {
  const ThemedCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppTheme.panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Burgundy stadium button with a trailing circular chevron, matching the
/// "Manage Products / Create New Bill" buttons on the home page.
class PillButton extends StatelessWidget {
  const PillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.filled = true,
    this.expand = true,
    this.color = AppTheme.burgundy,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool filled;
  final bool expand;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;
    final fg = filled ? Colors.white : color;
    final bg = filled ? color : Colors.white;

    final child = Material(
      color: disabled ? bg.withValues(alpha: 0.5) : bg,
      shape: StadiumBorder(
        side: filled ? BorderSide.none : BorderSide(color: color, width: 1.3),
      ),
      elevation: filled && !disabled ? 2 : 0,
      shadowColor: color.withValues(alpha: 0.4),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: fg, size: 19),
                const SizedBox(width: 10),
              ],
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: fg,
                    fontWeight: FontWeight.bold,
                    fontSize: 15.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return expand ? SizedBox(width: double.infinity, child: child) : child;
  }
}

/// A single label/value row, right-aligned value — used for GST & totals.
class AmountRow extends StatelessWidget {
  const AmountRow({
    super.key,
    required this.label,
    required this.amount,
    this.emphasize = false,
    this.highlight = false,
  });

  final String label;
  final double amount;
  final bool emphasize;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: emphasize ? 18 : 15,
              fontWeight: emphasize ? FontWeight.bold : FontWeight.w500,
              color: emphasize ? AppTheme.darkBurgundy : AppTheme.ink,
            ),
          ),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: emphasize ? 22 : 15,
              fontWeight: FontWeight.bold,
              color: emphasize ? AppTheme.burgundy : AppTheme.ink,
            ),
          ),
        ],
      ),
    );

    if (!highlight) return row;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.burgundy.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
      ),
      child: row,
    );
  }
}

/// Small rounded status badge (e.g. "250 in stock", "CANCELLED").
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.text,
    this.color = AppTheme.success,
  });

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12.5,
        ),
      ),
    );
  }
}