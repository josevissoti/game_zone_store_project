import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../models/user/user.dart';

typedef OwnerNameBuilder = Widget Function(String name);

class OwnerNameResolver extends StatelessWidget {
  final String uid;
  final UserService userService;
  final OwnerNameBuilder builder;
  final String fallbackName;

  const OwnerNameResolver({
    super.key,
    required this.uid,
    required this.userService,
    required this.builder,
    this.fallbackName = 'Usuário',
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserModel>(
      stream: userService.watchUser(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return builder(fallbackName);
        }

        if (snapshot.hasError || snapshot.data == null) {
          return builder(fallbackName);
        }

        final name = snapshot.data!.name.isNotEmpty
            ? snapshot.data!.name.split(' ').first
            : fallbackName;

        return builder(name);
      },
    );
  }
}

class OwnerNameChip extends StatelessWidget {
  final String uid;
  final UserService userService;
  final Color? backgroundColor;
  final Color? textColor;
  final double fontSize;
  final EdgeInsetsGeometry? padding;

  const OwnerNameChip({
    super.key,
    required this.uid,
    required this.userService,
    this.backgroundColor,
    this.textColor,
    this.fontSize = 11,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return OwnerNameResolver(
      uid: uid,
      userService: userService,
      builder: (name) => Container(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: backgroundColor ?? const Color(0xFF00D4FF).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(9999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.person_rounded,
              size: 10,
              color: textColor ?? const Color(0xFF00D4FF),
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                name,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  color: textColor ?? const Color(0xFF00D4FF),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}