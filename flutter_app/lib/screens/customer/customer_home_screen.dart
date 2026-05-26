import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../state/homefundi_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/brand_mark.dart';

class CustomerHomeScreen extends StatelessWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<HomefundiState>();
    final userName = state.currentUser?.displayName ?? 'Customer';
    final firstBooking =
        state.bookings.isNotEmpty ? state.bookings.first : null;
    final unreadMessages = state.threads
        .fold<int>(0, (sum, thread) => sum + (thread.unreadCount ?? 0));

    return Scaffold(
      backgroundColor: AppTheme.canvas,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 420;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints:
                    BoxConstraints(minHeight: constraints.maxHeight - 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Header(
                      isCompact: isCompact,
                      userName: userName,
                      serviceCount: state.services.length,
                    ),
                    const SizedBox(height: 16),
                    _QuickActions(
                      isCompact: isCompact,
                      activeBookingId: firstBooking?.id,
                      threadId: state.selectedThreadId ??
                          state.threads.firstOrNull?.id,
                    ),
                    const SizedBox(height: 16),
                    _Panel(
                      title: 'Quick overview',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _OverviewRow(
                            title: 'Bookings',
                            subtitle:
                                '${state.bookings.length} active and past jobs ready to review.',
                            meta: firstBooking?.status?.toUpperCase() ??
                                'NO ACTIVE JOB',
                          ),
                          const SizedBox(height: 12),
                          _OverviewRow(
                            title: 'Messages',
                            subtitle:
                                'Stay in sync with technicians and support.',
                            meta: unreadMessages == 0
                                ? 'ALL READ'
                                : '$unreadMessages UNREAD',
                          ),
                          const SizedBox(height: 12),
                          _OverviewRow(
                            title: 'Services',
                            subtitle:
                                '${state.services.length} services available in the current catalog.',
                            meta: state.selectedCategory,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const _Panel(
                      title: 'How it works',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Bullet(
                              text:
                                  'Choose a service category and describe the job.'),
                          _Bullet(
                              text:
                                  'Review the estimate, pay securely, and share your location.'),
                          _Bullet(
                              text:
                                  'Track the technician and verify the OTP when the work is done.'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _Panel(
                      title: 'Need help fast?',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Welcome, $userName. Open bookings, messages, or tracking to continue where you left off.',
                            style: const TextStyle(fontSize: 14, height: 1.35),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              _NavButton(
                                label: 'Open bookings',
                                onPressed: () => context.go('/tabs/bookings'),
                              ),
                              _NavButton(
                                label: 'Open messages',
                                onPressed: () => context.go('/tabs/messages'),
                              ),
                              _NavButton(
                                label: 'Book a service',
                                onPressed: () =>
                                    context.go('/book/home-repair'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/tabs/home');
              break;
            case 1:
              context.go('/tabs/bookings');
              break;
            case 2:
              context.go('/tabs/messages');
              break;
            case 3:
              context.go('/tabs/profile');
              break;
          }
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.isCompact,
    required this.userName,
    required this.serviceCount,
  });

  final bool isCompact;
  final String userName;
  final int serviceCount;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: 'Homefundi',
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const BrandMark(showWordmark: true),
          const SizedBox(height: 18),
          Text(
            'Hi $userName, book repairs, track progress, and chat with your technician.',
            style: TextStyle(
              fontSize: isCompact ? 20 : 24,
              fontWeight: FontWeight.w900,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'A clean, direct customer flow built for fast booking on narrow phones and wide screens alike.',
            style: TextStyle(fontSize: 14, height: 1.35),
          ),
          const SizedBox(height: 8),
          Text(
            '$serviceCount services ready to browse in the catalog.',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _NavButton(
                label: 'Book a service',
                onPressed: () => context.go('/book/home-repair'),
              ),
              _NavButton(
                label: 'View profile',
                onPressed: () => context.go('/tabs/profile'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.isCompact,
    required this.activeBookingId,
    required this.threadId,
  });

  final bool isCompact;
  final String? activeBookingId;
  final String? threadId;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionTile(
            label: 'Book',
            helper: 'New job',
            onTap: () => context.go('/book/home-repair'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionTile(
            label: 'Track',
            helper: 'Active job',
            onTap: activeBookingId == null
                ? null
                : () => context.go('/tracking/$activeBookingId'),
          ),
        ),
        if (!isCompact) ...[
          const SizedBox(width: 12),
          Expanded(
            child: _ActionTile(
              label: 'Chat',
              helper: 'Support',
              onTap:
                  threadId == null ? null : () => context.go('/chat/$threadId'),
            ),
          ),
        ],
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.label,
    required this.helper,
    required this.onTap,
  });

  final String label;
  final String helper;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 104,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: onTap == null ? const Color(0xFFE7E0CF) : Colors.white,
          border: Border.all(color: AppTheme.ink, width: 2),
          boxShadow: const [
            BoxShadow(
                color: AppTheme.leaf, offset: Offset(4, 4), blurRadius: 0),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label.toUpperCase(),
              style: TextStyle(
                color: onTap == null ? Colors.black45 : AppTheme.ink,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
            Text(
              helper,
              style: TextStyle(
                color: onTap == null ? Colors.black45 : AppTheme.ink,
                fontSize: 13,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.title,
    required this.child,
    this.padding = const EdgeInsets.all(14),
  });

  final String title;
  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppTheme.ink, width: 2),
        boxShadow: const [
          BoxShadow(color: AppTheme.leaf, offset: Offset(4, 4), blurRadius: 0),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _OverviewRow extends StatelessWidget {
  const _OverviewRow({
    required this.title,
    required this.subtitle,
    required this.meta,
  });

  final String title;
  final String subtitle;
  final String meta;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.canvas,
        border: Border.all(color: AppTheme.ink, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.only(top: 4),
            decoration: const BoxDecoration(
                color: AppTheme.leaf, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 15)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: const TextStyle(fontSize: 13, height: 1.25)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            meta.toUpperCase(),
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  ', style: TextStyle(fontSize: 20, height: 1)),
          Expanded(
              child: Text(text,
                  style: const TextStyle(fontSize: 14, height: 1.35))),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.ink,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      child: Text(label.toUpperCase(), textAlign: TextAlign.center),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppTheme.ink,
      unselectedItemColor: Colors.black54,
      backgroundColor: AppTheme.canvas,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
        BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined), label: 'Bookings'),
        BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline), label: 'Messages'),
        BottomNavigationBarItem(
            icon: Icon(Icons.person_outline), label: 'Profile'),
      ],
    );
  }
}

extension _FirstOrNull<E> on List<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
