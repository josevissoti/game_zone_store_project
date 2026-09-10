import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/design_tokens.dart';

class AuthCard extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsetsGeometry? padding;
  final bool showTopAccent;
  final List<BoxShadow>? shadows;

  const AuthCard({
    super.key,
    required this.child,
    this.maxWidth = 420,
    this.padding,
    this.showTopAccent = true,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 600;
    final cardWidth = isWideScreen ? maxWidth! : screenWidth - GameZoneSpacing.lg * 2;
    
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isWideScreen ? GameZoneSpacing.xl : GameZoneSpacing.lg,
          vertical: GameZoneSpacing.xl,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: cardWidth),
          child: Container(
            padding: padding ?? const EdgeInsets.all(GameZoneSpacing.xl),
            decoration: BoxDecoration(
              gradient: GameZoneColors.cardGradient,
              borderRadius: BorderRadius.circular(GameZoneRadius.xl),
              border: Border.all(
                color: GameZoneColors.border,
                width: 1,
              ),
              boxShadow: shadows ?? GameZoneShadows.card,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showTopAccent) _buildTopAccent(),
                if (showTopAccent) const SizedBox(height: GameZoneSpacing.lg),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopAccent() {
    return Container(
      width: 48,
      height: 4,
      decoration: BoxDecoration(
        gradient: GameZoneColors.primaryGradient,
        borderRadius: BorderRadius.circular(GameZoneRadius.full),
      ),
    );
  }
}

class AuthCardHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;
  final CrossAxisAlignment crossAxisAlignment;

  const AuthCardHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Row(
          mainAxisAlignment: crossAxisAlignment == CrossAxisAlignment.center
              ? MainAxisAlignment.center
              : MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: ShaderMask(
                shaderCallback: (bounds) => GameZoneColors.primaryGradient
                    .createShader(bounds),
                child: Text(
                  title,
                  style: GameZoneTypography.displaySmall.copyWith(
                    color: Colors.white,
                  ),
                  textAlign: crossAxisAlignment == CrossAxisAlignment.center
                      ? TextAlign.center
                      : TextAlign.start,
                ),
              ),
            ),
            action ?? const SizedBox.shrink(),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: GameZoneSpacing.sm),
          Text(
            subtitle!,
            style: GameZoneTypography.bodyMedium.copyWith(
              color: GameZoneColors.textSecondary,
            ),
            textAlign: crossAxisAlignment == CrossAxisAlignment.center
                ? TextAlign.center
                : TextAlign.start,
          ),
        ],
      ],
    );
}
}

class AuthTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final TextCapitalization textCapitalization;
  final bool enabled;
  final VoidCallback? onTap;
  final bool readOnly;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.obscureText = false,
    this.onChanged,
    this.textCapitalization = TextCapitalization.none,
    this.enabled = true,
    this.onTap,
    this.readOnly = false,
  });

  @override
  State<AuthTextField> createState() => AuthTextFieldState();
}

class AuthTextFieldState extends State<AuthTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _hasContent = false;
  bool _hasBeenTouched = false;
  bool _formSubmitted = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
    _hasContent = widget.controller.text.isNotEmpty;
    widget.controller.addListener(_onContentChange);
  }

  void _onFocusChange() {
    final wasFocused = _isFocused;
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
    // Mark as touched when field loses focus
    if (wasFocused && !_isFocused) {
      setState(() => _hasBeenTouched = true);
    }
  }

  void _onContentChange() {
    final hasContent = widget.controller.text.isNotEmpty;
    if (hasContent != _hasContent) {
      setState(() => _hasContent = hasContent);
    }
    
    // Real-time validation: run validator on every content change
    // Only update error if field has been touched or form submitted
    if (widget.validator != null && (_hasBeenTouched || _formSubmitted)) {
      final error = widget.validator!(widget.controller.text);
      setState(() => _errorText = error);
    }
  }

  // External validation trigger (called on form submit)
  bool validate() {
    if (widget.validator != null) {
      final error = widget.validator!(widget.controller.text);
      setState(() {
        _errorText = error;
        _formSubmitted = true;
      });
      return error == null;
    }
    setState(() => _formSubmitted = true);
    return true;
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    widget.controller.removeListener(_onContentChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show error only if field has been touched or form submitted
    final hasError = _errorText != null && (_hasBeenTouched || _formSubmitted);

    final borderColor = _errorText != null
        ? GameZoneColors.borderError
        : (_isFocused || _hasContent
            ? GameZoneColors.borderFocus
            : GameZoneColors.border);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(GameZoneRadius.lg),
            border: Border.all(
              color: borderColor,
              width: (_isFocused || _hasContent || hasError) ? 2 : 1,
            ),
            color: GameZoneColors.surface,
            boxShadow: (_isFocused || _hasContent)
                ? [
                    BoxShadow(
                      color: borderColor.withValues(alpha: 0.15),
                      blurRadius: 16,
                      spreadRadius: -4,
                      offset: const Offset(0, 0),
                    ),
                  ]
                : null,
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            enabled: widget.enabled,
            readOnly: widget.readOnly,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            inputFormatters: widget.inputFormatters,
            textCapitalization: widget.textCapitalization,
            style: GameZoneTypography.bodyLarge.copyWith(
              color: GameZoneColors.textPrimary,
            ),
            cursorColor: GameZoneColors.primaryCyan,
            cursorWidth: 2,
            onChanged: widget.onChanged,
            onTap: widget.onTap,
            decoration: InputDecoration(
              labelText: widget.label,
              hintText: widget.hint,
              labelStyle: GameZoneTypography.labelSmall.copyWith(
                color: _isFocused ? GameZoneColors.primaryCyan : GameZoneColors.textMuted,
              ),
              floatingLabelBehavior: FloatingLabelBehavior.always,
              hintStyle: GameZoneTypography.bodyMedium.copyWith(
                color: GameZoneColors.textMuted,
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.all(GameZoneSpacing.md),
                child: Icon(
                  widget.prefixIcon,
                  size: 22,
                  color: _isFocused ? GameZoneColors.primaryCyan : GameZoneColors.textMuted,
                ),
              ),
              suffixIcon: widget.suffixIcon != null
                  ? Padding(
                      padding: const EdgeInsets.all(GameZoneSpacing.md),
                      child: widget.suffixIcon,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: GameZoneSpacing.md,
                vertical: GameZoneSpacing.md,
              ),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: GameZoneSpacing.xs),
          Padding(
            padding: const EdgeInsets.only(left: GameZoneSpacing.xs),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 14,
                  color: GameZoneColors.borderError,
                ),
                const SizedBox(width: GameZoneSpacing.xs),
                Flexible(
                  child: Text(
                    _errorText!,
                    style: GameZoneTypography.labelSmall.copyWith(
                      color: GameZoneColors.borderError,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class AuthButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isSecondary;
  final bool isCoral;
  final IconData? icon;
  final double? width;

  const AuthButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isSecondary = false,
    this.isCoral = false,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: 56,
      child: isSecondary ? _buildSecondary() : (isCoral ? _buildCoral() : _buildPrimary()),
    );
  }

  Widget _buildPrimary() {
    return AnimatedContainer(
      duration: GameZoneAnimations.normal,
      curve: GameZoneAnimations.standard,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(GameZoneRadius.lg),
        gradient: onPressed != null && !isLoading
            ? GameZoneColors.primaryGradient
            : LinearGradient(
                colors: [
                  GameZoneColors.primaryCyan.withValues(alpha: 0.4),
                  GameZoneColors.primaryPurple.withValues(alpha: 0.4),
                ],
              ),
        boxShadow: onPressed != null && !isLoading
            ? GameZoneShadows.button
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(GameZoneRadius.lg),
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: GameZoneSpacing.lg),
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, size: 20, color: GameZoneColors.textOnPrimary),
                        const SizedBox(width: GameZoneSpacing.sm),
                      ],
                      Flexible(
                        child: Text(
                          text,
                          style: GameZoneTypography.titleLarge.copyWith(
                            color: GameZoneColors.textOnPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildCoral() {
    return AnimatedContainer(
      duration: GameZoneAnimations.normal,
      curve: GameZoneAnimations.standard,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(GameZoneRadius.lg),
        gradient: onPressed != null && !isLoading
            ? GameZoneColors.coralGradient
            : LinearGradient(
                colors: [
                  GameZoneColors.accentCoral.withValues(alpha: 0.4),
                  GameZoneColors.accentCoralDark.withValues(alpha: 0.4),
                ],
              ),
        boxShadow: onPressed != null && !isLoading
            ? GameZoneShadows.coralButton
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(GameZoneRadius.lg),
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: GameZoneSpacing.lg),
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, size: 20, color: GameZoneColors.textOnPrimary),
                        const SizedBox(width: GameZoneSpacing.sm),
                      ],
                      Flexible(
                        child: Text(
                          text,
                          style: GameZoneTypography.titleLarge.copyWith(
                            color: GameZoneColors.textOnPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondary() {
    return AnimatedContainer(
      duration: GameZoneAnimations.normal,
      curve: GameZoneAnimations.standard,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(GameZoneRadius.lg),
        border: Border.all(
          color: onPressed != null && !isLoading
              ? GameZoneColors.borderFocus
              : GameZoneColors.border,
          width: 1.5,
        ),
        color: onPressed != null && !isLoading
            ? GameZoneColors.primaryCyan.withValues(alpha: 0.1)
            : GameZoneColors.surface,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(GameZoneRadius.lg),
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: GameZoneSpacing.lg),
            child: isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: GameZoneColors.primaryCyan,
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null) ...[
                        Icon(
                          icon,
                          size: 20,
                          color: onPressed != null
                              ? GameZoneColors.primaryCyan
                              : GameZoneColors.textMuted,
                        ),
                        const SizedBox(width: GameZoneSpacing.sm),
                      ],
                      Flexible(
                        child: Text(
                          text,
                          style: GameZoneTypography.titleLarge.copyWith(
                            color: onPressed != null
                                ? GameZoneColors.primaryCyan
                                : GameZoneColors.textMuted,
                          ),
                          overflow: TextOverflow.ellipsis,
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

class AuthFooter extends StatelessWidget {
  final String text;
  final String actionText;
  final VoidCallback onActionPressed;

  const AuthFooter({
    super.key,
    required this.text,
    required this.actionText,
    required this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RichText(
        text: TextSpan(
          style: GameZoneTypography.bodyMedium.copyWith(
            color: GameZoneColors.textSecondary,
          ),
          children: [
            TextSpan(text: '$text '),
            WidgetSpan(
              child: GestureDetector(
                onTap: onActionPressed,
                child: ShaderMask(
                  shaderCallback: (bounds) => GameZoneColors.primaryGradient
                      .createShader(bounds),
                  child: Text(
                    actionText,
                    style: GameZoneTypography.titleMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}