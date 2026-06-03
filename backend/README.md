# CleanBee Payment Backend - Webhook Server

Backend server for handling DOKU payment webhooks and updating Firestore database.

## Overview

This Node.js/Express server:
- Receives DOKU payment callback webhooks
- Verifies HMAC-SHA256 signatures
- Updates Firestore payment and booking records
- Logs all webhook events for audit trail
- Provides payment status verification endpoints

## Quick Start

### 1. Prerequisites
- Node.js 16+ 
- Firebase project with Firestore
- DOKU API credentials

### 2. Installation

```bash
cd backend
npm install
```

### 3. Configuration

Copy and configure the `.env` file:

```bash
cp .env.example .env
```

Update `.env` with your values:
```env
PORT=3000
NODE_ENV=development
FIREBASE_KEY_PATH=./serviceAccountKey.json
DOKU_CLIENT_SECRET=YOUR_CLIENT_SECRET
```

### 4. Firebase Service Account

Download your Firebase service account key:

1. Go to Firebase Console
2. Project Settings → Service Accounts
3. Click "Generate New Private Key"
4. Save as `backend/serviceAccountKey.json`

⚠️ **SECURITY WARNING**: Never commit `serviceAccountKey.json` to version control!
It's already in `.gitignore` but verify before pushing.

### 5. Start Development Server

```bash
# Development (with auto-reload)
npm run dev

# Production
npm start
```

Server runs on: `http://localhost:3000`

## Endpoints

### Health Check
```
GET /health
```
Returns: `{ status: 'ok', timestamp: '...', service: '...' }`

### Payment Webhook (DOKU)
```
POST /api/payment/callback
Headers:
  x-doku-signature: <HMAC-SHA256 hex>
  x-doku-timestamp: <ISO 8601 timestamp>
Body: JSON payment data from DOKU
```

Processes:
- ✅ Verifies DOKU signature
- ✅ Finds payment record in Firestore
- ✅ Updates payment status
- ✅ Updates booking status (if success)
- ✅ Logs webhook event

### Payment Status Lookup
```
GET /api/payment/:referenceId/status
```
Returns: `{ status: 'found', reference_id: '...', payment_status: '...', ... }`

### Manual Verification
```
POST /api/payment/verify/:referenceId
```
Returns: Full payment document

### Webhook Logs
```
GET /api/webhook/logs?limit=20
```
Returns: Last N webhook events (default 20, max 100)

## Deployment

### Option 1: Heroku

```bash
# Install Heroku CLI
# Login to Heroku
heroku login

# Create app
heroku create cleanbee-payment-backend

# Set environment variables
heroku config:set DOKU_CLIENT_SECRET=your_secret
heroku config:set FIREBASE_KEY_PATH=/app/serviceAccountKey.json

# Upload service account key as config var
heroku config:set FIREBASE_KEY=$(cat serviceAccountKey.json)

# Deploy
git push heroku main
```

### Option 2: AWS Lambda

Use AWS Lambda with API Gateway or AWS Elastic Beanstalk.

### Option 3: Google Cloud Run

```bash
# Login to Google Cloud
gcloud auth login

# Create project
gcloud config set project cleanbee-payment

# Deploy
gcloud run deploy cleanbee-payment-backend \
  --source . \
  --platform managed \
  --region us-central1 \
  --set-env-vars DOKU_CLIENT_SECRET=your_secret
```

### Option 4: Docker

```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install --production
COPY . .
CMD ["npm", "start"]
```

Deploy to Docker Hub or registry of your choice.

## DOKU Dashboard Configuration

After deployment, configure webhooks in DOKU Dashboard:

1. Log in to DOKU Dashboard
2. Go to Settings → Webhooks
3. Add new webhook:
   - **URL**: `https://your-backend.com/api/payment/callback`
   - **Method**: POST
   - **Events**: All payment status changes
4. Enable events:
   - QR Payment (Settled)
   - Virtual Account (Settled)
5. Save and test with webhook trigger

## Firestore Security Rules

The security rules in `firestore.rules`:
- Allow users to create/read their own bookings
- Allow users to read their own payments
- Allow backend service account to update payment/booking status
- Allow admin to manage everything
- Deny all other access

### Deploy Firestore Rules

```bash
# From project root
firebase deploy --only firestore:rules

# Or from Firebase Console:
# Firestore → Rules tab → Update
```

Paste the contents of `firestore.rules` into Firebase Console.

## Payment Status Flow

```
DOKU Payment Event
    ↓
Webhook to /api/payment/callback
    ↓
Verify HMAC-SHA256 Signature
    ↓
Find Payment in Firestore
    ↓
Update Payment Status: pending → success/failed/expired
    ↓
Update Booking Status (if success): Pending → Dibayar
    ↓
Log Webhook Event
    ↓
Return Success Response
```

## Error Handling

The server logs all errors with request IDs for tracking:

```
❌ [webhook_123456_abc9d] Invalid signature
⚠️ [webhook_123456_def4e] Payment record not found
✅ [webhook_123456_ghi7j] Webhook processed successfully
```

Check logs:
```bash
GET /api/webhook/logs
```

## Debugging

### View Server Logs
```bash
npm run dev  # Shows console output
```

### Check Firestore Records
```bash
# Firebase Console:
# Firestore → Collections → payments
# Firestore → Collections → webhook_logs
```

### Test Webhook Locally

Use `curl` or Postman:
```bash
curl -X POST http://localhost:3000/api/payment/callback \
  -H "Content-Type: application/json" \
  -H "x-doku-signature: $(echo -n '2024-01-01T12:00:00Z\n{}' | openssl dgst -sha256 -hmac 'SECRET' -hex | cut -d' ' -f2)" \
  -H "x-doku-timestamp: 2024-01-01T12:00:00Z" \
  -d '{"data":{"reference_id":"test123","status":"SETTLED","amount":150000}}'
```

## Environment Variables Reference

| Variable | Required | Example | Description |
|----------|----------|---------|-------------|
| `PORT` | No | `3000` | Server port |
| `NODE_ENV` | No | `development` | Environment |
| `FIREBASE_KEY_PATH` | Yes | `./serviceAccountKey.json` | Firebase credentials |
| `FIREBASE_DATABASE_URL` | Yes | `https://project.firebaseio.com` | Firestore database URL |
| `DOKU_CLIENT_SECRET` | Yes | `SK-xxxxxx` | DOKU client secret |
| `WEBHOOK_SECRET` | No | `secret-key` | Optional webhook secret |

## Monitoring

Monitor webhook logs in Firebase Console:

1. Firestore → Collections → webhook_logs
2. Sort by `received_at` descending
3. Check `success` field for processed webhooks
4. Check `error` field for failures

## Security Considerations

✅ **Signature Verification**: HMAC-SHA256 signature required
✅ **Database Rules**: Firestore security rules restrict access
✅ **Service Account**: Uses least-privilege Firebase service account
✅ **Audit Trail**: All webhooks logged in Firestore
⚠️ **Secrets**: Never commit serviceAccountKey.json or real secrets

## Common Issues

### Error: Firebase Key Not Found
**Solution**: Download serviceAccountKey.json from Firebase Console

### Error: Invalid Signature
**Solution**: Check DOKU_CLIENT_SECRET matches Dashboard configuration

### Error: Payment Record Not Found
**Solution**: Payment created on client, webhook received before Firestore sync

### Port Already in Use
**Solution**: Change PORT in .env or: `lsof -i :3000 && kill -9 <PID>`

## Support

For issues or questions:
1. Check server logs: `npm run dev`
2. Check Firestore webhook_logs collection
3. Verify DOKU Dashboard webhook configuration
4. Review Firestore security rules

## License

ISC - CleanBee Team
