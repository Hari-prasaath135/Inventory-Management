import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../widgets/user_avatar.dart';
import 'app_shell.dart';

/// Home tab content — shop header, welcome panel and the Billing / Products
/// / Invoices shortcut cards. Rendered as the `body` of [AppShell] when
/// [AppSection.home] is selected. Add the Lakshmi picture to your project
/// and register it in pubspec.yaml:
///   flutter:
///     assets:
///       - assets/images/lakshmi.png
/// (A golden lotus is shown automatically if the asset is missing.)
class HomeContent extends StatelessWidget {
  const HomeContent({
    super.key,
    required this.onBilling,
    required this.onProducts,
    required this.onInvoices,
    this.onLogout,
    this.user,
  });

  final VoidCallback onBilling;
  final VoidCallback onProducts;
  final VoidCallback onInvoices;
  final VoidCallback? onLogout;
  final User? user;

  static const String lakshmiAsset = 'assets/images/lakshmi.png';

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 900;
    final profile = Profile.fromUser(user);

    final cards = <_CardData>[
      _CardData(
        Icons.inventory_2_outlined,
        'Products',
        'Add, edit and manage your card products and stock.',
        'Manage Products',
        onProducts,
      ),
      _CardData(
        Icons.shopping_cart,
        'Billing',
        'Create new bills, add items and generate invoices.',
        'Create New Bill',
        onBilling,
      ),
      _CardData(
        Icons.description_outlined,
        'Invoices',
        'View, search and manage all your invoices.',
        'View Invoices',
        onInvoices,
      ),
    ];

    return Column(
      children: [
        Expanded(
          child: _MainArea(
            compact: !isWide,
            profile: profile,
            cards: cards,
            onLogout: onLogout,
          ),
        ),
        if (isWide) Container(height: 22, color: AppShell.darkBurgundy),
      ],
    );
  }
}

// ============================================================ data classes

class _CardData {
  const _CardData(
    this.icon,
    this.title,
    this.description,
    this.buttonText,
    this.onTap,
  );

  final IconData icon;
  final String title;
  final String description;
  final String buttonText;
  final VoidCallback onTap;
}

// ============================================================== main area

class _MainArea extends StatelessWidget {
  const _MainArea({
    required this.compact,
    required this.profile,
    required this.cards,
    this.onLogout,
  });

  final bool compact;
  final Profile profile;
  final List<_CardData> cards;
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFFCFA), Color(0xFFFCF3F0)],
        ),
      ),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _Header(
              compact: compact,
              profile: profile,
              onLogout: onLogout,
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: compact
                  ? const EdgeInsets.fromLTRB(12, 4, 12, 12)
                  : const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: _WelcomePanel(compact: compact, cards: cards),
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================== header

class _Header extends StatelessWidget {
  const _Header({
    required this.compact,
    required this.profile,
    this.onLogout,
  });

  final bool compact;
  final Profile profile;
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          children: [
            _LakshmiImage(height: 110),
            SizedBox(height: 6),
            _TitleBlock(compact: true),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, c) {
        final tight = c.maxWidth < 1000;
        return Padding(
          padding: const EdgeInsets.fromLTRB(40, 18, 32, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _LakshmiImage(height: tight ? 130 : 170),
              const SizedBox(width: 20),
              const Expanded(child: _TitleBlock(compact: false)),
              const SizedBox(width: 16),
              ProfileChip(
                profile: profile,
                onLogout: onLogout,
                compact: tight,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LakshmiImage extends StatelessWidget {
  const _LakshmiImage({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      HomeContent.lakshmiAsset,
      height: height,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stack) => SizedBox(
        height: height,
        width: height * 0.85,
        child: Center(
          child: CustomPaint(
            size: Size(height * 0.8, height * 0.6),
            painter: const LotusPainter(
              color: AppShell.gold,
              filled: true,
              strokeWidth: 1.6,
            ),
          ),
        ),
      ),
    );
  }
}

class _TitleBlock extends StatelessWidget {
  const _TitleBlock({required this.compact});

  final bool compact;

  static const String _address =
      'Near KBS Coffe Shop, Chetty Street, Sri Vija Lakshmi, Pondicherry - 605001';

  @override
  Widget build(BuildContext context) {
    final small = compact ? 12.5 : 14.0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Flourish(width: 150, height: 14, color: AppShell.burgundy),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'Sree Lakshmi Cards',
            textAlign: TextAlign.center,
            style: AppShell.serifStyle(
              size: compact ? 34 : 48,
              height: 1.1,
            ),
          ),
        ),
        const SizedBox(height: 2),
        const Flourish(width: 70, height: 8, color: AppShell.burgundy),
        const SizedBox(height: 6),
        Text(
          'WHOLESALE & RETAIL DEALER IN',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppShell.navy,
            fontWeight: FontWeight.bold,
            fontSize: small,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          'ALL KINDS OF GREETING CARDS, INVITATION CARDS & RELATED ITEMS',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppShell.navy,
            fontWeight: FontWeight.w600,
            fontSize: small + 0.5,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 10),
        _InfoRow(icon: Icons.location_on, text: _address, compact: compact),
        const SizedBox(height: 6),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: 4,
          children: [
            _InfoRow(
              icon: Icons.phone,
              text: '+91 98765 43210',
              compact: compact,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Container(
                width: 1,
                height: 18,
                color: const Color(0xFFDCC5C5),
              ),
            ),
            _InfoRow(
              icon: Icons.email,
              text: 'sreelakshmicards@gmail.com',
              compact: compact,
            ),
          ],
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.text,
    required this.compact,
  });

  final IconData icon;
  final String text;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: AppShell.burgundy),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              fontSize: compact ? 13 : 15.5,
              color: AppShell.ink,
            ),
          ),
        ),
      ],
    );
  }
}

// ========================================================== welcome panel

class _WelcomePanel extends StatelessWidget {
  const _WelcomePanel({required this.compact, required this.cards});

  final bool compact;
  final List<_CardData> cards;

  @override
  Widget build(BuildContext context) {
    final pad = compact ? 16.0 : 56.0;
    final leaf = BranchPainter(
      AppShell.burgundy.withValues(alpha: 0.06),
    );

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFFEFD), Color(0xFFFEF8F6)],
        ),
        borderRadius: compact
            ? BorderRadius.circular(18)
            : const BorderRadius.vertical(top: Radius.circular(18)),
        border: Border.all(color: const Color(0xFFEEDAD6)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (!compact) ...[
            Positioned(
              left: -10,
              top: 30,
              width: 150,
              height: 200,
              child: IgnorePointer(child: CustomPaint(painter: leaf)),
            ),
            Positioned(
              right: -10,
              top: 30,
              width: 150,
              height: 200,
              child: IgnorePointer(
                child: Transform.flip(
                  flipX: true,
                  child: CustomPaint(painter: leaf),
                ),
              ),
            ),
          ],
          Padding(
            padding: EdgeInsets.symmetric(horizontal: pad),
            child: Column(
              children: [
                SizedBox(height: compact ? 14 : 20),
                const Flourish(
                  width: 200,
                  height: 16,
                  color: AppShell.burgundy,
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Welcome to Sree Lakshmi Cards',
                    textAlign: TextAlign.center,
                    style: AppShell.serifStyle(size: compact ? 30 : 52),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Manage your products, create bills, and keep track of invoices easily.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: compact ? 15 : 20,
                    color: AppShell.ink,
                  ),
                ),
                const SizedBox(height: 10),
                _LotusDivider(lineWidth: compact ? 50 : 150),
                const SizedBox(height: 4),
                Text(
                  'Quality Cards for Life\u2019s Special Moments',
                  textAlign: TextAlign.center,
                  style: AppShell.serifStyle(
                    size: compact ? 16 : 20,
                    weight: FontWeight.normal,
                    style: FontStyle.italic,
                    color: const Color(0xFF8A4B1F),
                  ),
                ),
                SizedBox(height: compact ? 20 : 30),
                // Pass the already-known `compact` flag down instead of
                // re-measuring width with a LayoutBuilder here. A
                // LayoutBuilder cannot sit inside a SliverFillRemaining
                // (hasScrollBody: false) subtree — that sliver asks its
                // child for its intrinsic height, and LayoutBuilder always
                // throws on intrinsic-size queries, which is what was
                // crashing the Home screen.
                _CardsLayout(cards: cards, compact: compact),
                const Spacer(),
                const SizedBox(height: 20),
                _Footer(compact: compact),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CardsLayout extends StatelessWidget {
  const _CardsLayout({required this.cards, required this.compact});

  final List<_CardData> cards;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Column(
        children: [
          for (var i = 0; i < cards.length; i++) ...[
            _FeatureCard(data: cards[i]),
            if (i != cards.length - 1) const SizedBox(height: 16),
          ],
        ],
      );
    }
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < cards.length; i++) ...[
            Expanded(child: _FeatureCard(data: cards[i])),
            if (i != cards.length - 1) const SizedBox(width: 28),
          ],
        ],
      ),
    );
  }
}

class _FeatureCard extends StatefulWidget {
  const _FeatureCard({required this.data});

  final _CardData data;

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final d = widget.data;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _hover ? -5 : 0, 0),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFFFFF), Color(0xFFFDF0ED)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _hover ? const Color(0xFFDDA9AE) : const Color(0xFFEBD3CF),
          ),
          boxShadow: [
            BoxShadow(
              color: AppShell.burgundy.withValues(alpha: _hover ? 0.18 : 0.08),
              blurRadius: _hover ? 26 : 16,
              offset: Offset(0, _hover ? 12 : 7),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: 8,
              right: 8,
              width: 86,
              height: 100,
              child: IgnorePointer(
                child: CustomPaint(
                  painter: BranchPainter(
                    AppShell.burgundy.withValues(alpha: 0.07),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(26, 28, 26, 26),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _IconBadge(icon: d.icon),
                  const SizedBox(height: 18),
                  Text(d.title, style: AppShell.serifStyle(size: 34)),
                  const SizedBox(height: 10),
                  Text(
                    d.description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16.5,
                      height: 1.55,
                      color: Color(0xFF3B3B45),
                    ),
                  ),
                  const SizedBox(height: 26),
                  _PillButton(label: d.buttonText, onTap: d.onTap),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppShell.burgundy.withValues(alpha: 0.06),
      ),
      child: Container(
        width: 92,
        height: 92,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const RadialGradient(
            center: Alignment(-0.3, -0.4),
            radius: 0.95,
            colors: [Color(0xFFB02A3E), Color(0xFF7A1120)],
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.22),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppShell.burgundy.withValues(alpha: 0.35),
              blurRadius: 26,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 44),
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: AppShell.burgundy.withValues(alpha: 0.14),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        shape: const StadiumBorder(
          side: BorderSide(color: Color(0xFFB83A4B), width: 1.2),
        ),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 7, 7, 7),
            child: Row(
              children: [
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: AppShell.darkBurgundy,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppShell.darkBurgundy,
                  ),
                  child: const Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ================================================================== footer

class _Footer extends StatelessWidget {
  const _Footer({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    const lineColor = Color(0xFFE3C7C4);
    const smallStyle = TextStyle(color: Color(0xFF17213B), fontSize: 13);

    final gst = const Text(
      '* GST is payable on Reverse Charge : No',
      style: smallStyle,
    );
    final site = const Text('www.sreelakshmicards.in', style: smallStyle);
    final thanks = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Thank You!', style: AppShell.serifStyle(size: compact ? 24 : 32)),
        const Text(
          'Visit Again',
          style: TextStyle(
            color: AppShell.ink,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(child: Container(height: 1, color: lineColor)),
            const Flourish(width: 130, height: 16, color: AppShell.burgundy),
            Expanded(child: Container(height: 1, color: lineColor)),
          ],
        ),
        const SizedBox(height: 6),
        if (compact)
          Column(
            children: [
              thanks,
              const SizedBox(height: 10),
              gst,
              const SizedBox(height: 2),
              site,
            ],
          )
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: Align(alignment: Alignment.centerLeft, child: gst)),
              const _SideOrnament(),
              const SizedBox(width: 14),
              thanks,
              const SizedBox(width: 14),
              const _SideOrnament(reverse: true),
              Expanded(child: Align(alignment: Alignment.centerRight, child: site)),
            ],
          ),
      ],
    );
  }
}

class _SideOrnament extends StatelessWidget {
  const _SideOrnament({this.reverse = false});

  final bool reverse;

  @override
  Widget build(BuildContext context) {
    final line = Container(
      width: 80,
      height: 1.2,
      color: AppShell.burgundy.withValues(alpha: 0.7),
    );
    const diamond = Diamond(color: AppShell.burgundy, size: 8);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: reverse
          ? [diamond, const SizedBox(width: 4), line]
          : [line, const SizedBox(width: 4), diamond],
    );
  }
}

class _FadeLine extends StatelessWidget {
  const _FadeLine({required this.width, this.reverse = false});

  final double width;
  final bool reverse;

  @override
  Widget build(BuildContext context) {
    final solid = AppShell.gold;
    final clear = AppShell.gold.withValues(alpha: 0);
    return Container(
      width: width,
      height: 1.3,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: reverse ? [solid, clear] : [clear, solid],
        ),
      ),
    );
  }
}

class _LotusDivider extends StatelessWidget {
  const _LotusDivider({required this.lineWidth});

  final double lineWidth;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _FadeLine(width: lineWidth),
        const SizedBox(width: 6),
        const Diamond(color: AppShell.gold, size: 6),
        const SizedBox(width: 10),
        const CustomPaint(
          size: Size(38, 26),
          painter: LotusPainter(
            color: Color(0xFFD9A441),
            filled: true,
            fillColor: Color(0xFFF0C568),
            strokeWidth: 1.2,
          ),
        ),
        const SizedBox(width: 10),
        const Diamond(color: AppShell.gold, size: 6),
        const SizedBox(width: 6),
        _FadeLine(width: lineWidth, reverse: true),
      ],
    );
  }
}