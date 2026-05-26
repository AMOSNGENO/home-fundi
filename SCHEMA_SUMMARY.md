# HOMEFUNDI Database Schema - Creation Summary

## ✅ Files Created Successfully

### 1. **2024_initial_schema.sql** (21,254 characters)
Complete MySQL schema file with all 19 tables and comprehensive indexing strategy.

**Location**: `c:\Users\nkipl\OneDrive\Desktop\artifacts\2024_initial_schema.sql`

**Key Features**:
- ✓ All table creation statements
- ✓ Foreign key relationships and constraints
- ✓ Proper data types and precision
- ✓ Timestamps on all tables (created_at, updated_at)
- ✓ Strategic indexing for performance
- ✓ Soft delete support (deleted_at)
- ✓ Cascade and Set Null deletion rules

---

### 2. **schema_documentation.md** (19,900 characters)
Comprehensive documentation explaining schema design, relationships, and decisions.

**Location**: `c:\Users\nkipl\OneDrive\Desktop\artifacts\schema_documentation.md`

**Contents**:
- ✓ Overview of all 19 tables
- ✓ Design decisions for each table
- ✓ Complete relationship diagram
- ✓ Indexing strategy and rationale
- ✓ Data type precision explanations
- ✓ Security and compliance measures
- ✓ Performance optimization tips
- ✓ Future enhancement suggestions

---

## 📊 Database Schema Overview

### **19 Tables Created**

#### Core Tables (2)
1. **users** - Base identity table for all user roles (customer, technician, admin)
2. **technician_profiles** - Technician-specific data, ratings, availability

#### Service Management (3)
3. **services** - Master service catalog
4. **technician_services** - Many-to-many: which services technicians offer
5. **technician_availability** - Weekly availability time slots

#### Booking Workflow (4)
6. **bookings** - Main booking transactions with status tracking
7. **booking_timeline** - Immutable history of booking status changes
8. **reviews** - Ratings and feedback from customers about technicians
9. **support_tickets** - Customer support issue tracking

#### Messaging & Communication (2)
10. **conversations** - Chat thread management between users
11. **messages** - Individual chat messages with read receipts

#### Payments & Wallet (3)
12. **transactions** - Complete payment history (payments, refunds, earnings)
13. **wallets** - User wallet balance tracking
14. **promo_usage** - Coupon/promotion usage audit trail

#### Promotions (1)
15. **promotions** - Discount codes and promotional offers

#### Admin & Audit (1)
16. **admin_logs** - Complete audit trail of admin actions

#### Notifications (2)
17. **notifications** - User notification records
18. **device_tokens** - Push notification device token management

#### Analytics (1)
19. **rating_breakdown** - Denormalized rating aggregates for performance

---

## 🔑 Key Design Features

### **Role-Based Access**
- Single `users` table with ENUM role discrimination
- Technician-specific fields in separate `technician_profiles` table
- Admin actions tracked in `admin_logs` table

### **Booking Status Lifecycle**
```
pending → accepted → in_progress → completed
                                    ↓
                                (no_show, cancelled)
```

### **Transactions Model**
- Supports multiple payment methods (UPI, card, wallet, cash)
- Separate transaction types (payment, refund, earning, wallet operations)
- Gateway response storage for debugging and compliance

### **Real-Time Features**
- Location tracking (latitude/longitude for technicians and customers)
- Chat with read receipts and media support
- Push notifications with device token management
- Unread message counting via indexed queries

### **Compliance & Auditing**
- Immutable `admin_logs` for regulatory requirements
- Soft deletes with `deleted_at` timestamps
- Complete `booking_timeline` for dispute resolution
- Verification status tracking (Aadhar, bank, background checks)

### **Performance Optimization**
- **19 Strategic Indexes** for common queries
- Denormalized fields (ratings, wallet balance) for fast lookups
- Composite indexes on (foreign_key, filter_column) pairs
- UNIQUE constraints to prevent duplicates

---

## 🚀 How to Deploy

### **Step 1: Execute Schema**
```bash
mysql -u root -p your_database_name < 2024_initial_schema.sql
```

### **Step 2: Verify Creation**
```sql
SHOW TABLES; -- Should show 19 tables
DESCRIBE users; -- Verify columns and types
```

### **Step 3: Create Initial Data**
```sql
-- Insert service categories
INSERT INTO services (name, category, base_price, description) VALUES
('Plumbing Repair', 'plumbing', 500.00, 'General plumbing repairs'),
('Electrical Maintenance', 'electrical', 600.00, 'Electrical work and maintenance'),
('Carpentry', 'carpentry', 700.00, 'Carpentry and woodwork');

-- Create test user
INSERT INTO users (name, email, phone, password_hash, role) VALUES
('John Doe', 'john@example.com', '9876543210', 'bcrypt_hash_here', 'customer');
```

### **Step 4: Test Constraints**
```sql
-- Test foreign key constraint
INSERT INTO bookings (booking_reference, customer_id, service_id, service_date, service_start_time, status)
VALUES ('BK001', 1, 1, '2024-12-20', '10:00:00', 'pending');

-- Test UNIQUE constraint
INSERT INTO technician_availability (technician_id, day_of_week, start_time, end_time)
VALUES (1, 'Monday', '08:00:00', '18:00:00');
```

---

## 📋 Table Reference Quick Guide

| Table | Purpose | Key Fields |
|-------|---------|-----------|
| `users` | All user accounts | id, email, phone, role |
| `technician_profiles` | Technician details | user_id, rating, jobs_completed |
| `services` | Service catalog | id, name, category |
| `bookings` | Service bookings | id, customer_id, technician_id, status |
| `messages` | Chat messages | conversation_id, sender_id, is_read |
| `transactions` | Payments & earnings | user_id, amount, transaction_type |
| `wallets` | User balance | user_id, balance |
| `reviews` | Ratings | booking_id, reviewer_id, rating |
| `admin_logs` | Audit trail | admin_id, action, entity_type |

---

## 🔐 Security Checklist

- ✅ Password fields stored as `password_hash` (never plaintext)
- ✅ Email and phone are UNIQUE (prevent account duplication)
- ✅ Sensitive fields noted for encryption at application layer
- ✅ Immutable audit logs for compliance
- ✅ Verification flags for KYC/compliance
- ✅ Proper foreign key constraints to maintain referential integrity
- ✅ Role-based access control support via `users.role`

---

## 📈 Scalability Considerations

1. **Horizontal Partitioning**: Bookings and messages tables can be partitioned by date
2. **Read Replicas**: Notifications and reviews tables are read-heavy
3. **Caching Strategy**: Cache rating_breakdown and technician availability
4. **Archive Strategy**: Move old bookings and transactions to archive after 2 years

---

## 🆘 Next Steps

1. **Review Documentation**: Read `schema_documentation.md` for detailed design rationale
2. **Customize**: Add any additional fields specific to your requirements
3. **Environment Variables**: Set up database credentials securely
4. **Backup Schedule**: Configure automated daily backups
5. **Monitoring**: Set up query performance monitoring and indexing alerts
6. **Testing**: Write integration tests for critical workflows

---

## 📞 Support Notes

- All timestamps are in server timezone (UTC recommended)
- DECIMAL type used for prices to avoid floating-point precision issues
- GPS coordinates use standard decimal degrees with 8 decimal places (~1.1mm precision)
- All tables use BIGINT UNSIGNED for future scalability (up to 18 quintillion records)

---

**Schema Version**: 2024 Initial Release
**MySQL Version**: 5.7+ (8.0+ recommended)
**Status**: ✅ Production Ready
