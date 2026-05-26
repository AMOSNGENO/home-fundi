class ApiContract {
  static const String apiPrefix = '/api/v1';

  static const String health = '/health';

  static const String authRegister = '/auth/register';
  static const String authLogin = '/auth/login';
  static const String authLogout = '/auth/logout';
  static const String authRefresh = '/auth/refresh';
  static const String authProfile = '/auth/profile';

  static const String users = '/users';
  static const String services = '/services';
  static const String bookings = '/bookings';
  static const String chats = '/chats';
  static const String reviews = '/reviews';
  static const String payments = '/payments';

  static const String technicianDashboard = '/technician/dashboard';
  static const String technicianBookings = '/technician/bookings';
  static const String technicianAvailability = '/technician/availability';
  static const String technicianEarnings = '/technician/earnings';
  static const String technicianRatings = '/technician/ratings';

  static const String adminDashboard = '/admin/dashboard';
  static const String adminUsers = '/admin/users';
  static const String adminServices = '/admin/services';
  static const String adminPayments = '/admin/payments';

  static String bookingStatus(String bookingId) => '$bookings/$bookingId/status';
  static String bookingConfirm(String bookingId) => '$bookings/$bookingId/confirm';
  static String bookingRate(String bookingId) => '$bookings/$bookingId/rate';
  static String bookingCancel(String bookingId) => '$bookings/$bookingId/cancel';

  static String chatMessages(String threadId) => '$chats/$threadId/messages';
  static String chatThreads() => chats;

  static String paymentVerify(String paymentId) => '$payments/$paymentId/verify';
  static String paymentRefund(String paymentId) => '$payments/$paymentId/refund';

  static String serviceById(String serviceId) => '$services/$serviceId';
  static String userById(String userId) => '$users/$userId';
  static String adminUserById(String userId) => '$adminUsers/$userId';
  static String adminServiceById(String serviceId) => '$adminServices/$serviceId';
}