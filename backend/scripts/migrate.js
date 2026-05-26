const fs = require('fs');
const path = require('path');

const storageDir = path.resolve(__dirname, '..', 'storage');
const dbPath = path.join(storageDir, 'homefundi-db.json');

const emptyDatabase = {
  schemaVersion: 1,
  migratedAt: new Date().toISOString(),
  users: [],
  sessions: [],
  services: [],
  bookings: [],
  chats: [],
  messages: [],
  payments: [],
  reviews: [],
};

fs.mkdirSync(storageDir, { recursive: true });

if (!fs.existsSync(dbPath)) {
  fs.writeFileSync(dbPath, `${JSON.stringify(emptyDatabase, null, 2)}\n`);
  console.log(`Created ${dbPath}`);
  process.exit(0);
}

const current = JSON.parse(fs.readFileSync(dbPath, 'utf8'));
const migrated = { ...emptyDatabase, ...current, schemaVersion: 1, migratedAt: new Date().toISOString() };

for (const key of Object.keys(emptyDatabase)) {
  if (Array.isArray(emptyDatabase[key]) && !Array.isArray(migrated[key])) {
    migrated[key] = [];
  }
}

fs.writeFileSync(dbPath, `${JSON.stringify(migrated, null, 2)}\n`);
console.log(`Migrated ${dbPath}`);
