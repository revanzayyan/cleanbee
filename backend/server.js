/**
 * DOKU Payment Webhook Handler Server
 * 
 * This server receives webhook callbacks from DOKU payment API
 * Updates Firestore with payment and booking status
 */

const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const crypto = require('crypto');
const admin = require('firebase-admin');
require('dotenv').config();

const app = express();

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.raw({ type: 'application/json' })); // For signature verification

// Initialize Firebase Admin SDK
const serviceAccountPath = process.env.FIREBASE_KEY_PATH || './serviceAccountKey.json';
try {
  const serviceAccount = require(serviceAccountPath);
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    databaseURL: process.env.FIREBASE_DATABASE_URL,
  });
} catch (error) {
  console.error('❌ Error initializing Firebase:', error.message);
  console.log('📝 Make sure to:');
  console.log('   1. Download serviceAccountKey.json from Firebase Console');
  console.log('   2. Place it in the backend directory');
  console.log('   3. Or set FIREBASE_KEY_PATH in .env file');
  process.exit(1);
}

const db = admin.firestore();

// Configuration
const DOKU_CLIENT_SECRET = process.env.DOKU_CLIENT_SECRET || 'SK-6By9fA8g4AMqnOGCAYE9';
const DOKU_CLIENT_ID = process.env.DOKU_CLIENT_ID || 'BRN-0262-1780146553005';

// NOTE: webhook secret kept for compatibility (signature is verified using DOKU client secret)
const WEBHOOK_SECRET = process.env.WEBHOOK_SECRET || 'your-webhook-secret-key';

const DOKU_BASE_URL = process.env.DOKU_BASE_URL || 'https://staging-api.doku.com';
const PORT = process.env.PORT || 3000;


// ============================================================================
// HEALTH CHECK ENDPOINT
// ============================================================================
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    service: 'DOKU Payment Webhook Handler',
  });
});

// ============================================================================
// WEBHOOK ENDPOINT - Receives DOKU payment callbacks
// ============================================================================
app.post('/api/payment/callback', async (req, res) => {
  const requestId = generateRequestId();
  console.log(`\n📨 [${requestId}] Incoming webhook...`);

  try {
    // Extract signature from headers
    const signature = req.headers['x-doku-signature'];
    const timestamp = req.headers['x-doku-timestamp'];
    const body = req.body;

    if (!signature || !timestamp) {
      console.log(`❌ [${requestId}] Missing signature or timestamp headers`);
      return res.status(400).json({
        error: 'Missing signature or timestamp',
        requestId,
      });
    }

    console.log(`🔍 [${requestId}] Verifying signature...`);

    // Verify DOKU signature
    if (!verifyDokuSignature(signature, timestamp, body)) {
      console.log(`❌ [${requestId}] Invalid signature`);
      return res.status(401).json({
        error: 'Invalid signature',
        requestId,
      });
    }

    console.log(`✅ [${requestId}] Signature verified`);

    // Extract payment data
    const paymentData = body.data || body;
    const referenceId = paymentData.reference_id || paymentData.reference || body.reference_id;
    const dokuStatus = paymentData.status;
    const amount = paymentData.amount;
    const invoiceRefNo = paymentData.order?.invoice_ref_no || paymentData.invoice_ref_no;

    console.log(`📋 [${requestId}] Payment Details:`);
    console.log(`   Reference: ${referenceId}`);
    console.log(`   Status: ${dokuStatus}`);
    console.log(`   Amount: ${amount}`);
    console.log(`   Invoice Ref: ${invoiceRefNo}`);

    if (!referenceId) {
      console.log(`❌ [${requestId}] Missing reference ID`);
      return res.status(400).json({
        error: 'Missing reference_id in payload',
        requestId,
      });
    }

    // Find payment record by reference_id
    console.log(`🔎 [${requestId}] Searching for payment record...`);
    const paymentsRef = db.collection('payments');
    const paymentSnapshot = await paymentsRef
      .where('reference_id', '==', referenceId)
      .limit(1)
      .get();

    if (paymentSnapshot.empty) {
      console.log(`⚠️ [${requestId}] Payment record not found: ${referenceId}`);
      // Return success anyway to acknowledge receipt
      return res.json({
        status: 'acknowledged',
        reference: referenceId,
        message: 'Payment record not yet created, will sync on next poll',
        requestId,
      });
    }

    const paymentDoc = paymentSnapshot.docs[0];
    const paymentId = paymentDoc.id;
    const existingPaymentData = paymentDoc.data();
    const bookingId = existingPaymentData.booking_id;

    // Map DOKU status to our status
    const mappedStatus = mapDokuStatus(dokuStatus);
    console.log(`🔄 [${requestId}] Mapped DOKU status '${dokuStatus}' → '${mappedStatus}'`);

    // Update payment record
    console.log(`💾 [${requestId}] Updating payment record...`);
    await paymentsRef.doc(paymentId).update({
      status: mappedStatus,
      doku_status: dokuStatus,
      paid_at: admin.firestore.Timestamp.now(),
      updated_at: admin.firestore.Timestamp.now(),
      webhook_data: body,
      webhook_received_at: admin.firestore.Timestamp.now(),
    });

    console.log(`✅ [${requestId}] Payment record updated: ${paymentId} → ${mappedStatus}`);

    // Update booking status if payment successful
    if (mappedStatus === 'success' && bookingId) {
      console.log(`📍 [${requestId}] Updating booking status...`);
      const bookingRef = db.collection('bookings').doc(bookingId);

      // Check if booking exists
      const bookingDoc = await bookingRef.get();
      if (bookingDoc.exists) {
        await bookingRef.update({
          status: 'Dibayar',
          payment_status: 'success',
          payment_id: paymentId,
          payment_verified_at: admin.firestore.Timestamp.now(),
          updated_at: admin.firestore.Timestamp.now(),
        });
        console.log(`✅ [${requestId}] Booking updated: ${bookingId} → Dibayar`);
      } else {
        console.log(`⚠️ [${requestId}] Booking not found: ${bookingId}`);
      }
    }

    // Log webhook event
    console.log(`📝 [${requestId}] Logging webhook event...`);
    await db.collection('webhook_logs').add({
      reference_id: referenceId,
      request_id: requestId,
      status: mappedStatus,
      payment_id: paymentId,
      booking_id: bookingId,
      amount: amount,
      doku_status: dokuStatus,
      received_at: admin.firestore.Timestamp.now(),
      success: true,
    });

    console.log(`🎉 [${requestId}] Webhook processed successfully\n`);

    // Return success response
    res.json({
      status: 'success',
      reference: referenceId,
      payment_id: paymentId,
      booking_id: bookingId,
      message: 'Webhook processed successfully',
      requestId,
    });

  } catch (error) {
    console.error(`❌ [${requestId}] Webhook error:`, error);

    // Log error
    try {
      await db.collection('webhook_logs').add({
        request_id: requestId,
        status: 'error',
        error: error.message,
        received_at: admin.firestore.Timestamp.now(),
        success: false,
      });
    } catch (logError) {
      console.error('Failed to log error:', logError);
    }

    res.status(500).json({
      error: error.message,
      requestId,
    });
  }
});

// ============================================================================
// MANUAL PAYMENT VERIFICATION ENDPOINT
// ============================================================================
app.post('/api/payment/verify/:referenceId', async (req, res) => {
  const { referenceId } = req.params;
  const requestId = generateRequestId();

  console.log(`\n🔍 [${requestId}] Manual verification request for: ${referenceId}`);

  try {
    // Find payment by reference_id
    const paymentSnapshot = await db.collection('payments')
      .where('reference_id', '==', referenceId)
      .limit(1)
      .get();

    if (paymentSnapshot.empty) {
      console.log(`❌ [${requestId}] Payment not found`);
      return res.status(404).json({
        error: 'Payment not found',
        referenceId,
      });
    }

    const paymentDoc = paymentSnapshot.docs[0];
    const payment = paymentDoc.data();

    console.log(`✅ [${requestId}] Payment found:`);
    console.log(`   Status: ${payment.status}`);
    console.log(`   Amount: ${payment.amount}`);
    console.log(`   Booking ID: ${payment.booking_id}`);

    res.json({
      status: 'found',
      payment: {
        id: paymentDoc.id,
        ...payment,
      },
      requestId,
    });

  } catch (error) {
    console.error(`❌ [${requestId}] Verification error:`, error);
    res.status(500).json({
      error: error.message,
      referenceId,
    });
  }
});

// ============================================================================
// CREATE VIRTUAL ACCOUNT (PROXY ENDPOINT)
// ============================================================================
app.post('/api/payment/virtual-account/create', async (req, res) => {
  const requestId = generateRequestId();
  console.log(`\n🧾 [${requestId}] Create Virtual Account proxy request...`);

  try {
    const {
      bookingId,
      amount,
      description,
      bankCode,
      customerId,
      customerName,
      // optional: allow caller to override
      callbackUrl,
    } = req.body || {};

    if (!bookingId || !amount || !description || !bankCode) {
      return res.status(400).json({
        error: 'Missing required fields',
        requestId,
      });
    }

    const timestamp = new Date().toISOString();
    const payload = {
      amount: Math.round(Number(amount)),
      bank_code: bankCode,
      invoice_ref_no: bookingId,
      reference: `VA-${bookingId}-${Date.now()}`,
      currency: 'IDR',
      order: {
        items: [
          {
            name: description,
            quantity: 1,
            price: Math.round(Number(amount)),
          },
        ],
      },
      customer: {
        id: customerId || bookingId,
        name: customerName || 'Customer',
      },
      callback_url: callbackUrl || 'https://headlock-sternum-tinker.ngrok-free.dev/api/payment/callback',
      expiry: {
        unit: 'HOUR',
        value: 24,
      },
    };

    // Signature for DOKU
    // signatureString = method\npath\nclientId\ntimestamp\nbody
    const path = '/payment/virtual-account-number/v2/create';
    const signatureString = `POST\n${path}\n${DOKU_CLIENT_ID}\n${timestamp}\n${JSON.stringify(payload)}`;
    const signature = crypto
      .createHmac('sha256', DOKU_CLIENT_SECRET)
      .update(signatureString)
      .digest('hex');

    const headers = {
      'Content-Type': 'application/json',
      'Authorization': `DOKU ${DOKU_CLIENT_ID}:${signature}`,
      'X-DOKU-Timestamp': timestamp,
      'X-DOKU-Idempotency-Key': String(Date.now()),
    };

    // Call DOKU server-to-server (no browser/CORS issues)
    const fetch = global.fetch || (await import('node-fetch')).default;

    const r = await fetch(`${DOKU_BASE_URL}${path}`, {
      method: 'POST',
      headers,
      body: JSON.stringify(payload),
    });

    const text = await r.text();
    let data;
    try { data = JSON.parse(text); } catch { data = { raw: text }; }

    if (!r.ok) {
      console.error(`❌ [${requestId}] DOKU error`, { status: r.status, data });
      return res.status(502).json({
        error: 'Failed to create virtual account via DOKU',
        requestId,
        statusCode: r.status,
        data,
      });
    }

    // Return DOKU response as-is (Flutter parses it)
    return res.json({
      requestId,
      data,
    });
  } catch (error) {
    console.error(`❌ [${requestId}] Proxy error:`, error);
    return res.status(500).json({
      error: error.message || String(error),
      requestId,
    });
  }
});

// ============================================================================
// PAYMENT STATUS ENDPOINT
// ============================================================================
app.get('/api/payment/:referenceId/status', async (req, res) => {

  const { referenceId } = req.params;

  try {
    const paymentSnapshot = await db.collection('payments')
      .where('reference_id', '==', referenceId)
      .limit(1)
      .get();

    if (paymentSnapshot.empty) {
      return res.status(404).json({
        error: 'Payment not found',
        referenceId,
      });
    }

    const paymentDoc = paymentSnapshot.docs[0];
    const payment = paymentDoc.data();

    res.json({
      status: 'found',
      reference_id: referenceId,
      payment_status: payment.status,
      booking_id: payment.booking_id,
      amount: payment.amount,
      created_at: payment.created_at,
      paid_at: payment.paid_at,
    });

  } catch (error) {
    console.error('Error fetching payment status:', error);
    res.status(500).json({
      error: error.message,
    });
  }
});

// ============================================================================
// WEBHOOK LOGS ENDPOINT
// ============================================================================
app.get('/api/webhook/logs', async (req, res) => {
  try {
    const limit = Math.min(parseInt(req.query.limit) || 20, 100);
    const logsSnapshot = await db.collection('webhook_logs')
      .orderBy('received_at', 'desc')
      .limit(limit)
      .get();

    const logs = logsSnapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data(),
    }));

    res.json({
      total: logs.length,
      logs,
    });

  } catch (error) {
    console.error('Error fetching logs:', error);
    res.status(500).json({
      error: error.message,
    });
  }
});

// ============================================================================
// ERROR HANDLERS
// ============================================================================

app.use((req, res) => {
  res.status(404).json({
    error: 'Not Found',
    path: req.path,
    method: req.method,
  });
});

app.use((err, req, res, next) => {
  console.error('Unhandled error:', err);
  res.status(500).json({
    error: 'Internal Server Error',
    message: err.message,
  });
});

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

/**
 * Verify DOKU webhook signature
 * DOKU uses HMAC-SHA256 signature verification
 */
function verifyDokuSignature(signature, timestamp, body) {
  try {
    // Convert body to JSON string if it's an object
    const bodyString = typeof body === 'string' ? body : JSON.stringify(body);

    // Create signature string: timestamp\nbody
    const signatureString = `${timestamp}\n${bodyString}`;

    // Generate expected signature using HMAC-SHA256
    const expectedSignature = crypto
      .createHmac('sha256', DOKU_CLIENT_SECRET)
      .update(signatureString)
      .digest('hex');

    // Compare signatures
    return crypto.timingSafeEqual(
      Buffer.from(signature),
      Buffer.from(expectedSignature)
    );
  } catch (error) {
    console.error('Signature verification error:', error);
    return false;
  }
}

/**
 * Map DOKU payment status to our internal status
 */
function mapDokuStatus(dokuStatus) {
  const statusMap = {
    'SETTLED': 'success',
    'SUCCESS': 'success',
    'COMPLETED': 'success',
    'PENDING': 'pending',
    'WAITING_PAYMENT': 'pending',
    'FAILED': 'failed',
    'REJECTED': 'failed',
    'EXPIRED': 'expired',
    'CANCELLED': 'cancelled',
  };

  return statusMap[dokuStatus?.toUpperCase()] || 'pending';
}

/**
 * Generate unique request ID for tracking
 */
function generateRequestId() {
  return `webhook_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
}

// ============================================================================
// SERVER STARTUP
// ============================================================================

const server = app.listen(PORT, () => {
  console.log(`
╔════════════════════════════════════════════╗
║  🚀 DOKU Payment Webhook Server            ║
║  Running on: http://localhost:${PORT}      ║
║  Environment: ${process.env.NODE_ENV || 'development'}               ║
╚════════════════════════════════════════════╝

Endpoints:
  POST   /api/payment/callback           - DOKU webhook receiver
  GET    /api/payment/:referenceId/status - Check payment status
  POST   /api/payment/verify/:referenceId - Manual verification
  GET    /api/webhook/logs                - View webhook logs
  GET    /health                          - Health check

Configuration:
  DOKU_CLIENT_SECRET: ${DOKU_CLIENT_SECRET ? '✓ Configured' : '✗ Missing'}
  Firebase: ${process.env.FIREBASE_KEY_PATH ? '✓ Configured' : '✓ Using default'}

Next Steps:
  1. Update DOKU dashboard webhooks to point to: https://your-backend.com/api/payment/callback
  2. Restart server after deployment
  3. Test webhook with: npm run dev
  `);
});

server.on('error', (error) => {
  console.error('Server error:', error);
  process.exit(1);
});

process.on('unhandledRejection', (reason, promise) => {
  console.error('Unhandled Rejection at:', promise, 'reason:', reason);
});
