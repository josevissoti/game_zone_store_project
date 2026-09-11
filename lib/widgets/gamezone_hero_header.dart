import 'package:flutter/material.dart';
import '../utils/design_tokens.dart';

class GameZoneHeroHeader extends StatelessWidget {
  final double height;
  final Color? backgroundColor;
  final Widget? trailing;

  const GameZoneHeroHeader({
    super.key,
    this.height = 108,
    this.backgroundColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: height,
      floating: false,
      pinned: true,
      backgroundColor: backgroundColor ?? GameZoneColors.surface,
      surfaceTintColor: Colors.transparent,
      toolbarHeight: height,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.only(
          left: GameZoneSpacing.lg,
          right: GameZoneSpacing.lg,
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'GAMEZONE',
              style: GameZoneTypography.displaySmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: GameZoneSpacing.md),
              trailing!,
            ],
          ],
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: GameZoneColors.primaryGradient,
          ),
        ),
      ),
    );
  }
}