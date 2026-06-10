/**
 * Anchor WhatsApp Bridge — server.js
 *
 * A lightweight Express REST server that wraps @whiskeysockets/baileys.
 * Exposes endpoints that the Flutter desktop app communicates with via
 * HTTP on localhost:3847.
 *
 * Endpoints:
 *   GET  /health                       — simple health check
 *   GET  /status                       — connection status + phone number
 *   GET  /qr                           — QR code as base64 PNG
 *   GET  /groups                       — list of all WhatsApp groups
 *   GET  /messages/:groupJid           — buffered messages for a group
 *   GET  /messages/:groupJid/since/:ts — messages since Unix timestamp (ms)
 *   POST /disconnect                   — disconnect and clear session
 */

const {
  default: makeWASocket,
  useMultiFileAuthState,
  DisconnectReason,
  isJidGroup,
  fetchLatestBaileysVersion,
} = require('@whiskeysockets/baileys');
const { Boom } = require('@hapi/boom');
const express = require('express');
const pino = require('pino');
const qrcode = require('qrcode');
const path = require('path');

// ─── Config ────────────────────────────────────────────────────────────────

const PORT = 3847;
const AUTH_DIR = path.join(__dirname, 'auth_info_baileys');
const MAX_MESSAGES_PER_GROUP = 500;

// ─── State ─────────────────────────────────────────────────────────────────

let sock = null;
let connectionStatus = 'disconnected'; // 'disconnected' | 'qr_pending' | 'connected'
let currentQrBase64 = null;
let connectedPhone = null;

// Map<groupJid: string, messages: Array<{id, sender, senderName, text, timestamp}>>
const messageBuffer = new Map();

// Map<groupJid: string, {jid, name, participantCount}>
const groupCache = new Map();

// ─── Logger ────────────────────────────────────────────────────────────────

const logger = pino({ level: 'warn' });

// ─── Helpers ───────────────────────────────────────────────────────────────

function getTextFromMessage(msg) {
  const m = msg.message;
  if (!m) return null;
  return (
    m.conversation ||
    m.extendedTextMessage?.text ||
    m.imageMessage?.caption ||
    m.videoMessage?.caption ||
    m.documentMessage?.caption ||
    null
  );
}

function bufferMessage(jid, msgData) {
  if (!messageBuffer.has(jid)) {
    messageBuffer.set(jid, []);
  }
  const buf = messageBuffer.get(jid);
  buf.push(msgData);
  // Keep only the last MAX_MESSAGES_PER_GROUP messages
  if (buf.length > MAX_MESSAGES_PER_GROUP) {
    buf.splice(0, buf.length - MAX_MESSAGES_PER_GROUP);
  }
}

// ─── Baileys Socket ────────────────────────────────────────────────────────

async function startSocket() {
  const { state, saveCreds } = await useMultiFileAuthState(AUTH_DIR);
  const { version } = await fetchLatestBaileysVersion();

  sock = makeWASocket({
    version,
    auth: state,
    logger,
    printQRInTerminal: false, // We handle QR display in Flutter
    markOnlineOnConnect: false, // Don't change online status
    syncFullHistory: false,    // Don't download full history (saves bandwidth)
    generateHighQualityLinkPreview: false,
  });

  // ── Credentials update ────────────────────────────────────
  sock.ev.on('creds.update', saveCreds);

  // ── Connection updates ────────────────────────────────────
  sock.ev.on('connection.update', async (update) => {
    const { connection, lastDisconnect, qr } = update;

    if (qr) {
      connectionStatus = 'qr_pending';
      // Convert QR string to base64 PNG for Flutter to display
      try {
        currentQrBase64 = await qrcode.toDataURL(qr, {
          errorCorrectionLevel: 'M',
          width: 300,
          margin: 2,
        });
        console.log('[WA Bridge] QR code generated — waiting for scan');
      } catch (err) {
        console.error('[WA Bridge] Failed to generate QR image:', err);
      }
    }

    if (connection === 'open') {
      connectionStatus = 'connected';
      currentQrBase64 = null;
      connectedPhone = sock.user?.id?.split(':')[0] || null;
      console.log(`[WA Bridge] Connected as ${connectedPhone}`);

      // Fetch and cache all groups
      try {
        const groups = await sock.groupFetchAllParticipating();
        for (const [jid, meta] of Object.entries(groups)) {
          groupCache.set(jid, {
            jid,
            name: meta.subject,
            participantCount: meta.participants?.length ?? 0,
          });
        }
        console.log(`[WA Bridge] Loaded ${groupCache.size} groups`);
      } catch (err) {
        console.error('[WA Bridge] Failed to fetch groups:', err.message);
      }
    }

    if (connection === 'close') {
      const statusCode = (lastDisconnect?.error)?.output?.statusCode;
      const shouldReconnect = statusCode !== DisconnectReason.loggedOut;
      connectionStatus = 'disconnected';
      connectedPhone = null;
      console.log(`[WA Bridge] Disconnected (${statusCode}), reconnect: ${shouldReconnect}`);

      if (shouldReconnect) {
        // Wait 3s before reconnecting
        setTimeout(startSocket, 3000);
      }
    }
  });

  // ── Incoming messages ─────────────────────────────────────
  sock.ev.on('messages.upsert', ({ messages, type }) => {
    if (type !== 'notify') return;

    for (const msg of messages) {
      const jid = msg.key.remoteJid;
      if (!jid || !isJidGroup(jid)) continue; // Only group messages
      if (msg.key.fromMe) continue; // Skip own messages

      const text = getTextFromMessage(msg);
      if (!text || text.trim().length === 0) continue;

      const sender = msg.key.participant || msg.key.remoteJid;
      const senderName = msg.pushName || sender.split('@')[0];

      bufferMessage(jid, {
        id: msg.key.id,
        sender: sender.split('@')[0],
        senderName,
        text: text.trim(),
        timestamp: (msg.messageTimestamp || Date.now() / 1000) * 1000, // ms
      });
    }
  });

  // ── Group metadata updates ────────────────────────────────
  sock.ev.on('groups.update', (updates) => {
    for (const update of updates) {
      if (update.subject && groupCache.has(update.id)) {
        const existing = groupCache.get(update.id);
        groupCache.set(update.id, { ...existing, name: update.subject });
      }
    }
  });
}

// ─── Express Server ────────────────────────────────────────────────────────

const app = express();
app.use(express.json());

// CORS — allow localhost Flutter
app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.header('Access-Control-Allow-Headers', 'Content-Type');
  if (req.method === 'OPTIONS') return res.sendStatus(200);
  next();
});

// GET /health
app.get('/health', (req, res) => {
  res.json({ ok: true, port: PORT });
});

// GET /status
app.get('/status', (req, res) => {
  res.json({
    status: connectionStatus,
    phone: connectedPhone,
    groupCount: groupCache.size,
  });
});

// GET /qr — returns QR code as base64 data URL
app.get('/qr', (req, res) => {
  if (connectionStatus === 'connected') {
    return res.json({ status: 'connected', qr: null });
  }
  if (!currentQrBase64) {
    return res.json({ status: connectionStatus, qr: null });
  }
  res.json({ status: 'qr_pending', qr: currentQrBase64 });
});

// GET /groups — list all WhatsApp groups
app.get('/groups', (req, res) => {
  const groups = Array.from(groupCache.values()).sort((a, b) =>
    a.name.localeCompare(b.name)
  );
  res.json({ groups });
});

// GET /messages/:groupJid — all buffered messages for a group
app.get('/messages/:groupJid', (req, res) => {
  const { groupJid } = req.params;
  const messages = messageBuffer.get(groupJid) || [];
  res.json({ groupJid, count: messages.length, messages });
});

// GET /messages/:groupJid/since/:timestamp — messages since Unix ms timestamp
app.get('/messages/:groupJid/since/:timestamp', (req, res) => {
  const { groupJid, timestamp } = req.params;
  const since = parseInt(timestamp, 10);
  const all = messageBuffer.get(groupJid) || [];
  const filtered = all.filter((m) => m.timestamp > since);
  res.json({ groupJid, since, count: filtered.length, messages: filtered });
});

// POST /disconnect — disconnect WhatsApp
app.post('/disconnect', async (req, res) => {
  try {
    if (sock) {
      await sock.logout();
      sock = null;
    }
    connectionStatus = 'disconnected';
    connectedPhone = null;
    currentQrBase64 = null;
    messageBuffer.clear();
    groupCache.clear();
    res.json({ ok: true });
  } catch (err) {
    console.error('[WA Bridge] Disconnect error:', err.message);
    res.status(500).json({ ok: false, error: err.message });
  }
});

// ─── Start ─────────────────────────────────────────────────────────────────

app.listen(PORT, '127.0.0.1', () => {
  console.log(`[WA Bridge] Listening on http://127.0.0.1:${PORT}`);
  startSocket().catch((err) => {
    console.error('[WA Bridge] Failed to start socket:', err);
  });
});

// Graceful shutdown
process.on('SIGTERM', async () => {
  console.log('[WA Bridge] Shutting down...');
  if (sock) await sock.end();
  process.exit(0);
});

process.on('SIGINT', async () => {
  if (sock) await sock.end();
  process.exit(0);
});
