-- HOMEFUNDI Mobile App - MySQL Database Schema
-- Complete schema for home services technician booking platform
-- Created: 2024

-- ============================================================================
-- 1. USERS TABLE (Base table for all user roles)
-- ============================================================================
CREATE TABLE users (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL UNIQUE,
  phone VARCHAR(20) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  role ENUM('customer', 'technician', 'admin') NOT NULL DEFAULT 'customer',
  profile_image_url VARCHAR(500),
  location_latitude DECIMAL(10, 8),
  location_longitude DECIMAL(11, 8),
  address VARCHAR(500),
  city VARCHAR(100),
  state VARCHAR(100),
  postal_code VARCHAR(20),
  country VARCHAR(100) DEFAULT 'India',
  is_active BOOLEAN DEFAULT TRUE,
  email_verified BOOLEAN DEFAULT FALSE,
  phone_verified BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP NULL,
  
  INDEX idx_email (email),
  INDEX idx_phone (phone),
  INDEX idx_role (role),
  INDEX idx_city (city),
  INDEX idx_is_active (is_active)
);

-- ============================================================================
-- 2. TECHNICIAN PROFILES TABLE
-- ============================================================================
CREATE TABLE technician_profiles (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL UNIQUE,
  bio TEXT,
  years_of_experience INT DEFAULT 0,
  average_rating DECIMAL(3, 2) DEFAULT 0.00,
  total_reviews INT DEFAULT 0,
  jobs_completed INT DEFAULT 0,
  is_available BOOLEAN DEFAULT TRUE,
  availability_status ENUM('available', 'busy', 'offline', 'on_break') DEFAULT 'offline',
  current_location_latitude DECIMAL(10, 8),
  current_location_longitude DECIMAL(11, 8),
  service_radius_km INT DEFAULT 15,
  aadhar_number VARCHAR(50),
  aadhar_verified BOOLEAN DEFAULT FALSE,
  bank_account_number VARCHAR(50),
  bank_verified BOOLEAN DEFAULT FALSE,
  gst_number VARCHAR(50),
  identity_verified BOOLEAN DEFAULT FALSE,
  background_check_completed BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_average_rating (average_rating),
  INDEX idx_jobs_completed (jobs_completed),
  INDEX idx_is_available (is_available),
  INDEX idx_availability_status (availability_status)
);

-- ============================================================================
-- 3. SERVICES TABLE
-- ============================================================================
CREATE TABLE services (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  category VARCHAR(100) NOT NULL,
  base_price DECIMAL(10, 2),
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  INDEX idx_category (category),
  INDEX idx_is_active (is_active)
);

-- ============================================================================
-- 4. TECHNICIAN SERVICES (Many-to-Many relationship)
-- ============================================================================
CREATE TABLE technician_services (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  technician_id BIGINT UNSIGNED NOT NULL,
  service_id BIGINT UNSIGNED NOT NULL,
  price DECIMAL(10, 2),
  expertise_level ENUM('beginner', 'intermediate', 'expert') DEFAULT 'intermediate',
  is_available BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  UNIQUE KEY unique_tech_service (technician_id, service_id),
  FOREIGN KEY (technician_id) REFERENCES technician_profiles(user_id) ON DELETE CASCADE,
  FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE CASCADE,
  INDEX idx_technician_id (technician_id),
  INDEX idx_service_id (service_id)
);

-- ============================================================================
-- 5. TECHNICIAN AVAILABILITY (Time slots)
-- ============================================================================
CREATE TABLE technician_availability (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  technician_id BIGINT UNSIGNED NOT NULL,
  day_of_week ENUM('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday') NOT NULL,
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  is_available BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (technician_id) REFERENCES technician_profiles(user_id) ON DELETE CASCADE,
  UNIQUE KEY unique_tech_day (technician_id, day_of_week),
  INDEX idx_technician_id (technician_id)
);

-- ============================================================================
-- 6. BOOKINGS TABLE
-- ============================================================================
CREATE TABLE bookings (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  booking_reference VARCHAR(50) NOT NULL UNIQUE,
  customer_id BIGINT UNSIGNED NOT NULL,
  technician_id BIGINT UNSIGNED,
  service_id BIGINT UNSIGNED NOT NULL,
  status ENUM('pending', 'accepted', 'in_progress', 'completed', 'cancelled', 'no_show') DEFAULT 'pending',
  
  -- Service Details
  service_date DATE NOT NULL,
  service_start_time TIME NOT NULL,
  estimated_duration_minutes INT,
  service_end_time TIME,
  
  -- Location Details
  customer_location_latitude DECIMAL(10, 8),
  customer_location_longitude DECIMAL(11, 8),
  service_address VARCHAR(500),
  
  -- Pricing
  base_price DECIMAL(10, 2),
  tax_amount DECIMAL(10, 2) DEFAULT 0.00,
  total_price DECIMAL(10, 2),
  discount_amount DECIMAL(10, 2) DEFAULT 0.00,
  
  -- Customer Notes
  description TEXT,
  
  -- Cancellation Details
  cancellation_reason TEXT,
  cancelled_by ENUM('customer', 'technician', 'system'),
  cancelled_at TIMESTAMP NULL,
  
  -- Tracking
  otp_code VARCHAR(6),
  otp_verified BOOLEAN DEFAULT FALSE,
  
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (customer_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (technician_id) REFERENCES technician_profiles(user_id) ON DELETE SET NULL,
  FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE RESTRICT,
  
  INDEX idx_customer_id (customer_id),
  INDEX idx_technician_id (technician_id),
  INDEX idx_status (status),
  INDEX idx_service_date (service_date),
  INDEX idx_booking_reference (booking_reference),
  INDEX idx_created_at (created_at)
);

-- ============================================================================
-- 7. BOOKING TIMELINE (Status history)
-- ============================================================================
CREATE TABLE booking_timeline (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  booking_id BIGINT UNSIGNED NOT NULL,
  previous_status ENUM('pending', 'accepted', 'in_progress', 'completed', 'cancelled', 'no_show'),
  new_status ENUM('pending', 'accepted', 'in_progress', 'completed', 'cancelled', 'no_show') NOT NULL,
  changed_by BIGINT UNSIGNED,
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE,
  FOREIGN KEY (changed_by) REFERENCES users(id) ON DELETE SET NULL,
  INDEX idx_booking_id (booking_id),
  INDEX idx_created_at (created_at)
);

-- ============================================================================
-- 8. CONVERSATIONS (Chat Threads)
-- ============================================================================
CREATE TABLE conversations (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  booking_id BIGINT UNSIGNED,
  participant_1_id BIGINT UNSIGNED NOT NULL,
  participant_2_id BIGINT UNSIGNED NOT NULL,
  
  last_message_id BIGINT UNSIGNED,
  last_message_time TIMESTAMP NULL,
  last_message_preview VARCHAR(255),
  is_active BOOLEAN DEFAULT TRUE,
  
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE SET NULL,
  FOREIGN KEY (participant_1_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (participant_2_id) REFERENCES users(id) ON DELETE CASCADE,
  
  UNIQUE KEY unique_conversation (participant_1_id, participant_2_id),
  INDEX idx_participant_1_id (participant_1_id),
  INDEX idx_participant_2_id (participant_2_id),
  INDEX idx_updated_at (updated_at)
);

-- ============================================================================
-- 9. MESSAGES (Chat Messages)
-- ============================================================================
CREATE TABLE messages (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  conversation_id BIGINT UNSIGNED NOT NULL,
  sender_id BIGINT UNSIGNED NOT NULL,
  receiver_id BIGINT UNSIGNED NOT NULL,
  
  message_text LONGTEXT,
  message_type ENUM('text', 'image', 'file', 'location', 'quote') DEFAULT 'text',
  media_url VARCHAR(500),
  
  is_read BOOLEAN DEFAULT FALSE,
  read_at TIMESTAMP NULL,
  
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (conversation_id) REFERENCES conversations(id) ON DELETE CASCADE,
  FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (receiver_id) REFERENCES users(id) ON DELETE CASCADE,
  
  INDEX idx_conversation_id (conversation_id),
  INDEX idx_sender_id (sender_id),
  INDEX idx_is_read (is_read),
  INDEX idx_created_at (created_at)
);

-- ============================================================================
-- 10. PAYMENTS & TRANSACTIONS
-- ============================================================================
CREATE TABLE transactions (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  transaction_reference VARCHAR(50) NOT NULL UNIQUE,
  booking_id BIGINT UNSIGNED,
  user_id BIGINT UNSIGNED NOT NULL,
  
  transaction_type ENUM('payment', 'refund', 'wallet_credit', 'wallet_debit', 'earning') NOT NULL,
  payment_method ENUM('credit_card', 'debit_card', 'upi', 'net_banking', 'wallet', 'cash') NOT NULL,
  
  amount DECIMAL(10, 2) NOT NULL,
  currency VARCHAR(3) DEFAULT 'INR',
  status ENUM('pending', 'completed', 'failed', 'refunded') DEFAULT 'pending',
  
  payment_gateway_response LONGTEXT,
  gateway_transaction_id VARCHAR(100),
  
  description TEXT,
  
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE SET NULL,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  
  INDEX idx_user_id (user_id),
  INDEX idx_booking_id (booking_id),
  INDEX idx_status (status),
  INDEX idx_transaction_type (transaction_type),
  INDEX idx_created_at (created_at)
);

-- ============================================================================
-- 11. WALLET (User Wallet Balance)
-- ============================================================================
CREATE TABLE wallets (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL UNIQUE,
  balance DECIMAL(10, 2) DEFAULT 0.00,
  currency VARCHAR(3) DEFAULT 'INR',
  last_transaction_id BIGINT UNSIGNED,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (last_transaction_id) REFERENCES transactions(id) ON DELETE SET NULL,
  INDEX idx_user_id (user_id)
);

-- ============================================================================
-- 12. REVIEWS & RATINGS
-- ============================================================================
CREATE TABLE reviews (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  booking_id BIGINT UNSIGNED NOT NULL UNIQUE,
  reviewer_id BIGINT UNSIGNED NOT NULL,
  reviewee_id BIGINT UNSIGNED NOT NULL,
  
  rating DECIMAL(3, 2) NOT NULL,
  title VARCHAR(255),
  comment TEXT,
  
  cleanliness_rating INT,
  professionalism_rating INT,
  punctuality_rating INT,
  
  is_anonymous BOOLEAN DEFAULT FALSE,
  is_helpful BOOLEAN DEFAULT FALSE,
  
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE,
  FOREIGN KEY (reviewer_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (reviewee_id) REFERENCES users(id) ON DELETE CASCADE,
  
  INDEX idx_booking_id (booking_id),
  INDEX idx_reviewer_id (reviewer_id),
  INDEX idx_reviewee_id (reviewee_id),
  INDEX idx_rating (rating),
  INDEX idx_created_at (created_at)
);

-- ============================================================================
-- 13. ADMIN LOGS (Audit Trail)
-- ============================================================================
CREATE TABLE admin_logs (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  admin_id BIGINT UNSIGNED NOT NULL,
  
  action VARCHAR(100) NOT NULL,
  entity_type VARCHAR(100),
  entity_id BIGINT UNSIGNED,
  
  description TEXT,
  old_values LONGTEXT,
  new_values LONGTEXT,
  
  ip_address VARCHAR(45),
  user_agent VARCHAR(500),
  
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  FOREIGN KEY (admin_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_admin_id (admin_id),
  INDEX idx_action (action),
  INDEX idx_entity_type (entity_type),
  INDEX idx_created_at (created_at)
);

-- ============================================================================
-- 14. PROMOTIONS & COUPONS
-- ============================================================================
CREATE TABLE promotions (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  code VARCHAR(50) NOT NULL UNIQUE,
  description TEXT,
  discount_type ENUM('percentage', 'fixed_amount') NOT NULL,
  discount_value DECIMAL(10, 2) NOT NULL,
  
  max_uses INT,
  current_uses INT DEFAULT 0,
  max_uses_per_user INT DEFAULT 1,
  
  min_booking_amount DECIMAL(10, 2),
  applicable_services JSON,
  
  valid_from DATETIME NOT NULL,
  valid_until DATETIME NOT NULL,
  is_active BOOLEAN DEFAULT TRUE,
  
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  INDEX idx_code (code),
  INDEX idx_is_active (is_active),
  INDEX idx_valid_from (valid_from),
  INDEX idx_valid_until (valid_until)
);

-- ============================================================================
-- 15. PROMO USAGE (Track coupon usage per user)
-- ============================================================================
CREATE TABLE promo_usage (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  promotion_id BIGINT UNSIGNED NOT NULL,
  user_id BIGINT UNSIGNED NOT NULL,
  booking_id BIGINT UNSIGNED NOT NULL,
  
  discount_amount DECIMAL(10, 2),
  used_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  FOREIGN KEY (promotion_id) REFERENCES promotions(id) ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE,
  
  INDEX idx_promotion_id (promotion_id),
  INDEX idx_user_id (user_id),
  INDEX idx_used_at (used_at)
);

-- ============================================================================
-- 16. SUPPORT TICKETS
-- ============================================================================
CREATE TABLE support_tickets (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  ticket_reference VARCHAR(50) NOT NULL UNIQUE,
  user_id BIGINT UNSIGNED NOT NULL,
  booking_id BIGINT UNSIGNED,
  
  subject VARCHAR(255) NOT NULL,
  description TEXT NOT NULL,
  category VARCHAR(100),
  priority ENUM('low', 'medium', 'high', 'urgent') DEFAULT 'medium',
  status ENUM('open', 'in_progress', 'resolved', 'closed') DEFAULT 'open',
  
  assigned_to BIGINT UNSIGNED,
  resolution_notes TEXT,
  
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  resolved_at TIMESTAMP NULL,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE SET NULL,
  FOREIGN KEY (assigned_to) REFERENCES users(id) ON DELETE SET NULL,
  
  INDEX idx_user_id (user_id),
  INDEX idx_status (status),
  INDEX idx_priority (priority),
  INDEX idx_assigned_to (assigned_to),
  INDEX idx_created_at (created_at)
);

-- ============================================================================
-- 17. NOTIFICATIONS
-- ============================================================================
CREATE TABLE notifications (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  
  title VARCHAR(255) NOT NULL,
  description TEXT,
  notification_type VARCHAR(100),
  
  related_entity_type VARCHAR(100),
  related_entity_id BIGINT UNSIGNED,
  
  is_read BOOLEAN DEFAULT FALSE,
  read_at TIMESTAMP NULL,
  
  action_url VARCHAR(500),
  
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_user_id (user_id),
  INDEX idx_is_read (is_read),
  INDEX idx_created_at (created_at)
);

-- ============================================================================
-- 18. DEVICE TOKENS (Push Notifications)
-- ============================================================================
CREATE TABLE device_tokens (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  
  device_token VARCHAR(500) NOT NULL,
  device_type ENUM('ios', 'android', 'web') NOT NULL,
  device_name VARCHAR(255),
  
  app_version VARCHAR(50),
  os_version VARCHAR(50),
  
  is_active BOOLEAN DEFAULT TRUE,
  last_used_at TIMESTAMP NULL,
  
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  UNIQUE KEY unique_device_token (device_token),
  INDEX idx_user_id (user_id),
  INDEX idx_device_type (device_type)
);

-- ============================================================================
-- 19. RATINGS BREAKDOWN (For analytics)
-- ============================================================================
CREATE TABLE rating_breakdown (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  technician_id BIGINT UNSIGNED NOT NULL,
  
  one_star_count INT DEFAULT 0,
  two_star_count INT DEFAULT 0,
  three_star_count INT DEFAULT 0,
  four_star_count INT DEFAULT 0,
  five_star_count INT DEFAULT 0,
  
  total_ratings INT DEFAULT 0,
  average_rating DECIMAL(3, 2) DEFAULT 0.00,
  
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (technician_id) REFERENCES technician_profiles(user_id) ON DELETE CASCADE,
  UNIQUE KEY unique_technician (technician_id),
  INDEX idx_technician_id (technician_id)
);

-- ============================================================================
-- INDEXES ON IMPORTANT QUERIES
-- ============================================================================

-- Composite indexes for common queries
CREATE INDEX idx_booking_status_date ON bookings(status, service_date);
CREATE INDEX idx_booking_customer_date ON bookings(customer_id, service_date);
CREATE INDEX idx_booking_technician_status ON bookings(technician_id, status);

-- For chat queries
CREATE INDEX idx_message_conversation_read ON messages(conversation_id, is_read);
CREATE INDEX idx_message_sender_created ON messages(sender_id, created_at);

-- For transaction queries
CREATE INDEX idx_transaction_user_status ON transactions(user_id, status);
CREATE INDEX idx_transaction_type_date ON transactions(transaction_type, created_at);

-- For availability queries
CREATE INDEX idx_availability_tech_day ON technician_availability(technician_id, day_of_week);

-- For search queries
CREATE INDEX idx_user_city_active ON users(city, is_active);
CREATE INDEX idx_technician_available_rating ON technician_profiles(is_available, average_rating);
