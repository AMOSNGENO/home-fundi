Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, value) => MapEntry(key.toString(), value));
  }
  return <String, dynamic>{};
}

String? _string(dynamic value) {
  if (value == null) return null;
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}

int? _int(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.round();
  return int.tryParse(value.toString());
}

double? _double(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  return double.tryParse(value.toString());
}

bool? _bool(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  final text = value.toString().toLowerCase();
  if (text == 'true' || text == '1' || text == 'yes') return true;
  if (text == 'false' || text == '0' || text == 'no') return false;
  return null;
}

DateTime? _dateTime(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  return DateTime.tryParse(value.toString());
}

List<dynamic> _list(dynamic value) {
  if (value is List) return value;
  return const <dynamic>[];
}

class UserDto {
  const UserDto({
    required this.id,
    this.name,
    this.email,
    this.phone,
    this.role,
    this.avatarUrl,
    this.location,
    this.rating,
    this.completedJobs,
    this.createdAt,
    this.updatedAt,
    this.raw = const <String, dynamic>{},
  });

  final String id;
  final String? name;
  final String? email;
  final String? phone;
  final String? role;
  final String? avatarUrl;
  final String? location;
  final double? rating;
  final int? completedJobs;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic> raw;

  String get displayName => name ?? email ?? id;

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: _string(json['id'] ?? json['user_id']) ?? '',
      name: _string(json['name'] ?? json['full_name'] ?? json['username']),
      email: _string(json['email']),
      phone: _string(json['phone'] ?? json['phone_number']),
      role: _string(json['role'] ?? json['type'] ?? json['user_type']),
      avatarUrl: _string(json['avatar'] ?? json['avatar_url'] ?? json['photo']),
      location: _string(json['location'] ?? json['address'] ?? json['city']),
      rating: _double(json['rating'] ?? json['avg_rating']),
      completedJobs: _int(json['completed_jobs'] ?? json['jobs_completed']),
      createdAt: _dateTime(json['created_at']),
      updatedAt: _dateTime(json['updated_at']),
      raw: json,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        if (name != null) 'name': name,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
        if (role != null) 'role': role,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
        if (location != null) 'location': location,
        if (rating != null) 'rating': rating,
        if (completedJobs != null) 'completed_jobs': completedJobs,
        if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
        if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      };
}

class AuthSessionDto {
  const AuthSessionDto({
    required this.accessToken,
    this.refreshToken,
    this.tokenType,
    this.expiresAt,
    this.profile,
    this.raw = const <String, dynamic>{},
  });

  final String accessToken;
  final String? refreshToken;
  final String? tokenType;
  final DateTime? expiresAt;
  final UserDto? profile;
  final Map<String, dynamic> raw;

  factory AuthSessionDto.fromJson(Map<String, dynamic> json) {
    final payload = _asMap(json['data'] ?? json['result'] ?? json['payload'] ?? json);
    final profileData = payload['user'] ?? payload['profile'];
    return AuthSessionDto(
      accessToken: _string(payload['access_token'] ?? payload['token']) ?? '',
      refreshToken: _string(payload['refresh_token']),
      tokenType: _string(payload['token_type']) ?? 'Bearer',
      expiresAt: _dateTime(payload['expires_at']),
      profile: profileData is Map ? UserDto.fromJson(_asMap(profileData)) : null,
      raw: json,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'access_token': accessToken,
        if (refreshToken != null) 'refresh_token': refreshToken,
        if (tokenType != null) 'token_type': tokenType,
        if (expiresAt != null) 'expires_at': expiresAt!.toIso8601String(),
        if (profile != null) 'user': profile!.toJson(),
      };
}

class ServiceDto {
  const ServiceDto({
    required this.id,
    this.title,
    this.description,
    this.category,
    this.price,
    this.currency,
    this.durationMinutes,
    this.imageUrl,
    this.icon,
    this.isActive,
    this.rating,
    this.location,
    this.raw = const <String, dynamic>{},
  });

  final String id;
  final String? title;
  final String? description;
  final String? category;
  final double? price;
  final String? currency;
  final int? durationMinutes;
  final String? imageUrl;
  final String? icon;
  final bool? isActive;
  final double? rating;
  final String? location;
  final Map<String, dynamic> raw;

  factory ServiceDto.fromJson(Map<String, dynamic> json) {
    return ServiceDto(
      id: _string(json['id'] ?? json['service_id']) ?? '',
      title: _string(json['title'] ?? json['name']),
      description: _string(json['description']),
      category: _string(json['category'] ?? json['service_category']),
      price: _double(json['price'] ?? json['amount']),
      currency: _string(json['currency']) ?? 'TZS',
      durationMinutes: _int(json['duration_minutes'] ?? json['duration']),
      imageUrl: _string(json['image'] ?? json['image_url'] ?? json['photo']),
      icon: _string(json['icon']),
      isActive: _bool(json['is_active'] ?? json['active']),
      rating: _double(json['rating'] ?? json['avg_rating']),
      location: _string(json['location'] ?? json['service_area']),
      raw: json,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (category != null) 'category': category,
        if (price != null) 'price': price,
        if (currency != null) 'currency': currency,
        if (durationMinutes != null) 'duration_minutes': durationMinutes,
        if (imageUrl != null) 'image_url': imageUrl,
        if (icon != null) 'icon': icon,
        if (isActive != null) 'is_active': isActive,
        if (rating != null) 'rating': rating,
        if (location != null) 'location': location,
      };
}

class BookingDto {
  const BookingDto({
    required this.id,
    this.serviceId,
    this.customerId,
    this.technicianId,
    this.serviceName,
    this.status,
    this.scheduledAt,
    this.address,
    this.notes,
    this.amount,
    this.currency,
    this.otpCode,
    this.rating,
    this.createdAt,
    this.updatedAt,
    this.raw = const <String, dynamic>{},
  });

  final String id;
  final String? serviceId;
  final String? customerId;
  final String? technicianId;
  final String? serviceName;
  final String? status;
  final DateTime? scheduledAt;
  final String? address;
  final String? notes;
  final double? amount;
  final String? currency;
  final String? otpCode;
  final double? rating;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic> raw;

  factory BookingDto.fromJson(Map<String, dynamic> json) {
    final embeddedService = json['service'];
    final embeddedServiceName = embeddedService is Map ? _string(_asMap(embeddedService)['name']) : null;

    return BookingDto(
      id: _string(json['id'] ?? json['booking_id']) ?? '',
      serviceId: _string(json['service_id']),
      customerId: _string(json['customer_id'] ?? json['user_id']),
      technicianId: _string(json['technician_id'] ?? json['provider_id']),
      serviceName: _string(json['service_name'] ?? embeddedServiceName),
      status: _string(json['status'] ?? json['state']) ?? 'pending',
      scheduledAt: _dateTime(json['scheduled_at'] ?? json['scheduled_time']),
      address: _string(json['address'] ?? json['location']),
      notes: _string(json['notes'] ?? json['description']),
      amount: _double(json['amount'] ?? json['price']),
      currency: _string(json['currency']) ?? 'TZS',
      otpCode: _string(json['otp_code'] ?? json['otp']),
      rating: _double(json['rating']),
      createdAt: _dateTime(json['created_at']),
      updatedAt: _dateTime(json['updated_at']),
      raw: json,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        if (serviceId != null) 'service_id': serviceId,
        if (customerId != null) 'customer_id': customerId,
        if (technicianId != null) 'technician_id': technicianId,
        if (serviceName != null) 'service_name': serviceName,
        if (status != null) 'status': status,
        if (scheduledAt != null) 'scheduled_at': scheduledAt!.toIso8601String(),
        if (address != null) 'address': address,
        if (notes != null) 'notes': notes,
        if (amount != null) 'amount': amount,
        if (currency != null) 'currency': currency,
        if (otpCode != null) 'otp_code': otpCode,
        if (rating != null) 'rating': rating,
      };
}

class ChatThreadDto {
  const ChatThreadDto({
    required this.id,
    this.bookingId,
    this.customerId,
    this.technicianId,
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCount,
    this.participants = const <UserDto>[],
    this.raw = const <String, dynamic>{},
  });

  final String id;
  final String? bookingId;
  final String? customerId;
  final String? technicianId;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int? unreadCount;
  final List<UserDto> participants;
  final Map<String, dynamic> raw;

  factory ChatThreadDto.fromJson(Map<String, dynamic> json) {
    final participants = _list(json['participants'])
        .whereType<Map>()
        .map((item) => UserDto.fromJson(_asMap(item)))
        .toList(growable: false);

    return ChatThreadDto(
      id: _string(json['id'] ?? json['thread_id']) ?? '',
      bookingId: _string(json['booking_id']),
      customerId: _string(json['customer_id']),
      technicianId: _string(json['technician_id']),
      lastMessage: _string(json['last_message'] ?? json['preview']),
      lastMessageAt: _dateTime(json['last_message_at']),
      unreadCount: _int(json['unread_count']),
      participants: participants,
      raw: json,
    );
  }
}

class MessageDto {
  const MessageDto({
    required this.id,
    this.threadId,
    this.senderId,
    this.senderName,
    this.message,
    this.sentAt,
    this.isMine,
    this.readAt,
    this.raw = const <String, dynamic>{},
  });

  final String id;
  final String? threadId;
  final String? senderId;
  final String? senderName;
  final String? message;
  final DateTime? sentAt;
  final bool? isMine;
  final DateTime? readAt;
  final Map<String, dynamic> raw;

  factory MessageDto.fromJson(Map<String, dynamic> json) {
    final sender = json['sender'];
    final senderName = sender is Map ? _string(_asMap(sender)['name']) : null;

    return MessageDto(
      id: _string(json['id'] ?? json['message_id']) ?? '',
      threadId: _string(json['thread_id']),
      senderId: _string(json['sender_id'] ?? json['user_id']),
      senderName: _string(json['sender_name'] ?? senderName),
      message: _string(json['message'] ?? json['body'] ?? json['text']),
      sentAt: _dateTime(json['sent_at'] ?? json['created_at']),
      isMine: _bool(json['is_mine'] ?? json['mine']),
      readAt: _dateTime(json['read_at']),
      raw: json,
    );
  }
}

class PaymentDto {
  const PaymentDto({
    required this.id,
    this.bookingId,
    this.provider,
    this.method,
    this.amount,
    this.currency,
    this.status,
    this.reference,
    this.transactionId,
    this.paidAt,
    this.verifiedAt,
    this.raw = const <String, dynamic>{},
  });

  final String id;
  final String? bookingId;
  final String? provider;
  final String? method;
  final double? amount;
  final String? currency;
  final String? status;
  final String? reference;
  final String? transactionId;
  final DateTime? paidAt;
  final DateTime? verifiedAt;
  final Map<String, dynamic> raw;

  factory PaymentDto.fromJson(Map<String, dynamic> json) {
    return PaymentDto(
      id: _string(json['id'] ?? json['payment_id']) ?? '',
      bookingId: _string(json['booking_id']),
      provider: _string(json['provider'] ?? json['gateway']),
      method: _string(json['method'] ?? json['payment_method']),
      amount: _double(json['amount']),
      currency: _string(json['currency']) ?? 'TZS',
      status: _string(json['status']),
      reference: _string(json['reference'] ?? json['reference_no']),
      transactionId: _string(json['transaction_id']),
      paidAt: _dateTime(json['paid_at'] ?? json['created_at']),
      verifiedAt: _dateTime(json['verified_at']),
      raw: json,
    );
  }
}

class ReviewDto {
  const ReviewDto({
    required this.id,
    this.bookingId,
    this.userId,
    this.technicianId,
    this.rating,
    this.comment,
    this.createdAt,
    this.raw = const <String, dynamic>{},
  });

  final String id;
  final String? bookingId;
  final String? userId;
  final String? technicianId;
  final double? rating;
  final String? comment;
  final DateTime? createdAt;
  final Map<String, dynamic> raw;

  factory ReviewDto.fromJson(Map<String, dynamic> json) {
    return ReviewDto(
      id: _string(json['id'] ?? json['review_id']) ?? '',
      bookingId: _string(json['booking_id']),
      userId: _string(json['user_id']),
      technicianId: _string(json['technician_id']),
      rating: _double(json['rating']),
      comment: _string(json['comment'] ?? json['review']),
      createdAt: _dateTime(json['created_at']),
      raw: json,
    );
  }
}

class TechnicianAvailabilityDto {
  const TechnicianAvailabilityDto({
    required this.id,
    this.technicianId,
    this.weekday,
    this.startTime,
    this.endTime,
    this.isAvailable,
    this.raw = const <String, dynamic>{},
  });

  final String id;
  final String? technicianId;
  final String? weekday;
  final String? startTime;
  final String? endTime;
  final bool? isAvailable;
  final Map<String, dynamic> raw;

  factory TechnicianAvailabilityDto.fromJson(Map<String, dynamic> json) {
    return TechnicianAvailabilityDto(
      id: _string(json['id'] ?? json['availability_id']) ?? '',
      technicianId: _string(json['technician_id']),
      weekday: _string(json['weekday'] ?? json['day']),
      startTime: _string(json['start_time']),
      endTime: _string(json['end_time']),
      isAvailable: _bool(json['is_available']),
      raw: json,
    );
  }
}

class DashboardSummaryDto {
  const DashboardSummaryDto({
    this.totalBookings,
    this.pendingBookings,
    this.completedBookings,
    this.totalRevenue,
    this.averageRating,
    this.totalUsers,
    this.totalServices,
    this.raw = const <String, dynamic>{},
  });

  final int? totalBookings;
  final int? pendingBookings;
  final int? completedBookings;
  final double? totalRevenue;
  final double? averageRating;
  final int? totalUsers;
  final int? totalServices;
  final Map<String, dynamic> raw;

  factory DashboardSummaryDto.fromJson(Map<String, dynamic> json) {
    return DashboardSummaryDto(
      totalBookings: _int(json['total_bookings']),
      pendingBookings: _int(json['pending_bookings']),
      completedBookings: _int(json['completed_bookings']),
      totalRevenue: _double(json['total_revenue']),
      averageRating: _double(json['average_rating']),
      totalUsers: _int(json['total_users']),
      totalServices: _int(json['total_services']),
      raw: json,
    );
  }
}