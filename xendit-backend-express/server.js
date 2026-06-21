const express = require('express');
const bodyParser = require('body-parser');
const axios = require('axios');
const admin = require('firebase-admin');
require('dotenv').config();

const app = express();
app.use(bodyParser.json());

const PORT = process.env.PORT || 3000;
const XENDIT_SECRET_KEY = process.env.XENDIT_SECRET_KEY;
const XENDIT_WEBHOOK_SECRET = process.env.XENDIT_WEBHOOK_SECRET || process.env.WEBHOOK_SECRET;

if (!XENDIT_SECRET_KEY) {
    throw new Error('Missing env XENDIT_SECRET_KEY');
}

// Firebase Admin init
// Asumsi: Anda sudah menyiapkan GOOGLE_APPLICATION_CREDENTIALS (opsi paling gampang) / atau env credentials lain.
// Untuk saat ini kita pakai default credentials dari environment.
if (!admin.apps.length) {
    admin.initializeApp();
}
const firestore = admin.firestore();

// Encode Secret Key ke Base64 untuk autentikasi Basic Auth Xendit
const authHeader = Buffer.from(`${XENDIT_SECRET_KEY}:`).toString('base64');

// Xendit invoices API endpoint
const XENDIT_BASE_URL = 'https://api.xendit.co';
const XENDIT_INVOICES_PATH = '/v2/invoices';


// ==========================================
// ENDPOINT 1: MEMBUAT INVOICE (DIPANGGIL OLEH FLUTTER)
// ==========================================
app.post('/v1/xendit/create-invoice', async (req, res) => {
    try {
        const { booking_id, amount, email, description } = req.body;

        // Validasi input sederhana
        if (!booking_id || !amount || !email) {
            return res.status(400).json({ message: "Data tidak lengkap" });
        }

        if (!req.body.success_redirect_url && !req.body.successUrl) {
            return res.status(400).json({ message: 'success_redirect_url wajib diisi' });
        }

        if (!req.body.failure_redirect_url && !req.body.failureUrl) {
            return res.status(400).json({ message: 'failure_redirect_url wajib diisi' });
        }


        // Panggil Xendit Invoices v2
        // Catatan sandbox: cukup pakai secret sandbox (xnd_development_...). Base URL tetap https://xendit.co
        const response = await axios.post(
            `${XENDIT_BASE_URL}${XENDIT_INVOICES_PATH}`,
            {
                external_id: booking_id,
                amount: parseInt(amount),
                description: description || 'Pembayaran Aplikasi',
                currency: req.body.currency || 'IDR',

                // Cocokkan dengan skema /v2/invoices
                customer: {
                    given_names: (req.body.customer?.given_names || req.body.given_names || '').toString(),
                    surname: (req.body.customer?.surname || req.body.surname || '').toString(),
                    email: req.body.customer?.email || email,
                    mobile_number: req.body.customer?.mobile_number || req.body.mobile_number,
                },
                items: req.body.items || [
                    {
                        name: req.body.item_name || description || 'Pembayaran',
                        quantity: 1,
                        price: parseInt(amount),
                        category: req.body.item_category || 'Payment',
                        url: req.body.item_url,
                    }
                ],

                success_redirect_url: req.body.success_redirect_url || req.body.successUrl,
                failure_redirect_url: req.body.failure_redirect_url || req.body.failureUrl,

// Opsional: kirim metadata
                metadata: req.body.metadata || { booking_id },
            },
            {
                headers: {
                    'Authorization': `Basic ${authHeader}`,
                    'Content-Type': 'application/json'
                }
            }
        );


        // Kembalikan objek invoice_url ke aplikasi Flutter
        return res.status(200).json({
            message: "Invoice berhasil dibuat",
            invoice_url: response.data.invoice_url,
            status: response.data.status
        });

    } catch (error) {
        console.error("Xendit Error:", error.response ? error.response.data : error.message);
        return res.status(500).json({
            message: "Gagal membuat transaksi ke Xendit",
            error: error.response ? error.response.data : error.message
        });
    }
});

// ==========================================
// ENDPOINT 2: WEBHOOK/CALLBACK (DIPANGGIL OLEH XENDIT KETIKA LUNAS)
// ==========================================
app.post('/v1/xendit/webhook', async (req, res) => {
    const callbackData = req.body;

    // Catatan: Signature header Xendit bergantung konfigurasi webhook.
    // Untuk implementasi yang benar, cek dokumentasi Xendit (header yang dipakai & cara verifikasinya).
    // Saat ini kita log dulu supaya bisa disesuaikan.
    console.log("Menerima Webhook dari Xendit:", callbackData);

    const bookingId = callbackData.external_id;
    const statusPembayaran = callbackData.status;
    const paymentId = callbackData.payment_id;


    if (!bookingId) {
        console.warn('Webhook missing external_id', callbackData);
        return res.status(400).send('Missing external_id');
    }

    if (statusPembayaran === 'PAID' || statusPembayaran === 'SETTLED') {
        console.log(`Booking ID: ${bookingId} TELAH LUNAS! payment_id=${paymentId}`);

        // status field di app umumnya: 'Diproses' | 'Dibayar' | 'Selesai'
        // Requirement: setelah payment berhasil -> 'Diproses'
        const newStatus = 'Diproses';


        // Metadata sering tidak selalu ikut terbawa di webhook.
        // Jadi minimal pastikan status & payment_id selalu tersimpan.
        const bookingMeta = callbackData?.metadata?.booking;
        const data = bookingMeta && typeof bookingMeta === 'object' ? bookingMeta : {};

        // Pastikan tidak ada key yang nilainya `undefined` untuk Firestore.
        // Bahkan jika kita pakai filter, kita tetap buat tipe yang benar (string) agar aman.
        const rawPayload = {
            status: newStatus,
            payment_id: paymentId ?? null,
            updated_at: new Date().toISOString(),

            category: typeof data.category === 'string' ? data.category : undefined,
            building_type: typeof data.buildingType === 'string' ? data.buildingType : undefined,
            building_detail: typeof data.buildingDetail === 'string' ? data.buildingDetail : undefined,
            floor_detail: typeof data.floorDetail === 'string' ? data.floorDetail : undefined,
            room_detail: typeof data.roomDetail === 'string' ? data.roomDetail : undefined,
            date: typeof data.date === 'string' ? data.date : undefined,
            time_range: typeof data.timeRange === 'string' ? data.timeRange : undefined,
            user_uid: typeof data.userUid === 'string' ? data.userUid : undefined,
            user_email: typeof data.userEmail === 'string' ? data.userEmail : undefined,
        };

        const payload = Object.fromEntries(
            Object.entries(rawPayload).filter(([_, v]) => v !== undefined)
        );



        console.log('Webhook write payload booking/{external_id}:', {
            bookingId,
            hasMetadata: Boolean(bookingMeta),
            paymentId,
            payloadKeys: Object.keys(payload),
        });

        try {
            await firestore.collection('bookings').doc(bookingId).set(payload, { merge: true });
        } catch (err) {
            console.error('Firestore create/update failed:', err?.message || err);
            return res.status(500).send('Webhook failed');
        }
    }


    return res.status(200).send('Webhook received successfully');
});


app.listen(PORT, () => {
    console.log(`Backend Xendit berjalan di port ${PORT}`);
});