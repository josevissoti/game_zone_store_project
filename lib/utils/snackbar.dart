import 'package:flutter/material.dart';
import 'design_tokens.dart';

enum SnackBarType {
  success,
  error,
  info,
}

void showSnackBar(
  BuildContext context, {
  required String message,
  SnackBarType type = SnackBarType.info,
  Duration duration = const Duration(seconds: 3),
  VoidCallback? onActionPressed,
  String? actionLabel,
}) {
  Color backgroundColor;
  Color actionColor;

  switch (type) {
    case SnackBarType.success:
      backgroundColor = GameZoneColors.surfaceElevated;
      actionColor = GameZoneColors.accentGreen;
      break;
    case SnackBarType.error:
      backgroundColor = GameZoneColors.borderError.withValues(alpha: 0.2);
      actionColor = GameZoneColors.borderError;
      break;
    case SnackBarType.info:
      backgroundColor = GameZoneColors.surfaceElevated;
      actionColor = GameZoneColors.primaryCyan;
      break;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message, style: GameZoneTypography.bodyMedium.copyWith(color: GameZoneColors.textPrimary)),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(GameZoneRadius.lg),
      ),
      margin: const EdgeInsets.all(GameZoneSpacing.md),
      padding: const EdgeInsets.symmetric(
        horizontal: GameZoneSpacing.lg,
        vertical: GameZoneSpacing.md,
      ),
      duration: duration,
      action: onActionPressed != null && actionLabel != null
          ? SnackBarAction(
              label: actionLabel,
              textColor: actionColor,
              onPressed: onActionPressed,
            )
          : null,
    ),
  );
}