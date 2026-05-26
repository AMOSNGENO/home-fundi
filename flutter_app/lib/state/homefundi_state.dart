import 'package:flutter/foundation.dart';

import '../core/storage/token_storage.dart';
import '../features/models/homefundi_models.dart';
import '../features/repositories/auth_repository.dart';
import '../features/repositories/booking_repository.dart';
import '../features/repositories/chat_repository.dart';
import '../features/repositories/payment_repository.dart';
import '../features/repositories/service_repository.dart';
import '../features/repositories/user_repository.dart';

class HomefundiState extends ChangeNotifier {
  HomefundiState({
    AuthRepository? authRepository,
    UserRepository? userRepository,
    ServiceRepository? serviceRepository,
    BookingRepository? bookingRepository,
    ChatRepository? chatRepository,
    PaymentRepository? paymentRepository,
    TokenStorage? tokenStorage,
  })  : _authRepository = authRepository,
        _userRepository = userRepository,
        _serviceRepository = serviceRepository,
        _bookingRepository = bookingRepository,
        _chatRepository = chatRepository,
        _paymentRepository = paymentRepository,
        _tokenStorage = tokenStorage;

  final AuthRepository? _authRepository;
  final UserRepository? _userRepository;
  final ServiceRepository? _serviceRepository;
  final BookingRepository? _bookingRepository;
  final ChatRepository? _chatRepository;
  final PaymentRepository? _paymentRepository;
  final TokenStorage? _tokenStorage;

  bool _initialized = false;
  bool _busy = false;
  String? _errorMessage;
  UserDto? _currentUser;
  AuthSessionDto? _session;

  String _selectedCategory = 'All';
  String? _selectedThreadId;
  String? _selectedBookingId;

  List<ServiceDto> _services = <ServiceDto>[];
  List<BookingDto> _bookings = <BookingDto>[];
  List<ChatThreadDto> _threads = <ChatThreadDto>[];
  final Map<String, List<MessageDto>> _messagesByThread =
      <String, List<MessageDto>>{};
  List<PaymentDto> _payments = <PaymentDto>[];
  List<UserDto> _users = <UserDto>[];

  bool get initialized => _initialized;
  bool get isBusy => _busy;
  String? get errorMessage => _errorMessage;
  UserDto? get currentUser => _currentUser;
  AuthSessionDto? get session => _session;

  String get selectedCategory => _selectedCategory;
  String? get selectedThreadId => _selectedThreadId;
  String? get selectedBookingId => _selectedBookingId;

  List<ServiceDto> get services => List.unmodifiable(_services);
  List<BookingDto> get bookings => List.unmodifiable(_bookings);
  List<ChatThreadDto> get threads => List.unmodifiable(_threads);
  List<PaymentDto> get payments => List.unmodifiable(_payments);
  List<UserDto> get users => List.unmodifiable(_users);

  List<ServiceDto> get filteredServices {
    if (_selectedCategory == 'All') return services;
    return _services
        .where((service) =>
            (service.category ?? '').toLowerCase() ==
            _selectedCategory.toLowerCase())
        .toList(growable: false);
  }

  BookingDto? bookingById(String id) {
    for (final booking in _bookings) {
      if (booking.id == id) return booking;
    }
    return null;
  }

  ChatThreadDto? threadById(String id) {
    for (final thread in _threads) {
      if (thread.id == id) return thread;
    }
    return null;
  }

  List<MessageDto> messagesForThread(String threadId) {
    return List.unmodifiable(
        _messagesByThread[threadId] ?? const <MessageDto>[]);
  }

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    await bootstrap();
  }

  Future<void> bootstrap() async {
    _setBusy(true);
    try {
      await _restoreSession();
      if (_session?.profile != null) {
        _currentUser = _session!.profile;
      } else {
        final repository = _authRepository;
        if (repository != null) {
          _currentUser = await repository.meCached();
          _currentUser ??= await repository.profile(forceRefresh: false);
        }
      }

      await Future.wait<void>(<Future<void>>[
        loadServices(),
        loadBookings(),
        loadThreads(),
        loadPayments(),
        loadUsers(),
      ]);
      _errorMessage = null;
    } catch (error) {
      _errorMessage = error.toString();
      _loadFallbackData();
    } finally {
      _setBusy(false);
    }
  }

  Future<void> refreshProfile() async {
    try {
      final profile = await _authRepository?.profile(forceRefresh: true);
      if (profile != null) {
        _currentUser = profile;
        _errorMessage = null;
        notifyListeners();
      }
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
    }
  }

  Future<AuthSessionDto?> login({
    required String email,
    required String password,
  }) async {
    final repository = _authRepository;
    if (repository == null) return null;

    _setBusy(true);
    try {
      final session = await repository.login(email: email, password: password);
      _session = session;
      _currentUser = session.profile;
      await bootstrap();
      return session;
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
      return null;
    } finally {
      _setBusy(false);
    }
  }

  Future<AuthSessionDto?> register(Map<String, dynamic> payload) async {
    final repository = _authRepository;
    if (repository == null) return null;

    _setBusy(true);
    try {
      final session = await repository.register(payload);
      _session = session;
      _currentUser = session.profile;
      await bootstrap();
      return session;
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
      return null;
    } finally {
      _setBusy(false);
    }
  }

  Future<void> logout() async {
    try {
      await _authRepository?.logout();
    } finally {
      await _tokenStorage?.clear();
      _session = null;
      _currentUser = null;
      _selectedThreadId = null;
      _selectedBookingId = null;
      _messagesByThread.clear();
      notifyListeners();
    }
  }

  Future<void> loadUsers() async {
    try {
      final repository = _userRepository;
      if (repository != null) {
        _users = await repository.list();
      } else {
        _users = _fallbackUsers();
      }
      notifyListeners();
    } catch (error) {
      _users = _fallbackUsers();
      _errorMessage = error.toString();
      notifyListeners();
    }
  }

  Future<void> loadServices({String? category}) async {
    if (category != null) {
      _selectedCategory = category;
    }

    try {
      final repository = _serviceRepository;
      if (repository != null) {
        _services = await repository.list(
          category: category == null || category == 'All' ? null : category,
        );
      } else {
        _services = _fallbackServices();
      }
      notifyListeners();
    } catch (error) {
      _services = _fallbackServices();
      _errorMessage = error.toString();
      notifyListeners();
    }
  }

  Future<void> loadBookings({String? status}) async {
    try {
      final repository = _bookingRepository;
      if (repository != null) {
        _bookings = await repository.list(status: status);
      } else {
        _bookings = _fallbackBookings();
      }

      if (_selectedBookingId == null && _bookings.isNotEmpty) {
        _selectedBookingId = _bookings.first.id;
      }
      notifyListeners();
    } catch (error) {
      _bookings = _fallbackBookings();
      _errorMessage = error.toString();
      notifyListeners();
    }
  }

  Future<void> loadThreads() async {
    try {
      final repository = _chatRepository;
      if (repository != null) {
        _threads = await repository.threads();
      } else {
        _threads = _fallbackThreads();
      }

      if (_selectedThreadId == null && _threads.isNotEmpty) {
        _selectedThreadId = _threads.first.id;
      }
      notifyListeners();
    } catch (error) {
      _threads = _fallbackThreads();
      _errorMessage = error.toString();
      notifyListeners();
    }
  }

  Future<void> loadMessages(String threadId) async {
    _selectedThreadId = threadId;
    try {
      final repository = _chatRepository;
      if (repository != null) {
        _messagesByThread[threadId] = await repository.messages(threadId);
      } else {
        _messagesByThread[threadId] = _fallbackMessages(threadId);
      }
      notifyListeners();
    } catch (error) {
      _messagesByThread[threadId] = _fallbackMessages(threadId);
      _errorMessage = error.toString();
      notifyListeners();
    }
  }

  Future<void> loadPayments() async {
    try {
      final repository = _paymentRepository;
      if (repository != null) {
        _payments = await repository.list();
      } else {
        _payments = _fallbackPayments();
      }
      notifyListeners();
    } catch (error) {
      _payments = _fallbackPayments();
      _errorMessage = error.toString();
      notifyListeners();
    }
  }

  Future<BookingDto?> bookService(Map<String, dynamic> payload) async {
    try {
      final booking = await _bookingRepository?.create(payload);
      if (booking != null) {
        _selectedBookingId = booking.id;
        _bookings = <BookingDto>[
          booking,
          ..._bookings.where((item) => item.id != booking.id)
        ];
        await loadThreads();
        notifyListeners();
      }
      return booking;
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
      return null;
    }
  }

  Future<BookingDto?> updateBookingStatus(
      String bookingId, String status) async {
    try {
      final updated = await _bookingRepository?.updateStatus(bookingId, status);
      if (updated != null) {
        _bookings = _bookings
            .map((item) => item.id == bookingId ? updated : item)
            .toList(growable: false);
        notifyListeners();
      }
      return updated;
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
      return null;
    }
  }

  Future<BookingDto?> confirmBooking(String bookingId) async {
    try {
      final updated = await _bookingRepository?.confirm(bookingId);
      if (updated != null) {
        _bookings = _bookings
            .map((item) => item.id == bookingId ? updated : item)
            .toList(growable: false);
        notifyListeners();
      }
      return updated;
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
      return null;
    }
  }

  Future<BookingDto?> cancelBooking(String bookingId, {String? reason}) async {
    try {
      final updated =
          await _bookingRepository?.cancel(bookingId, reason: reason);
      if (updated != null) {
        _bookings = _bookings
            .map((item) => item.id == bookingId ? updated : item)
            .toList(growable: false);
        notifyListeners();
      }
      return updated;
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
      return null;
    }
  }

  Future<BookingDto?> rateBooking(
    String bookingId, {
    required double rating,
    String? comment,
  }) async {
    try {
      final updated = await _bookingRepository?.rate(
        bookingId,
        rating: rating,
        comment: comment,
      );
      if (updated != null) {
        _bookings = _bookings
            .map((item) => item.id == bookingId ? updated : item)
            .toList(growable: false);
        notifyListeners();
      }
      return updated;
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
      return null;
    }
  }

  Future<BookingDto?> submitOtp({
    required String bookingId,
    required String otp,
  }) async {
    try {
      final updated = await _bookingRepository?.submitOtp(
        bookingId: bookingId,
        otp: otp,
      );
      if (updated != null) {
        _bookings = _bookings
            .map((item) => item.id == bookingId ? updated : item)
            .toList(growable: false);
        notifyListeners();
      }
      return updated;
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
      return null;
    }
  }

  Future<MessageDto?> sendMessage({
    required String threadId,
    required String message,
  }) async {
    try {
      final sent = await _chatRepository?.sendMessage(
          threadId: threadId, message: message);
      if (sent != null) {
        final messages = List<MessageDto>.from(
            _messagesByThread[threadId] ?? const <MessageDto>[]);
        messages.add(sent);
        _messagesByThread[threadId] = messages;
        notifyListeners();
      }
      return sent;
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
      return null;
    }
  }

  Future<PaymentDto?> createPayment(Map<String, dynamic> payload) async {
    try {
      final payment = await _paymentRepository?.create(payload);
      if (payment != null) {
        _payments = <PaymentDto>[
          payment,
          ..._payments.where((item) => item.id != payment.id)
        ];
        notifyListeners();
      }
      return payment;
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
      return null;
    }
  }

  Future<PaymentDto?> verifyPayment(String paymentId, {String? code}) async {
    try {
      final payment = await _paymentRepository?.verify(paymentId, code: code);
      if (payment != null) {
        _payments = _payments
            .map((item) => item.id == paymentId ? payment : item)
            .toList(growable: false);
        notifyListeners();
      }
      return payment;
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
      return null;
    }
  }

  void selectCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void selectBooking(String bookingId) {
    _selectedBookingId = bookingId;
    notifyListeners();
  }

  void selectThread(String threadId) {
    _selectedThreadId = threadId;
    notifyListeners();
  }

  void _setBusy(bool value) {
    _busy = value;
    notifyListeners();
  }

  Future<void> _restoreSession() async {
    final tokenStorage = _tokenStorage;
    if (tokenStorage == null) return;

    final accessToken = await tokenStorage.readAccessToken();
    if (accessToken == null || accessToken.isEmpty) return;

    _session = AuthSessionDto(
      accessToken: accessToken,
      refreshToken: await tokenStorage.readRefreshToken(),
      tokenType: await tokenStorage.readTokenType(),
      expiresAt: await tokenStorage.readExpiresAt(),
      profile: _toUserDto(await tokenStorage.readProfile()),
    );
  }

  UserDto? _toUserDto(Map<String, dynamic>? raw) {
    if (raw == null || raw.isEmpty) return null;
    return UserDto.fromJson(raw);
  }

  void _loadFallbackData() {
    _services = <ServiceDto>[];
    _bookings = <BookingDto>[];
    _threads = <ChatThreadDto>[];
    _payments = <PaymentDto>[];
    _users = <UserDto>[];
    _selectedBookingId = null;
    _selectedThreadId = null;
  }

  List<ServiceDto> _fallbackServices() {
    return <ServiceDto>[];
  }

  List<BookingDto> _fallbackBookings() {
    return <BookingDto>[];
  }

  List<ChatThreadDto> _fallbackThreads() {
    return <ChatThreadDto>[];
  }

  List<MessageDto> _fallbackMessages(String threadId) {
    return <MessageDto>[];
  }

  List<PaymentDto> _fallbackPayments() {
    return <PaymentDto>[];
  }

  List<UserDto> _fallbackUsers() {
    return <UserDto>[];
  }
}
