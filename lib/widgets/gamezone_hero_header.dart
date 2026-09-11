import 'package:flutter/material.dart';
import '../utils/design_tokens.dart';

class GameZoneHeroHeader extends StatelessWidget {
  final String collapsedTitle;
  final String? collapsedSubtitle;
  final String expandedTagline;
  final Widget? trailing;
  final double expandedHeight;
  final Color? backgroundColor;
  final Color? surfaceTintColor;

  const GameZoneHeroHeader({
    super.key,
    required this.collapsedTitle,
    this.collapsedSubtitle,
    required this.expandedTagline,
    this.trailing,
    this.expandedHeight = 180,
    this.backgroundColor,
    this.surfaceTintColor,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;
    final isTablet = screenWidth > 600;

    return SliverAppBar(
      expandedHeight: expandedHeight,
      floating: false,
      pinned: true,
      backgroundColor: backgroundColor ?? GameZoneColors.surface,
      surfaceTintColor: surfaceTintColor ?? Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.only(
          left: isDesktop ? GameZoneSpacing.xl : GameZoneSpacing.lg,
          right: isDesktop ? GameZoneSpacing.xl : GameZoneSpacing.lg,
          bottom: 16,
        ),
        title: _buildCollapsedTitle(isDesktop, isTablet),
        background: _buildExpandedBackground(isDesktop, isTablet),
      ),
    );
  }

  Widget _buildCollapsedTitle(bool isDesktop, bool isTablet) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => GameZoneColors.primaryGradient.createShader(bounds),
          child: Text(
            'GAMEZONE',
            style: GameZoneTypography.displaySmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
        ),
        const SizedBox(width: GameZoneSpacing.md),
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                collapsedTitle,
                style: GameZoneTypography.headlineMedium.copyWith(
                  color: GameZoneColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (collapsedSubtitle != null && (isTablet || isDesktop)) ...[
                const SizedBox(height: 2),
                Text(
                  collapsedSubtitle!,
                  style: GameZoneTypography.labelSmall.copyWith(
                    color: GameZoneColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: GameZoneSpacing.sm),
          trailing!,
        ],
      ],
    );
  }

  Widget _buildExpandedBackground(bool isDesktop, bool isTablet) {
    final horizontalPadding = isDesktop ? GameZoneSpacing.xl : GameZoneSpacing.lg;

    return Container(
      decoration: BoxDecoration(
        gradient: GameZoneColors.primaryGradient,
      ),
      child: Stack(
        children: [
          // Decorative orbs
          Positioned(
            top: -60,
            right: -40,
            child: Container(
              width: isDesktop ? 220 : 180,
              height: isDesktop ? 220 : 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    GameZoneColors.accentCoral.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -60,
            child: Container(
              width: isDesktop ? 260 : 220,
              height: isDesktop ? 260 : 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    GameZoneColors.primaryCyan.withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Main content
          Positioned(
            left: horizontalPadding,
            right: horizontalPadding,
            bottom: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      GameZoneColors.textOnPrimary,
                      GameZoneColors.textOnPrimary.withValues(alpha: 0.7)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: Text(
                    'GAMEZONE',
                    style: GameZoneTypography.displayMedium.copyWith(
                      color: GameZoneColors.textOnPrimary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: GameZoneSpacing.xs),
                Text(
                  expandedTagline,
                  style: GameZoneTypography.bodyMedium.copyWith(
                    color: GameZoneColors.textOnPrimary.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}