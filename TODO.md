# TODO

## Virtual account generation fix (proxy through backend)

- [x] Read current DOKU VA generation implementation in `lib/services/payment_service.dart`.
- [x] Read backend webhook server in `backend/server.js` and callback handler + verification screen.
- [x] Add backend endpoint `POST /api/payment/virtual-account/create` to proxy DOKU VA creation server-to-server.
- [x] Update Flutter web VA creation to call the backend proxy endpoint instead of DOKU directly.

## Next steps (run & verify)
- [ ] Install/verify backend runtime dependencies needed by `server.js` proxy (notably `node-fetch` if required by your Node version).
- [ ] Start backend and test: `POST /api/payment/virtual-account/create` returns DOKU response.
- [ ] Run Flutter web flow to generate VA; confirm request goes to backend (not directly to `staging-api.doku.com`).
- [ ] Confirm webhook `POST /api/payment/callback` updates Firestore correctly.

