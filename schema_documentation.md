# HOMEFUNDI Mobile App - MySQL Database Schema Documentation

## Overview
This document describes the comprehensive MySQL database schema designed for the HOMEFUNDI mobile app - a home services/technician booking platform built with React Native and Flutter.

The schema supports three user roles (customers, technicians, and admins) and includes complete functionality for bookings, payments, messaging, ratings, and administrative oversight.

---

## Table Structure & Design Decisions

### 1. **Users Table** (Core identity table)
```sql
users
- id: BIGINT UNSIGNED (Primary Key)
- name, email, phone (unique)
- role: ENUM (customer|technician|admin)
- password_hash: Secure password storage
- Location fields: latitude, longitude, address, city, state, postal_code
- Verification flags: email_verified, phone_verified
- Status: is_active, deleted_at (soft delete support)
- Timestamps: created_at, updated_at
```

**Design Decision**: Single users table with role discrimination allows for efficient authentication and profile management. Soft deletes via `deleted_at` preserve data integrity for auditing.

---

### 2. **Technician Profiles Table**
```sql
technician_profiles
- user_id: BIGINT UNSIGNED (UNIQUE foreign key to users)
- Professional Data:
  - bio, years_of_experience, jobs_completed
  - average_rating (DECIMAL 3,2 for 0-5 star ratings)
  - total_reviews
- Availability:
  - is_available (boolean)
  - availability_status: ENUM (available|busy|offline|on_break)
  - current_location_latitude/longitude (real-time tracking)
  - service_radius_km (service area)
- Verification & Compliance:
  - aadhar_number, aadhar_verified
  - bank_account_number, bank_verified
  - gst_number, identity_verified
  - background_check_completed
```

**Design Decision**: Separate table keeps technician-specific data modular. Real-time location tracking enables proximity-based job matching. Verification fields support regulatory compliance.

---

### 3. **Services Table**
```sql
services
- id: BIGINT UNSIGNED (Primary Key)
- name, description
- category: VARCHAR(100) - searchable service categories
- base_price: Default pricing
- is_active: Soft availability toggle
```

**Design Decision**: Master service catalog allows platform-wide service management with base pricing that technicians can customize.

---

### 4. **Technician Services** (Many-to-Many)
```sql
technician_services
- technician_id → technician_profiles.user_id
- service_id → services.id
- price: Technician-specific pricing override
- expertise_level: ENUM (beginner|intermediate|expert)
- is_available: Per-service availability
- UNIQUE constraint: (technician_id, service_id)
```

**Design Decision**: Allows flexible pricing and expertise specification per technician per service. Composite unique key prevents duplicates.

---

### 5. **Technician Availability** (Time slots)
```sql
technician_availability
- technician_id → technician_profiles.user_id
- day_of_week: ENUM (Monday-Sunday)
- start_time, end_time: TIME fields
- is_available: Boolean toggle
- UNIQUE constraint: (technician_id, day_of_week)
```

**Design Decision**: Weekly recurring availability reduces data volume vs. daily slots. Customers see standardized availability patterns. Real-time updates via `availability_status` in technician_profiles.

---

### 6. **Bookings Table** (Core transaction table)
```sql
bookings
- id: BIGINT UNSIGNED (Primary Key)
- booking_reference: VARCHAR(50) UNIQUE - customer-facing ID
- customer_id → users.id
- technician_id → technician_profiles.user_id (nullable until accepted)
- service_id → services.id
- Status: ENUM (pending|accepted|in_progress|completed|cancelled|no_show)

Service Details:
- service_date, service_start_time, estimated_duration_minutes
- service_end_time: Tracked on completion
- customer_location_latitude/longitude, service_address

Pricing:
- base_price, tax_amount, total_price, discount_amount

Tracking:
- otp_code, otp_verified (OTP-based verification at service)
- cancellation_reason, cancelled_by, cancelled_at

Indexes:
- (status, service_date) - for finding available services
- (customer_id, service_date) - customer history
- (technician_id, status) - technician workload
```

**Design Decision**: 
- Status lifecycle: pending → accepted → in_progress → completed (or cancelled)
- `no_show` status for tracking missed appointments
- Separate `booking_timeline` table tracks all status transitions for analytics
- Location stored at booking time for accuracy; real-time tracking elsewhere
- OTP verification adds security layer to booking completion

---

### 7. **Booking Timeline Table** (Audit trail)
```sql
booking_timeline
- booking_id → bookings.id
- previous_status → new_status: Track all transitions
- changed_by → users.id: WHO made the change
- notes: WHY the change occurred
- created_at: TIMESTAMP
```

**Design Decision**: Immutable log enables historical analysis, dispute resolution, and compliance auditing.

---

### 8. **Conversations Table** (Chat threads)
```sql
conversations
- booking_id → bookings.id (nullable - conversations can exist outside bookings)
- participant_1_id, participant_2_id → users.id
- UNIQUE constraint: (participant_1_id, participant_2_id) - prevents duplicate conversations

Metadata:
- last_message_id → messages.id
- last_message_time, last_message_preview (denormalized for UI efficiency)
- is_active: Soft deletion
```

**Design Decision**: 
- Unique constraint on participant pair prevents duplicate threads
- Denormalized last message data speeds up chat list rendering
- Nullable booking_id allows customer service conversations outside bookings

---

### 9. **Messages Table** (Chat messages)
```sql
messages
- conversation_id → conversations.id
- sender_id, receiver_id → users.id
- message_text: LONGTEXT for rich content
- message_type: ENUM (text|image|file|location|quote)
- media_url: For image/file attachments
- is_read, read_at: Read receipts
- Indexes: (conversation_id, is_read) - for unread count

Design Pattern: Read receipts support real-time delivery notifications
```

**Design Decision**: Flexible message types support multimedia messaging. `is_read` + `read_at` enables modern chat UX with read indicators.

---

### 10. **Transactions Table** (Payment & earnings)
```sql
transactions
- transaction_reference: VARCHAR(50) UNIQUE - external tracking ID
- booking_id → bookings.id (nullable - transactions can occur outside bookings)
- user_id → users.id
- transaction_type: ENUM (payment|refund|wallet_credit|wallet_debit|earning)
- payment_method: ENUM (credit_card|debit_card|upi|net_banking|wallet|cash)
- amount, currency: DECIMAL(10,2) for accuracy
- status: ENUM (pending|completed|failed|refunded)
- payment_gateway_response: LONGTEXT - raw gateway response for debugging
- gateway_transaction_id: External payment provider reference

Indexes:
- (user_id, status) - user financial history
- (transaction_type, created_at) - reporting
```

**Design Decision**: 
- Separate table from bookings allows multiple payments per booking (partial, refunds, tips)
- Immutable transaction log preserves compliance records
- Gateway response stored for dispute resolution
- `wallet_credit` and `wallet_debit` transactions enable wallet-based payments

---

### 11. **Wallets Table** (User account balance)
```sql
wallets
- user_id → users.id (UNIQUE)
- balance: DECIMAL(10,2) - current wallet balance
- currency: VARCHAR(3) - INR, USD, etc.
- last_transaction_id → transactions.id
```

**Design Decision**: Denormalized wallet balance (instead of SUM queries) enables fast balance lookups. `last_transaction_id` tracks recent activity.

---

### 12. **Reviews Table** (Ratings & feedback)
```sql
reviews
- booking_id → bookings.id (UNIQUE - one review per booking)
- reviewer_id, reviewee_id → users.id
- rating: DECIMAL(3,2) - 0.00 to 5.00
- title, comment: Review text
- Subcategory ratings: cleanliness_rating, professionalism_rating, punctuality_rating
- is_anonymous: Privacy option
- is_helpful: Community voting on review usefulness
- Index on reviewee_id for profile ratings aggregation
```

**Design Decision**: 
- UNIQUE booking_id prevents duplicate reviews
- Subcategory ratings provide detailed feedback for technician improvement
- Separate from ratings_breakdown table (denormalized aggregates)
- Supports both customer→technician and technician→customer reviews

---

### 13. **Admin Logs Table** (Audit trail for compliance)
```sql
admin_logs
- admin_id → users.id
- action: VARCHAR(100) - action name (e.g., 'suspend_user', 'refund_booking')
- entity_type, entity_id: What was changed (e.g., 'booking', 123)
- description, old_values, new_values: Change details (JSON/serialized)
- ip_address, user_agent: Audit context
- created_at: Immutable timestamp
```

**Design Decision**: Comprehensive admin audit trail enables compliance with regulations (data protection, fraud prevention). Never updated or deleted.

---

### 14. **Promotions Table** (Discount management)
```sql
promotions
- code: VARCHAR(50) UNIQUE - promo code (e.g., "SAVE10")
- discount_type: ENUM (percentage|fixed_amount)
- discount_value: DECIMAL(10,2)
- max_uses, current_uses: Global usage limits
- max_uses_per_user: Per-user limit
- min_booking_amount: Minimum booking value to use
- applicable_services: JSON - array of service IDs (null = all services)
- valid_from, valid_until: Time-based validity
- is_active: Soft activation toggle
```

**Design Decision**: JSON field for applicable_services allows complex targeting without separate table. Denormalized `current_uses` speeds up availability checks.

---

### 15. **Promo Usage Table** (Coupon audit)
```sql
promo_usage
- promotion_id → promotions.id
- user_id → users.id
- booking_id → bookings.id
- discount_amount: DECIMAL(10,2)
- used_at: TIMESTAMP
```

**Design Decision**: Tracks every coupon use for analytics, fraud detection, and per-user limit enforcement.

---

### 16. **Support Tickets Table** (Customer support)
```sql
support_tickets
- ticket_reference: VARCHAR(50) UNIQUE - customer-facing ticket ID
- user_id → users.id
- booking_id → bookings.id (optional - might not relate to specific booking)
- subject, description, category
- priority: ENUM (low|medium|high|urgent)
- status: ENUM (open|in_progress|resolved|closed)
- assigned_to → users.id (admin staff)
- resolution_notes: Admin response
- created_at, resolved_at: SLA tracking
```

**Design Decision**: Separate from messages for structured support workflow. Status tracking enables SLA management and reporting.

---

### 17. **Notifications Table** (User notifications)
```sql
notifications
- user_id → users.id
- title, description: Notification content
- notification_type: VARCHAR(100) - categorization (booking_accepted, payment_received, etc.)
- related_entity_type, related_entity_id: Link to relevant entity
- is_read, read_at: Read status
- action_url: Deep link for mobile app
```

**Design Decision**: Persistent notification record enables history view. Separate from device tokens (which are ephemeral). `is_read` + `read_at` tracks user engagement.

---

### 18. **Device Tokens Table** (Push notification infrastructure)
```sql
device_tokens
- user_id → users.id
- device_token: VARCHAR(500) UNIQUE - FCM/APNs token
- device_type: ENUM (ios|android|web)
- device_name, app_version, os_version: Device metadata
- is_active: User can disable notifications
- last_used_at: Track active devices
```

**Design Decision**: 
- UNIQUE constraint prevents duplicate tokens
- Ephemeral data (expires if app uninstalls)
- Separate from notifications (which are persistent)
- Device metadata enables targeted push messaging

---

### 19. **Rating Breakdown Table** (Analytics cache)
```sql
rating_breakdown
- technician_id → technician_profiles.user_id (UNIQUE)
- one_star_count through five_star_count: Rating distribution
- total_ratings: Denormalized for faster queries
- average_rating: DECIMAL(3,2) - cached average
```

**Design Decision**: Denormalized aggregation table prevents expensive SUM queries on the reviews table. Updated via triggers or batch jobs. Enables fast technician ranking/filtering.

---

## Key Relationships Overview

```
Users (base)
├── Technician Profiles (1:0..1)
│   ├── Technician Services (1:N) → Services
│   ├── Technician Availability (1:N)
│   ├── Reviews (N:N via reviewer/reviewee)
│   ├── Rating Breakdown (1:1)
│   └── Bookings (1:N as technician)
│
├── Conversations (N:N with other users)
│   └── Messages (1:N)
│
├── Bookings (N:M, many as customer)
│   ├── Booking Timeline (1:N)
│   ├── Transactions (1:N)
│   ├── Reviews (1:0..1)
│   ├── Support Tickets (1:N)
│   └── Promo Usage (1:N)
│
├── Transactions (N:M)
│   └── Wallets (related via user_id)
│
├── Admin Logs (1:N for admins)
│
├── Notifications (1:N)
├── Device Tokens (1:N)
└── Support Tickets (1:N for issue reporters)
```

---

## Indexing Strategy

### High-Priority Indexes (included)
1. **Booking Search**
   - `(status, service_date)` - find available services
   - `(customer_id, service_date)` - customer booking history
   - `(technician_id, status)` - technician workload

2. **Chat Optimization**
   - `(conversation_id, is_read)` - unread message count
   - `(sender_id, created_at)` - user message history

3. **Payment Queries**
   - `(user_id, status)` - user transaction history
   - `(transaction_type, created_at)` - earnings reports

4. **Technician Discovery**
   - `(is_available, average_rating)` - find top available technicians
   - `(city, is_active)` - location-based search

5. **Temporal Analysis**
   - `(created_at)` on high-frequency tables
   - `(updated_at)` on conversations

---

## Data Types & Precision

### Numeric Precision
- **Ratings**: `DECIMAL(3,2)` - allows 0.00 to 9.99 (sufficient for 0-5 stars with decimals)
- **Prices/Amounts**: `DECIMAL(10,2)` - allows up to 99,999,999.99 (sufficient for INR)
- **Coordinates**: `DECIMAL(10,8)` latitude, `DECIMAL(11,8)` longitude - GPS accuracy to ~1.1mm

### Text Fields
- **VARCHAR(255)**: Standard for names, emails, phone numbers
- **VARCHAR(500)**: URLs and longer strings
- **VARCHAR(50)**: Codes, references, references
- **LONGTEXT**: Rich content (messages, API responses, notes)

### Timestamps
- `CURRENT_TIMESTAMP` default for automatic server-side timestamps
- `ON UPDATE CURRENT_TIMESTAMP` for tracking modifications
- Supports historical analysis and compliance auditing

---

## Soft Deletes & Data Retention

1. **Soft Deletes**: `deleted_at` column on `users` table
   - Preserves referential integrity
   - Enables data recovery
   - Supports compliance requirements

2. **Cascade Deletes**: Used where appropriate
   - `technician_profiles` CASCADE when user deleted
   - `messages` CASCADE when conversation deleted
   - Keeps database clean when entities truly removed

3. **Set Null**: Used for references to optional owners
   - `technician_id` in bookings becomes NULL if technician deleted
   - `assigned_to` in support tickets becomes NULL if admin deleted
   - Preserves booking/ticket record while removing user reference

---

## Performance Considerations

### Query Optimization
- Composite indexes on frequently joined/filtered column pairs
- `BIGINT UNSIGNED` for scalability (up to 18 quintillion records)
- Denormalized fields (last_message_preview, average_rating) reduce query complexity

### Scalability Strategy
1. **Horizontal Partitioning**: Tables like `bookings`, `messages` can be partitioned by date
2. **Read Replicas**: Heavy read tables (reviews, notifications) can be replicated
3. **Caching Layer**: Redis/Memcached for frequently accessed data (ratings, availability)

### Indexes to Consider Later (if scale requires)
- Partial indexes on active bookings (PostgreSQL feature)
- Full-text search indexes on messages and support tickets
- Geospatial indexes on location coordinates (MySQL 5.7+)

---

## Security & Compliance

1. **Password Storage**
   - `password_hash`: Never store plaintext passwords
   - Use bcrypt/Argon2 with salts

2. **Verification Workflow**
   - `aadhar_verified`, `bank_verified`, `identity_verified`: Track compliance
   - `background_check_completed`: For technician vetting
   - `email_verified`, `phone_verified`: Two-factor trust

3. **Audit Trail**
   - `admin_logs`: Complete history of admin actions
   - `booking_timeline`: Dispute resolution records
   - `transactions`: Immutable payment history

4. **Sensitive Data**
   - `aadhar_number`, `bank_account_number`: Encrypt at application layer (not shown in schema)
   - Implement column-level encryption in production
   - Mask sensitive fields in API responses

---

## Migration Path & Constraints

### Foreign Key Constraints
- All relationships properly defined
- `ON DELETE CASCADE`: Cleanup dependent records
- `ON DELETE SET NULL`: Preserve parent records but remove child references
- `ON DELETE RESTRICT`: Prevent deletion if child records exist (e.g., services)

### Execution Order for Creation
1. Create base table: `users`
2. Create role-specific tables: `technician_profiles`, `services`
3. Create junction tables: `technician_services`, `technician_availability`
4. Create transaction tables: `bookings`, `conversations`, `messages`, `transactions`, `wallets`
5. Create dependent tables: `reviews`, `booking_timeline`, `admin_logs`, etc.
6. Create all indexes

### Backup & Recovery
- Regular snapshots of `admin_logs` and `transactions` tables for compliance
- Point-in-time recovery enabled via binary logs
- Backup schedule: Daily full + Hourly incremental

---

## Future Enhancements

1. **Advanced Scheduling**
   - Add `recurring_booking` table for subscription-based services
   - Add `preferred_technician_id` to bookings for loyalty

2. **Analytics**
   - Add `booking_analytics` table for dashboard metrics
   - Add `technician_analytics` for performance tracking

3. **Geographic Features**
   - Implement GIS queries for service area optimization
   - Add `service_area_polygon` table for complex coverage areas

4. **Multilingual Support**
   - Add `language_code` to users table
   - Create `translations` table for service names, reviews

5. **AI/ML Features**
   - Add `demand_prediction` table for surge pricing
   - Add `technician_recommendation_logs` for algorithm auditing

---

## Summary of Table Count

**Total Tables: 19**
- Core: 1 (users)
- Technician: 4 (technician_profiles, technician_services, technician_availability, rating_breakdown)
- Services: 1 (services)
- Booking Workflow: 4 (bookings, booking_timeline, reviews, support_tickets)
- Messaging: 2 (conversations, messages)
- Payments: 3 (transactions, wallets, promo_usage)
- Promotions: 1 (promotions)
- Admin/Audit: 1 (admin_logs)
- Notifications: 2 (notifications, device_tokens)

---

## How to Use This Schema

1. **MySQL 5.7+**: Copy the `2024_initial_schema.sql` file into your database
2. **Execute**: `mysql -u root -p your_database_name < 2024_initial_schema.sql`
3. **Verify**: Check that all 19 tables are created: `SHOW TABLES;`
4. **Test**: Run sample INSERT statements to ensure foreign key constraints work
5. **Backup**: Create regular backups before enabling production traffic

---

This schema is production-ready and supports the full feature set of the HOMEFUNDI platform while maintaining scalability, performance, and compliance requirements.
