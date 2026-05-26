import 'package:flutter/material.dart';

const Color brutalPaper = Color(0xFFF8F3E8);
const Color brutalSurface = Color(0xFFFFFAEF);
const Color brutalInk = Color(0xFF111111);
const Color brutalAccent = Color(0xFFFFD34E);
const Color brutalMint = Color(0xFF7EE0C0);
const Color brutalSky = Color(0xFFA8D8FF);
const Color brutalPink = Color(0xFFFFA0B8);

class BrutalistPageScaffold extends StatelessWidget {
  const BrutalistPageScaffold({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    this.actions,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: brutalPaper,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 30,
                            height: 0.95,
                            fontWeight: FontWeight.w900,
                            color: brutalInk,
                            letterSpacing: -1.1,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            subtitle!,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.35,
                              fontWeight: FontWeight.w700,
                              color: brutalInk,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (actions != null && actions!.isNotEmpty)
                    Wrap(spacing: 8, runSpacing: 8, children: actions!),
                ],
              ),
            ),
            Expanded(
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}

class BrutalistScrollView extends StatelessWidget {
  const BrutalistScrollView({super.key, required this.children, this.padding});

  final List<Widget> children;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: padding ?? const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class BrutalistCard extends StatelessWidget {
  const BrutalistCard({
    super.key,
    required this.child,
    this.color = brutalSurface,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final Color color;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: brutalInk, width: 3),
        boxShadow: const [
          BoxShadow(
            color: brutalInk,
            offset: Offset(6, 6),
            blurRadius: 0,
          ),
        ],
      ),
      padding: padding,
      child: child,
    );
  }
}

class BrutalistSectionHeader extends StatelessWidget {
  const BrutalistSectionHeader({
    super.key,
    required this.title,
    this.trailing,
    this.subtitle,
  });

  final String title;
  final Widget? trailing;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: brutalInk,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.35,
                      fontWeight: FontWeight.w700,
                      color: brutalInk,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class BrutalistChip extends StatelessWidget {
  const BrutalistChip({
    super.key,
    required this.label,
    this.selected = false,
    this.color,
    this.onTap,
  });

  final String label;
  final bool selected;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final baseColor = color ?? brutalAccent;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? baseColor : brutalSurface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: brutalInk, width: 2.5),
          boxShadow: const [
            BoxShadow(
              color: brutalInk,
              offset: Offset(3, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: brutalInk,
          ),
        ),
      ),
    );
  }
}

class BrutalistStatCard extends StatelessWidget {
  const BrutalistStatCard({
    super.key,
    required this.label,
    required this.value,
    this.color = brutalAccent,
    this.detail,
  });

  final String label;
  final String value;
  final String? detail;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: BrutalistCard(
        color: color,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: brutalInk,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: brutalInk,
              ),
            ),
            if (detail != null) ...[
              const SizedBox(height: 6),
              Text(
                detail!,
                style: const TextStyle(
                  fontSize: 11,
                  height: 1.25,
                  fontWeight: FontWeight.w700,
                  color: brutalInk,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class BrutalistActionButton extends StatelessWidget {
  const BrutalistActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.backgroundColor = brutalAccent,
  });

  final String label;
  final VoidCallback onPressed;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: brutalInk,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: brutalInk, width: 2.5),
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w900,
          letterSpacing: 0.2,
        ),
      ),
      child: Text(label),
    );
  }
}