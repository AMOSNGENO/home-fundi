import 'package:flutter/material.dart';

class BrutalistPanel extends StatelessWidget {
  const BrutalistPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.backgroundColor,
    this.borderColor = Colors.black,
    this.shadowColor = Colors.black,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final Color borderColor;
  final Color shadowColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).colorScheme.surface,
        border: Border.all(color: borderColor, width: 4),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            offset: const Offset(6, 6),
            blurRadius: 0,
          ),
        ],
      ),
      child: child,
    );
  }
}