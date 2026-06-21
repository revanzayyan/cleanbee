import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class XenditService {
  /// Base URL backend Express Anda.
  /// Pastikan endpoint ini bisa diakses dari device/emulator.
  /// - Android emulator: gunakan http://10.0.2.2:3000
  /// - Real device: gunakan IP komputer/server atau domain publik.
  static String get backendBaseUrl {
    return 'https://cleanbee-backend-971233495843.asia-southeast2.run.app';
  }

  static const String createInvoicePath = '/v1/xendit/create-invoice';

  /// Membuat invoice menggunakan backend Anda (backend yang sudah integrasi Xendit).
  /// Mengembalikan invoice_url dari response.
  Future<String> createInvoice({
    required String bookingId,
    required int amount,
    required String email,
    required String description,
    required Map<String, dynamic> customer,
    required List<Map<String, dynamic>> items,
    required String successRedirectUrl,
    required String failureRedirectUrl,
    Map<String, dynamic>? metadata,
  }) async {
    final uri = Uri.parse('$backendBaseUrl$createInvoicePath');

    final body = {
      'booking_id': bookingId,
      'amount': amount,
      'email': email,
      'description': description,
      'currency': 'IDR',
      'customer': customer,
      'items': items,
      'success_redirect_url': successRedirectUrl,
      'failure_redirect_url': failureRedirectUrl,
      // Penting: metadata harus konsisten dengan yang dibaca backend webhook.
      // Backend webhook saat ini membaca: callbackData.metadata.booking
      // Jadi kita pastikan metadata berbentuk { booking_id, booking: {...} }.
      'metadata': metadata ?? {
        'booking_id': bookingId,
        'booking': {
          // isi minimal agar field seperti category tersedia jika backend membutuhkan
          'category': description,
        },
      },
    };

    final response = await http.post(
      uri,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal membuat invoice: ${response.statusCode} ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final invoiceUrl = data['invoice_url']?.toString();
    if (invoiceUrl == null || invoiceUrl.isEmpty) {
      throw Exception('invoice_url tidak ditemukan pada response: ${response.body}');
    }
    return invoiceUrl;
  }
}

