# Project Structure

## Backend Directories

- `backend/app/` — controllers, models, services, and other application classes
- `backend/bootstrap/` — framework bootstrap files
- `backend/config/` — configuration files
- `backend/database/migrations/` — database migrations
- `backend/database/seeders/` — seeders
- `backend/database/factories/` — model factories
- `backend/routes/api.php` — API route definitions
- `backend/storage/` — application storage

## Conventions

- Use PSR-4 namespaces rooted at `App\\`
- Keep Laravel-specific configuration inside `backend/config/`
- Keep all generated database artifacts inside `backend/database/`