import 'package:flutter/material.dart';

const Color _brutalistInk = Colors.black;

BoxDecoration brutalistSurface({
  required ColorScheme colorScheme,
  Color? fill,
  double borderWidth = 3,
  Offset shadowOffset = const Offset(5, 5),
}) {
  return BoxDecoration(
    color: fill ?? colorScheme.surface,
    border: Border.all(color: _brutalistInk, width: borderWidth),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.18),
        offset: shadowOffset,
        blurRadius: 0,
      ),
    ],
  );
}

Widget brutalistPanel({
  required Widget child,
  required ColorScheme colorScheme,
  EdgeInsetsGeometry padding = const EdgeInsets.all(16),
  Color? fill,
  double borderWidth = 3,
  Offset shadowOffset = const Offset(5, 5),
}) {
  return Container(
    decoration: brutalistSurface(
      colorScheme: colorScheme,
      fill: fill,
      borderWidth: borderWidth,
      shadowOffset: shadowOffset,
    ),
    padding: padding,
    child: child,
  );
}

Widget brutalistChip(
  String label, {
  required ColorScheme colorScheme,
  Color? fill,
  Color? textColor,
}) {
  return Container(
    margin: const EdgeInsets.only(right: 8, bottom: 8),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: fill ?? colorScheme.primaryContainer,
      border: Border.all(color: _brutalistInk, width: 2),
    ),
    child: Text(
      label,
      style: TextStyle(
        fontWeight: FontWeight.w900,
        color: textColor ?? _brutalistInk,
      ),
    ),
  );
}

Widget brutalistSectionTitle(
  BuildContext context,
  String title, {
  String? subtitle,
}) {
  final theme = Theme.of(context);
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w900,
          letterSpacing: -0.4,
        ),
      ),
      if (subtitle != null) ...[
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            height: 1.3,
          ),
        ),
      ],
    ],
  );
}

Widget brutalistButton({
  required BuildContext context,
  required String label,
  required VoidCallback onPressed,
  bool filled = true,
  Widget? icon,
}) {
  final colorScheme = Theme.of(context).colorScheme;
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: filled ? colorScheme.primary : colorScheme.surface,
        foregroundColor: filled ? colorScheme.onPrimary : _brutalistInk,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: _brutalistInk, width: 3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            icon,
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

InputDecoration brutalistInputDecoration(
  BuildContext context, {
  String? label,
  String? hint,
  Widget? prefixIcon,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: Theme.of(context).colorScheme.surface,
    border: const OutlineInputBorder(
      borderSide: BorderSide(color: _brutalistInk, width: 3),
      borderRadius: BorderRadius.zero,
    ),
    enabledBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: _brutalistInk, width: 3),
      borderRadius: BorderRadius.zero,
    ),
    focusedBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: _brutalistInk, width: 3),
      borderRadius: BorderRadius.zero,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
    labelStyle: const TextStyle(fontWeight: FontWeight.w700),
    hintStyle: TextStyle(color: Colors.black.withValues(alpha: 0.5)),
  );
}

Widget brutalistStatusPill(
  String label, {
  required ColorScheme colorScheme,
  Color? fill,
  Color? textColor,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: fill ?? colorScheme.secondaryContainer,
      border: Border.all(color: _brutalistInk, width: 2),
    ),
    child: Text(
      label,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w900,
        color: textColor ?? _brutalistInk,
      ),
    ),
  );
}

class BrutalistStatCard extends StatelessWidget {
  const BrutalistStatCard({
    super.key,
    required this.title,
    required this.value,
    this.caption,
    required this.colorScheme,
  });

  final String title;
  final String value;
  final String? caption;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: brutalistPanel(
        colorScheme: colorScheme,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            if (caption != null) ...[
              const SizedBox(height: 6),
              Text(
                caption!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
