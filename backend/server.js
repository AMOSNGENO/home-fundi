const crypto = require('crypto');
const fs = require('fs');
const http = require('http');
const path = require('path');
const { URL } = require('url');

const storageDir = path.resolve(__dirname, 'storage');
const dbPath = path.join(storageDir, 'homefundi-db.json');
const port = Number(process.env.PORT || process.argv[2] || 8000);

function now() {
  return new Date().toISOString();
}

function id(prefix) {
  return `${prefix}_${crypto.randomBytes(8).toString('hex')}`;
}

function ensureDatabase() {
  if (!fs.existsSync(dbPath)) {
    fs.mkdirSync(storageDir, { recursive: true });
    fs.writeFileSync(dbPath, `${JSON.stringify({
      schemaVersion: 1,
      migratedAt: now(),
      users: [],
      sessions: [],
      services: [],
      bookings: [],
      chats: [],
      messages: [],
      payments: [],
      reviews: [],
    }, null, 2)}\n`);
  }
}

function readDb() {
  ensureDatabase();
  return JSON.parse(fs.readFileSync(dbPath, 'utf8'));
}

function writeDb(db) {
  fs.mkdirSync(storageDir, { recursive: true });
  fs.writeFileSync(dbPath, `${JSON.stringify(db, null, 2)}\n`);
}

function send(response, statusCode, payload) {
  response.writeHead(statusCode, {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'Authorization, Content-Type',
    'Access-Control-Allow-Methods': 'GET, POST, PUT, PATCH, DELETE, OPTIONS',
    'Content-Type': 'application/json',
  });
  response.end(JSON.stringify(payload));
}

function body(request) {
  return new Promise((resolve) => {
    let raw = '';
    request.on('data', (chunk) => {
      raw += chunk;
    });
    request.on('end', () => {
      try {
        resolve(raw ? JSON.parse(raw) : {});
      } catch {
        resolve({});
      }
    });
  });
}

function bearer(request) {
  const header = request.headers.authorization || '';
  const match = header.match(/^Bearer\s+(.+)$/i);
  return match ? match[1] : null;
}

function currentUser(db, request) {
  const token = bearer(request);
  const session = token ? db.sessions.find((item) => item.access_token === token) : null;
  return session ? db.users.find((user) => user.id === session.user_id) : null;
}

function publicUser(user) {
  if (!user) return null;
  const { password, ...safe } = user;
  return safe;
}

function collection(response, key, items) {
  send(response, 200, { [key]: items, data: items });
}

function notFound(response) {
  send(response, 404, { message: 'Not found' });
}

async function route(request, response) {
  if (request.method === 'OPTIONS') {
    send(response, 204, {});
    return;
  }

  const url = new URL(request.url, `http://${request.headers.host}`);
  const pathname = url.pathname.replace(/^\/api\/v1/, '') || '/';
  const db = readDb();

  if (pathname === '/health') {
    send(response, 200, { ok: true, schema_version: db.schemaVersion });
    return;
  }

  if (pathname === '/auth/register' && request.method === 'POST') {
    const payload = await body(request);
    const email = String(payload.email || '').trim().toLowerCase();
    if (!email || !payload.password || !payload.name) {
      send(response, 422, { message: 'Name, email, and password are required.' });
      return;
    }
    if (db.users.some((user) => user.email === email)) {
      send(response, 422, { message: 'Email is already registered.' });
      return;
    }
    const user = {
      id: id('usr'),
      name: String(payload.name).trim(),
      email,
      phone: payload.phone || null,
      role: payload.role || 'customer',
      password: String(payload.password),
      created_at: now(),
      updated_at: now(),
    };
    const session = {
      id: id('ses'),
      user_id: user.id,
      access_token: id('tok'),
      refresh_token: id('ref'),
      created_at: now(),
    };
    db.users.push(user);
    db.sessions.push(session);
    writeDb(db);
    send(response, 201, {
      user: publicUser(user),
      access_token: session.access_token,
      refresh_token: session.refresh_token,
      token_type: 'Bearer',
    });
    return;
  }

  if (pathname === '/auth/login' && request.method === 'POST') {
    const payload = await body(request);
    const email = String(payload.email || '').trim().toLowerCase();
    const user = db.users.find((item) => item.email === email && item.password === payload.password);
    if (!user) {
      send(response, 422, { message: 'Invalid credentials.' });
      return;
    }
    const session = {
      id: id('ses'),
      user_id: user.id,
      access_token: id('tok'),
      refresh_token: id('ref'),
      created_at: now(),
    };
    db.sessions.push(session);
    writeDb(db);
    send(response, 200, {
      user: publicUser(user),
      access_token: session.access_token,
      refresh_token: session.refresh_token,
      token_type: 'Bearer',
    });
    return;
  }

  if (pathname === '/auth/profile' && request.method === 'GET') {
    send(response, 200, { user: publicUser(currentUser(db, request)) });
    return;
  }

  if (pathname === '/auth/logout' && request.method === 'POST') {
    const token = bearer(request);
    db.sessions = db.sessions.filter((session) => session.access_token !== token);
    writeDb(db);
    send(response, 200, { message: 'Logged out.' });
    return;
  }

  if (pathname === '/users' && request.method === 'GET') {
    collection(response, 'users', db.users.map(publicUser));
    return;
  }

  if (pathname === '/services' && request.method === 'GET') {
    const category = url.searchParams.get('category');
    const services = category
      ? db.services.filter((service) => String(service.category || '').toLowerCase() === category.toLowerCase())
      : db.services;
    collection(response, 'services', services);
    return;
  }

  if (pathname === '/services' && request.method === 'POST') {
    const payload = await body(request);
    const service = {
      id: id('svc'),
      title: payload.title || payload.name || 'Untitled service',
      description: payload.description || '',
      category: payload.category || 'General',
      price: Number(payload.price || 0),
      currency: payload.currency || 'TZS',
      duration_minutes: Number(payload.duration_minutes || 60),
      is_active: payload.is_active !== false,
      created_at: now(),
      updated_at: now(),
    };
    db.services.unshift(service);
    writeDb(db);
    send(response, 201, { service });
    return;
  }

  if (pathname === '/bookings' && request.method === 'GET') {
    const status = url.searchParams.get('status');
    const bookings = status ? db.bookings.filter((booking) => booking.status === status) : db.bookings;
    collection(response, 'bookings', bookings);
    return;
  }

  if (pathname === '/bookings' && request.method === 'POST') {
    const payload = await body(request);
    const user = currentUser(db, request);
    if (!user) {
      send(response, 401, { message: 'Please log in before booking a service.' });
      return;
    }
    const booking = {
      id: id('bk'),
      service_id: payload.service_id || null,
      customer_id: user ? user.id : null,
      technician_id: null,
      service_name: payload.service_name || payload.category || 'Service request',
      status: 'pending',
      scheduled_at: payload.preferredDate || null,
      address: payload.address || null,
      notes: payload.notes || payload.description || null,
      amount: Number(payload.amount || payload.price || 0),
      currency: payload.currency || 'TZS',
      otp_code: null,
      created_at: now(),
      updated_at: now(),
    };
    db.bookings.unshift(booking);
    db.chats.unshift({
      id: id('chat'),
      booking_id: booking.id,
      customer_id: user.id,
      technician_id: null,
      participants: [publicUser(user)],
      last_message: 'Booking request created.',
      last_message_at: now(),
      unread_count: 0,
      created_at: now(),
    });
    writeDb(db);
    send(response, 201, { booking });
    return;
  }

  const bookingAction = pathname.match(/^\/bookings\/([^/]+)\/(confirm|cancel|rate|otp)$/);
  if (bookingAction && request.method === 'POST') {
    const booking = db.bookings.find((item) => item.id === bookingAction[1]);
    if (!booking) return notFound(response);
    const payload = await body(request);
    if (bookingAction[2] === 'confirm') booking.status = 'confirmed';
    if (bookingAction[2] === 'cancel') {
      booking.status = 'cancelled';
      booking.cancellation_reason = payload.reason || null;
    }
    if (bookingAction[2] === 'rate') booking.rating = Number(payload.rating || 0);
    if (bookingAction[2] === 'otp') booking.status = 'completed';
    booking.updated_at = now();
    writeDb(db);
    send(response, 200, { booking });
    return;
  }

  const bookingStatus = pathname.match(/^\/bookings\/([^/]+)\/status$/);
  if (bookingStatus && request.method === 'PATCH') {
    const booking = db.bookings.find((item) => item.id === bookingStatus[1]);
    if (!booking) return notFound(response);
    const payload = await body(request);
    booking.status = payload.status || booking.status;
    booking.updated_at = now();
    writeDb(db);
    send(response, 200, { booking });
    return;
  }

  if (pathname === '/chats' && request.method === 'GET') {
    collection(response, 'threads', db.chats);
    return;
  }

  const chatMessages = pathname.match(/^\/chats\/([^/]+)\/messages$/);
  if (chatMessages && request.method === 'GET') {
    collection(response, 'messages', db.messages.filter((message) => message.thread_id === chatMessages[1]));
    return;
  }

  if (chatMessages && request.method === 'POST') {
    const payload = await body(request);
    const user = currentUser(db, request);
    const message = {
      id: id('msg'),
      thread_id: chatMessages[1],
      sender_id: user?.id || null,
      sender_name: user?.name || 'Customer',
      message: payload.message || '',
      is_mine: true,
      sent_at: now(),
    };
    db.messages.push(message);
    const chat = db.chats.find((item) => item.id === chatMessages[1]);
    if (chat) {
      chat.last_message = message.message;
      chat.last_message_at = message.sent_at;
    }
    writeDb(db);
    send(response, 201, { message });
    return;
  }

  if (pathname === '/payments' && request.method === 'GET') {
    const bookingId = url.searchParams.get('booking_id');
    const payments = bookingId ? db.payments.filter((payment) => payment.booking_id === bookingId) : db.payments;
    collection(response, 'payments', payments);
    return;
  }

  if (pathname === '/payments' && request.method === 'POST') {
    const payload = await body(request);
    const payment = {
      id: id('pay'),
      booking_id: payload.booking_id || payload.bookingId || null,
      provider: payload.provider || 'manual',
      method: payload.method || 'card',
      amount: Number(payload.amount || 0),
      currency: payload.currency || 'TZS',
      status: 'pending',
      reference: id('HF').toUpperCase(),
      created_at: now(),
    };
    db.payments.unshift(payment);
    writeDb(db);
    send(response, 201, { payment });
    return;
  }

  const paymentVerify = pathname.match(/^\/payments\/([^/]+)\/verify$/);
  if (paymentVerify && request.method === 'POST') {
    const payment = db.payments.find((item) => item.id === paymentVerify[1]);
    if (!payment) return notFound(response);
    payment.status = 'verified';
    payment.verified_at = now();
    writeDb(db);
    send(response, 200, { payment });
    return;
  }

  notFound(response);
}

ensureDatabase();
http.createServer((request, response) => {
  route(request, response).catch((error) => {
    send(response, 500, { message: error.message });
  });
}).listen(port, '127.0.0.1', () => {
  console.log(`HOMEFUNDI API listening on http://127.0.0.1:${port}/api/v1`);
});
