import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final User? user;
  final double radius;

  const UserAvatar({
    super.key,
    required this.user,
    this.radius = 22,
  });

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return CircleAvatar(
        radius: radius,
        child: const Icon(Icons.person),
      );
    }

    final uid = user!.uid;

    // Generate a stable number from the Firebase UID.
    final seed = uid.codeUnits.fold(
      0,
      (previous, element) => previous + element,
    );

    final random = Random(seed);

    final colors = [
      const Color(0xFF8D1725),
      const Color(0xFFB76E79),
      const Color(0xFFC99A3D),
      const Color(0xFF6A4C93),
      const Color(0xFF457B9D),
      const Color(0xFF2A9D8F),
      const Color(0xFFE76F51),
    ];

    final backgroundColor =
        colors[random.nextInt(colors.length)];

    final name = user!.displayName ?? '';
    final email = user!.email ?? '';

    String initial = 'U';

    if (name.trim().isNotEmpty) {
      initial = name.trim()[0].toUpperCase();
    } else if (email.isNotEmpty) {
      initial = email[0].toUpperCase();
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      child: Text(
        initial,
        style: TextStyle(
          color: Colors.white,
          fontSize: radius * 0.8,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}