import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/network/api_client.dart';
import 'core/storage/token_storage.dart';
import 'features/repositories/auth_repository.dart';
import 'features/repositories/booking_repository.dart';
import 'features/repositories/chat_repository.dart';
import 'features/repositories/payment_repository.dart';
import 'features/repositories/service_repository.dart';
import 'features/repositories/user_repository.dart';
import 'screens/customer/customer_screens.dart';
import 'state/homefundi_state.dart';
import 'theme/app_theme.dart';

class HomefundiApp extends StatefulWidget {
  const HomefundiApp({super.key});

  @override
  State<HomefundiApp> createState() => _HomefundiAppState();
}

class _HomefundiAppState extends State<HomefundiApp> {
  late final TokenStorage _tokenStorage;
  late final ApiClient _apiClient;
  late final AuthRepository _authRepository;
  late final UserRepository _userRepository;
  late final ServiceRepository _serviceRepository;
  late final BookingRepository _bookingRepository;
  late final ChatRepository _chatRepository;
  late final PaymentRepository _paymentRepository;
  late final HomefundiState _homefundiState;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _tokenStorage = TokenStorage();
    _apiClient = ApiClient(tokenStorage: _tokenStorage);
    _authRepository =
        AuthRepository(apiClient: _apiClient, tokenStorage: _tokenStorage);
    _userRepository = UserRepository(_apiClient);
    _serviceRepository = ServiceRepository(_apiClient);
    _bookingRepository = BookingRepository(_apiClient);
    _chatRepository = ChatRepository(_apiClient);
    _paymentRepository = PaymentRepository(_apiClient);
    _homefundiState = HomefundiState(
      authRepository: _authRepository,
      userRepository: _userRepository,
      serviceRepository: _serviceRepository,
      bookingRepository: _bookingRepository,
      chatRepository: _chatRepository,
      paymentRepository: _paymentRepository,
      tokenStorage: _tokenStorage,
    )..initialize();
    _router = _buildRouter(_homefundiState);
  }

  @override
  void dispose() {
    _router.dispose();
    _homefundiState.dispose();
    _apiClient.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<HomefundiState>.value(value: _homefundiState),
      ],
      child: MaterialApp.router(
        title: 'Homefundi',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: _router,
        scrollBehavior: const _HomefundiScrollBehavior(),
        builder: (context, child) {
          final content = child ?? const SizedBox.shrink();

          return LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = constraints.maxWidth;
              final useCenteredShell = maxWidth >= 1200;
              final responsiveContent = useCenteredShell
                  ? Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: content,
                      ),
                    )
                  : content;

              return ColoredBox(
                color: AppTheme.canvas,
                child: SafeArea(
                  top: false,
                  child: responsiveContent,
                ),
              );
            },
          );
        },
      ),
    );
  }

  GoRouter _buildRouter(HomefundiState state) {
    return GoRouter(
      initialLocation: '/auth',
      refreshListenable: state,
      redirect: (_, routerState) {
        final isAuthRoute = routerState.matchedLocation == '/auth';
        final hasToken = state.session?.accessToken.isNotEmpty == true;
        final loggedIn = state.currentUser != null || hasToken;

        if (!state.initialized) return null;
        if (!loggedIn && !isAuthRoute) return '/auth';
        if (loggedIn && isAuthRoute) return '/tabs/home';
        return null;
      },
      routes: [
        GoRoute(
          path: '/',
          redirect: (_, __) => '/tabs/home',
        ),
        GoRoute(
          path: '/auth',
          builder: (_, __) => const AuthScreen(),
        ),
        GoRoute(
          path: '/tabs/home',
          builder: (_, __) => const CustomerHomeScreen(),
        ),
        GoRoute(
          path: '/tabs/bookings',
          builder: (_, __) => const BookingsScreen(),
        ),
        GoRoute(
          path: '/tabs/messages',
          builder: (_, __) => const MessagesScreen(),
        ),
        GoRoute(
          path: '/tabs/profile',
          builder: (_, __) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/book/:category',
          builder: (context, state) => BookServiceScreen(
            category: state.pathParameters['category'],
          ),
        ),
        GoRoute(
          path: '/payment/:bookingId',
          builder: (context, state) => PaymentScreen(
            bookingId: state.pathParameters['bookingId'],
          ),
        ),
        GoRoute(
          path: '/tracking/:bookingId',
          builder: (context, state) => TrackingScreen(
            bookingId: state.pathParameters['bookingId'],
          ),
        ),
        GoRoute(
          path: '/otp/:bookingId',
          builder: (context, state) => OtpVerificationScreen(
            bookingId: state.pathParameters['bookingId'],
          ),
        ),
        GoRoute(
          path: '/chat/:threadId',
          builder: (context, state) => ChatRoomScreen(
            threadId: state.pathParameters['threadId'],
            title: state.uri.queryParameters['title'],
          ),
        ),
      ],
    );
  }
}

class _HomefundiScrollBehavior extends MaterialScrollBehavior {
  const _HomefundiScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => <PointerDeviceKind>{
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.unknown,
      };
}
