
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/user_avatar.dart';

enum AppSection {
  home,
  billing,
  invoices,
}

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
  final Widget body;
  final VoidCallback? onLogout;
  final User? user;

  // ============================================================
  // THEME COLORS
  // ============================================================

  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);

  static const Color darkText = Color(0xFF0F172A);
  static const Color secondaryText = Color(0xFF475569);

  static const Color borderColor = Color(0xFFE2E8F0);
  static const Color selectedBackground = Color(0xFFEFF6FF);

  static const String serif = 'Georgia';

  static TextStyle serifStyle({
    required double size,
    FontWeight weight = FontWeight.bold,
    Color color = darkText,
    FontStyle style = FontStyle.normal,
  }) {
    return TextStyle(
      fontFamily: serif,
      fontSize: size,
      fontWeight: weight,
      fontStyle: style,
      color: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 900;

    final profile = Profile.fromUser(user);

    final navItems = <_NavItem>[
      _NavItem(
        icon: Icons.home_outlined,
        label: 'Dashboard',
        onTap: () {
          onSectionSelected(AppSection.home);
        },
        selected: section == AppSection.home,
      ),

      _NavItem(
        icon: Icons.shopping_cart_outlined,
        label: 'Billing',
        onTap: () {
          onSectionSelected(AppSection.billing);
        },
        selected: section == AppSection.billing,
      ),

  

      _NavItem(
        icon: Icons.description_outlined,
        label: 'Invoices',
        onTap: () {
          onSectionSelected(AppSection.invoices);
        },
        selected: section == AppSection.invoices,
      ),
    ];

    // ==========================================================
    // DESKTOP / WINDOWS
    // ==========================================================

    if (isWide) {
      return Scaffold(
        backgroundColor: background,
        body: Row(
          children: [
            _Sidebar(
              items: navItems,
            ),

            Expanded(
              child: Column(
                children: [
                  _DesktopHeader(
                    profile: profile,
                    onLogout: onLogout,
                  ),

                  Expanded(
                    child: body,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // ==========================================================
    // MOBILE / SMALL WINDOW
    // ==========================================================

    return Scaffold(
      backgroundColor: background,

      appBar: AppBar(
        backgroundColor: surface,
        foregroundColor: darkText,
        elevation: 0,

        title: Text(
          'Sree Lakshmi Cards & Bags',
          style: serifStyle(
            size: 20,
            color: darkText,
          ),
        ),

        actions: [
          Padding(
            padding: const EdgeInsets.only(
              right: 12,
            ),
            child: ProfileChip(
              profile: profile,
              onLogout: onLogout,
              compact: true,
            ),
          ),
        ],
      ),

      drawer: Drawer(
        width: 260,
        backgroundColor: surface,

        child: SafeArea(
          child: _Sidebar(
            width: 260,
            items: navItems,
          ),
        ),
      ),

      body: body,
    );
  }
}

// ============================================================
// NAVIGATION ITEM
// ============================================================

class _NavItem {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;
}

// ============================================================
// PROFILE
// ============================================================

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
    final displayName = user?.displayName?.trim();

    return Profile(
      name: displayName != null &&
              displayName.isNotEmpty
          ? displayName
          : 'User',
      email: user?.email ?? '',
      photoUrl: user?.photoURL,
      user: user,
    );
  }
}

// ============================================================
// DESKTOP HEADER
// ============================================================

class _DesktopHeader extends StatelessWidget {
  const _DesktopHeader({
    required this.profile,
    this.onLogout,
  });

  final Profile profile;
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,

      padding: const EdgeInsets.symmetric(
        horizontal: 28,
      ),

      decoration: const BoxDecoration(
       color: AppShell.surface,
        border: Border(
          bottom: BorderSide(
            color: AppShell.borderColor,
          ),
        ),
      ),

      child: Row(
        children: [
          Text(
            'Sree Lakshmi Cards & Bags',
         style: AppShell.serifStyle(
  size: 22,
  color: AppShell.darkText,
),
          ),

          const Spacer(),

          ProfileChip(
            profile: profile,
            onLogout: onLogout,
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SIDEBAR
// ============================================================

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.items,
    this.width = 236,
  });

  final List<_NavItem> items;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,

      decoration: const BoxDecoration(
        color: AppShell.surface,

        border: Border(
          right: BorderSide(
            color: AppShell.borderColor,
          ),
        ),
      ),

      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),

            // ==================================================
            // LOGO
            // ==================================================

            Container(
              width: 64,
              height: 64,

              padding: const EdgeInsets.all(7),

              decoration: BoxDecoration(
                color: AppShell.selectedBackground,
                borderRadius:
                    BorderRadius.circular(10),
              ),

              child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(7),

                child: Image.asset(
                  'assets/images/lakshmi_hd.png',

                  fit: BoxFit.contain,

                  errorBuilder:
                      (context, error, stackTrace) {
                    return const Icon(
                      Icons.storefront_outlined,
                      color: AppShell.primaryBlue,
                      size: 32,
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 12),

           Text(
  'Sree Lakshmi Cards and Bags',
  textAlign: TextAlign.center,
  style: const TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w900,
    letterSpacing: 0.5,
    color: AppShell.darkText,
  ),
),

          const Text(
  'Cards',
  style: TextStyle(
    color: AppShell.secondaryText,
    fontSize: 12,
  ),
),

            const SizedBox(height: 28),

            // ==================================================
            // NAVIGATION
            // ==================================================

            for (final item in items)
              _SidebarTile(
                item: item,
              ),

            const Spacer(),

            const Padding(
  padding: EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 8,
  ),
  child: Text(
    'Inventory',
    textAlign: TextAlign.left,
    style: TextStyle(
      color: AppShell.secondaryText,
      fontSize: 12,
    ),
  ),
),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// SIDEBAR TILE
// ============================================================

class _SidebarTile extends StatelessWidget {
  const _SidebarTile({
    required this.item,
  });

  final _NavItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 2,
      ),

      child: Material(
  color: item.selected
      ? AppShell.selectedBackground
      : Colors.transparent,

        borderRadius:
            BorderRadius.circular(8),

        child: InkWell(
          borderRadius:
              BorderRadius.circular(8),

          onTap: item.onTap,

          child: Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),

            child: Row(
              children: [
                Icon(
                  item.icon,

                  size: 21,

                  color: item.selected
                      ? AppShell.primaryBlue
                      : AppShell.secondaryText,
                ),

                const SizedBox(width: 13),

                Expanded(
                  child: Text(
                    item.label,

                    style: TextStyle(
                      color: item.selected
                          ? AppShell.primaryBlue
                          : AppShell.darkText,

                      fontSize: 15,

                      fontWeight: item.selected
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
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

// ============================================================
// PROFILE CHIP
// ============================================================

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
        color: AppShell.surface,
      ),

      child: UserAvatar(
        user: profile.user,
        radius: compact ? 18 : 21,
      ),
    );

    return PopupMenuButton<String>(
      tooltip: 'Account',

      offset: const Offset(0, 50),

      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(8),
      ),

      onSelected: (value) {
        if (value == 'logout') {
          if (onLogout != null) {
            onLogout!();
          } else {
            FirebaseAuth.instance.signOut();
          }
        }
      },

      itemBuilder: (context) {
        return [
          if (profile.email.isNotEmpty)
            PopupMenuItem<String>(
              enabled: false,

              child: Text(
                profile.email,

                overflow:
                    TextOverflow.ellipsis,

                style: const TextStyle(
                  color: AppShell.secondaryText,
                  fontSize: 12,
                ),
              ),
            ),

          const PopupMenuItem<String>(
            value: 'logout',

            child: Row(
              children: [
                Icon(
                  Icons.logout,
                  size: 18,
                  color: AppShell.primaryBlue,
                ),

                SizedBox(width: 10),

                Text('Sign out'),
              ],
            ),
          ),
        ];
      },

      child: compact
          ? avatar
          : Row(
              mainAxisSize:
                  MainAxisSize.min,

              children: [
                avatar,

                const SizedBox(width: 10),

                Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  mainAxisAlignment:
                      MainAxisAlignment.center,

                  children: [
                    SizedBox(
                      width: 140,

                      child: Text(
                        profile.name,

                        maxLines: 1,

                        overflow:
                            TextOverflow.ellipsis,

                        style:
                            const TextStyle(
                          color: AppShell.darkText,
                          fontSize: 14,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ),

                    const Text(
                      'Administrator',

                      style: TextStyle(
                        color: AppShell.secondaryText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 8),

                const Icon(
                  Icons.keyboard_arrow_down,
                 color: AppShell.secondaryText

                ),
              ],
            ),
    );
  }
}
