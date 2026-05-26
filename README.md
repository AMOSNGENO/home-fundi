# HOMEFUNDI Mobile App - MySQL Database Schema

Welcome! This directory contains a complete, production-ready MySQL database schema for the HOMEFUNDI home services/technician booking platform.

## 📁 File Structure

```
artifacts/
├── 2024_initial_schema.sql          ⭐ Main Schema File (21 KB)
├── schema_documentation.md          📚 Detailed Design Documentation (20 KB)
├── SCHEMA_SUMMARY.md                📋 Quick Reference & Deployment Guide (8 KB)
├── TABLE_STRUCTURE_REFERENCE.txt    🗂️ Visual Table Structure (15 KB)
├── COMPLETION_REPORT.md             ✅ Project Completion Report (11 KB)
└── README.md                         👈 This file
```

## 🚀 Quick Start

### Option 1: Execute Schema Directly
```bash
mysql -u root -p database_name < 2024_initial_schema.sql
```

### Option 2: Copy-Paste Individual Tables
Open `2024_initial_schema.sql` and execute sections in your MySQL client.

### Verify Installation
```bash
mysql -u root -p database_name -e "SHOW TABLES;"
# Should show 19 tables
```

---

## 📖 Which File Should I Read?

### 🎯 **For Implementation**
→ **Start with `2024_initial_schema.sql`**
- Ready-to-execute SQL file
- All 19 tables defined
- Includes indexes, constraints, foreign keys
- Can be run directly in MySQL

### 🎓 **For Understanding Design**
→ **Read `schema_documentation.md`**
- Explains WHY each table/field exists
- Design decisions and trade-offs
- Security & compliance considerations
- Performance optimization strategies
- Future enhancement suggestions

### ⚡ **For Quick Reference**
→ **Use `SCHEMA_SUMMARY.md`**
- Deployment checklist
- Table count and metrics
- Quick reference table
- Security overview
- Scalability notes

### 🗺️ **For Visual Overview**
→ **View `TABLE_STRUCTURE_REFERENCE.txt`**
- ASCII tree of all 19 tables
- All fields listed with types
- Easy-to-scan format
- Print-friendly

### ✅ **For Project Status**
→ **Review `COMPLETION_REPORT.md`**
- What was delivered
- Design features summary
- Deployment instructions
- Statistics and metrics

---

## 📊 Schema Overview

### **19 Tables Across 8 Categories**

| Category | Tables | Purpose |
|----------|--------|---------|
| **Identity** | users, technician_profiles | User management & roles |
| **Services** | services, technician_services, technician_availability | Service catalog & expertise |
| **Bookings** | bookings, booking_timeline, reviews, support_tickets | Booking workflow & feedback |
| **Messaging** | conversations, messages | Real-time chat |
| **Payments** | transactions, wallets, promo_usage | Payment processing & wallet |
| **Promotions** | promotions | Discount management |
| **Admin** | admin_logs | Compliance audit trail |
| **Notifications** | notifications, device_tokens, rating_breakdown | Push notifications & analytics |

---

## ✨ Key Features

✅ **Role-Based Access** - customer, technician, admin  
✅ **Booking Lifecycle** - pending → accepted → in_progress → completed  
✅ **Real-Time Messaging** - Chat with read receipts and media  
✅ **Payment Processing** - Multiple methods, wallet, transactions  
✅ **Reviews & Ratings** - 5-star system with subcategories  
✅ **Admin Controls** - Audit logs, support tickets, promotions  
✅ **Push Notifications** - Device token management  
✅ **Performance Optimized** - 40+ strategic indexes  
✅ **Compliance Ready** - Soft deletes, audit trails, verification tracking  
✅ **Scalable Design** - BIGINT IDs, denormalization for read performance  

---

## 🔐 Security Features

- ✅ Password hashing support (implement bcrypt/Argon2 at app layer)
- ✅ Email and phone uniqueness (prevent duplicate accounts)
- ✅ Role-based access control
- ✅ Verification tracking (Aadhar, bank, background checks)
- ✅ Immutable audit logs for compliance
- ✅ Soft deletes with timestamp tracking
- ✅ Foreign key constraints for data integrity
- ✅ Payment gateway response logging for dispute resolution

---

## 📈 Performance & Scalability

### Indexes (40+ total)
- Primary keys on all tables (BIGINT UNSIGNED)
- Foreign key indexes for JOIN performance
- Composite indexes on common query patterns:
  - (status, service_date) on bookings
  - (user_id, status) on transactions
  - (conversation_id, is_read) on messages

### Denormalization Strategy
- average_rating cached in technician_profiles
- wallet balance stored directly (no SUM queries)
- rating_breakdown table for analytics caching
- last_message_preview for chat list performance

### Scalability Ready
- BIGINT UNSIGNED IDs (18+ quintillion record capacity)
- DECIMAL for financial precision (no floating-point errors)
- Ready for horizontal partitioning by date
- Support for read replicas on read-heavy tables

---

## 🛠️ Technical Details

### Data Types
```sql
BIGINT UNSIGNED    -- IDs and large numbers
VARCHAR(n)         -- Flexible strings
TEXT/LONGTEXT      -- Rich content
DECIMAL(10,2)      -- Prices (99,999,999.99)
DECIMAL(3,2)       -- Ratings (0.00-9.99)
DECIMAL(10,8)      -- GPS latitude
DECIMAL(11,8)      -- GPS longitude
ENUM               -- Constrained values
BOOLEAN            -- True/false flags
JSON               -- Complex data
TIMESTAMP          -- Auto-managed timestamps
```

### Constraints
- **UNIQUE** on email, phone, booking_reference, codes
- **NOT NULL** on required fields
- **DEFAULT** on timestamps (CURRENT_TIMESTAMP)
- **FOREIGN KEY** with CASCADE or SET NULL
- **ENUM** for restricted value sets
- **PRIMARY KEY** on all tables

---

## 📋 Prerequisites

### Database Requirements
- MySQL 5.7+ (8.0+ recommended)
- InnoDB storage engine (supports foreign keys)
- 100+ MB disk space (for schema and initial data)

### User Privileges
```sql
GRANT ALL PRIVILEGES ON database_name.* TO 'user'@'localhost';
FLUSH PRIVILEGES;
```

---

## 🚀 Deployment Checklist

- [ ] Read `schema_documentation.md` for design understanding
- [ ] Review `2024_initial_schema.sql` for any customizations needed
- [ ] Execute schema: `mysql < 2024_initial_schema.sql`
- [ ] Verify all 19 tables created: `SHOW TABLES;`
- [ ] Test constraints with sample INSERT statements
- [ ] Configure automated daily backups
- [ ] Set up monitoring for query performance
- [ ] Review security settings (password hashing, encryption)
- [ ] Plan table partitioning strategy for production scale
- [ ] Document any customizations made

---

## 🔄 Laravel/PHP Integration

If using Laravel:

```php
// Use Eloquent ORM to map tables
php artisan make:model User
php artisan make:model Booking

// Tables use snake_case (Laravel convention)
// Supports soft deletes: use SoftDeletes trait
// Foreign keys properly defined in schema
```

For migrations, reference `2024_initial_schema.sql` to create Laravel migration files.

---

## 🔄 Node.js/Express Integration

If using Node.js:

```javascript
// Use Sequelize or TypeORM
// Tables ready for ORM mapping
// Foreign keys support eager loading
// ENUM fields map to Sequelize DataTypes.ENUM
```

---

## ❓ FAQ

**Q: Can I customize the schema?**  
A: Yes! Review `schema_documentation.md` first, then update `2024_initial_schema.sql`. Test with sample data before production.

**Q: How do I handle passwords?**  
A: Use bcrypt or Argon2 at the application layer. Store only `password_hash` in the database.

**Q: Should I encrypt sensitive fields?**  
A: Yes. Implement column-level encryption at the application layer for Aadhar, bank account numbers, etc.

**Q: How do I scale this for millions of users?**  
A: Implement read replicas, partition tables by date, use caching (Redis) for frequently accessed data, and implement database sharding if needed.

**Q: What about multi-currency support?**  
A: The schema supports it via `currency` field in `transactions` and `wallets` tables. Implement currency conversion logic at app layer.

**Q: Can I modify table names?**  
A: Yes, but you'll need to update all foreign key references. Recommended: keep table names as designed for consistency.

---

## 📞 Support Notes

### If You Encounter Issues

1. **Foreign Key Constraint Error**: Ensure tables are created in the correct order (base → dependent)
2. **Duplicate Key Error**: Check UNIQUE constraints (email, phone, booking_reference)
3. **Type Mismatch**: Verify ENUM values match those defined in schema
4. **Out of Range**: Use BIGINT UNSIGNED as defined (not INT)

### Best Practices

- Always backup before schema changes
- Test schema changes on development first
- Use transactions for multi-table operations
- Regular backups: daily full + hourly incremental
- Monitor query performance with `EXPLAIN ANALYZE`
- Keep admin_logs and transactions tables separate from user data for archival

---

## 📚 Additional Resources

### For Further Learning
- MySQL Documentation: https://dev.mysql.com/doc/
- Database Design Principles: Check `schema_documentation.md`
- Performance Tuning: See "Performance Optimization" section in documentation

### File Size Summary
- **2024_initial_schema.sql** - 21 KB (Main schema)
- **schema_documentation.md** - 20 KB (Design explanation)
- **SCHEMA_SUMMARY.md** - 8 KB (Quick reference)
- **TABLE_STRUCTURE_REFERENCE.txt** - 15 KB (Visual reference)
- **COMPLETION_REPORT.md** - 11 KB (Project status)
- **README.md** - This file

**Total Documentation**: ~75 KB

---

## 📝 Version Info

**Schema Version**: 2024.1 (Initial Release)  
**Status**: ✅ Production Ready  
**Last Updated**: 2024  
**MySQL Compatibility**: 5.7+  

---

## 🎯 Next Steps

1. **Review** the documentation files above
2. **Execute** `2024_initial_schema.sql` in your MySQL instance
3. **Verify** all 19 tables are created
4. **Test** with sample data
5. **Deploy** to production with proper backups
6. **Monitor** query performance and adjust indexes as needed

---

## 🎉 You're All Set!

The HOMEFUNDI database schema is complete and ready for use. All files are production-ready and thoroughly documented.

**Happy coding! 🚀**

---

*For detailed design decisions and architecture rationale, see `schema_documentation.md`*
