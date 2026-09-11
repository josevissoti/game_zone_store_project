import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/design_tokens.dart';

class SearchFilter extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final String hintText;
  final String? initialValue;
  final Duration debounceDuration;

  const SearchFilter({
    super.key,
    required this.onChanged,
    required this.hintText,
    this.initialValue,
    this.debounceDuration = const Duration(milliseconds: 300),
  });

  @override
  State<SearchFilter> createState() => _SearchFilterState();
}

class _SearchFilterState extends State<SearchFilter> {
  late TextEditingController _controller;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onTextChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(widget.debounceDuration, () {
      if (mounted) {
        widget.onChanged(value.trim().toLowerCase());
      }
    });
  }

  void clear() {
    _controller.clear();
    widget.onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: GameZoneSpacing.lg, vertical: GameZoneSpacing.md),
      decoration: BoxDecoration(
        color: GameZoneColors.surface,
        borderRadius: BorderRadius.circular(GameZoneRadius.lg),
        border: Border.all(color: GameZoneColors.border),
      ),
      child: TextField(
        controller: _controller,
        onChanged: _onTextChanged,
        style: GameZoneTypography.bodyMedium.copyWith(color: GameZoneColors.textPrimary),
        cursorColor: GameZoneColors.primaryCyan,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: GameZoneTypography.bodyMedium.copyWith(color: GameZoneColors.textMuted),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(GameZoneSpacing.md),
            child: Icon(
              Icons.search_rounded,
              color: GameZoneColors.textMuted,
              size: 22,
            ),
          ),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear_rounded,
                    color: GameZoneColors.textMuted,
                    size: 22,
                  ),
                  onPressed: () {
                    _controller.clear();
                    _onTextChanged('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: GameZoneSpacing.md,
            vertical: GameZoneSpacing.md,
          ),
        ),
      ),
    );
  }
}