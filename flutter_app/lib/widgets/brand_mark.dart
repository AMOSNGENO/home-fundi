import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({
    super.key,
    this.size = 44,
    this.showWordmark = false,
  });

  final double size;
  final bool showWordmark;

  @override
  Widget build(BuildContext context) {
    final mark = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppTheme.leaf,
        border: Border.all(color: AppTheme.ink, width: 3),
        boxShadow: const [
          BoxShadow(color: AppTheme.ink, offset: Offset(4, 4), blurRadius: 0),
        ],
      ),
      child: Center(
        child: Text(
          'HF',
          style: TextStyle(
            color: AppTheme.paper,
            fontSize: size * 0.36,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );

    if (!showWordmark) return mark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        const SizedBox(width: 12),
        const Text(
          'HOMEFUNDI',
          style: TextStyle(
            color: AppTheme.accent,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}
