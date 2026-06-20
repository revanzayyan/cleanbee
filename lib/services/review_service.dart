import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review_model.dart';

class ReviewService extends ChangeNotifier {
  static final ReviewService _instance = ReviewService._internal();
  factory ReviewService() => _instance;
  ReviewService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<ReviewModel> _reviews = [];

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _reviewSub;
  bool _isListening = false;

  // Draft sementara untuk alur review yang sedang berjalan
  int? draftRating;
  String? draftComment;
  String? draftOrderId;

  List<ReviewModel> get reviews => List.unmodifiable(_reviews);

  /// Mulai mendengarkan koleksi reviews dari Firestore
  void ensureListening() {
    if (_isListening) return;
    _isListening = true;

    _reviewSub = _firestore
        .collection('reviews')
        .orderBy('created_at', descending: true)
        .snapshots()
        .listen((snapshot) {
      final nextReviews = snapshot.docs.map((doc) {
        return ReviewModel.fromMap(doc.data(), id: doc.id);
      }).toList();

      _reviews
        ..clear()
        ..addAll(nextReviews);
      notifyListeners();
    }, onError: (e) {
      debugPrint('ReviewService stream error: $e');
    });
  }

  /// Simpan ulasan baru ke Firestore dan tambahkan ke list lokal
  Future<ReviewModel?> addReview(ReviewModel review) async {
    try {
      final docRef = await _firestore.collection('reviews').add(review.toMap());
      final saved = review.copyWith(id: docRef.id);
      // insert di awal agar tampil paling atas
      _reviews.insert(0, saved);
      notifyListeners();
      // Bersihkan draft
      _clearDraft();
      return saved;
    } catch (e) {
      debugPrint('Error adding review: $e');
      // fallback: simpan lokal saja
      final local = review.copyWith(id: 'local_${DateTime.now().millisecondsSinceEpoch}');
      _reviews.insert(0, local);
      notifyListeners();
      _clearDraft();
      return local;
    }
  }

  /// Simpan admin reply
  Future<void> replyToReview(String reviewId, String reply) async {
    try {
      await _firestore.collection('reviews').doc(reviewId).update({
        'admin_reply': reply,
      });
      final idx = _reviews.indexWhere((r) => r.id == reviewId);
      if (idx != -1) {
        _reviews[idx] = _reviews[idx].copyWith(adminReply: reply);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error replying to review: $e');
    }
  }

  /// Rata-rata rating untuk staff tertentu
  double getAverageRating(String staffId) {
    final staffReviews = _reviews.where((r) => r.staffId == staffId).toList();
    if (staffReviews.isEmpty) return 0.0;
    final sum = staffReviews.fold<int>(0, (prev, r) => prev + r.rating);
    return sum / staffReviews.length;
  }

  /// Simpan draft rating sementara
  void saveDraft({required String orderId, required int rating, String? comment}) {
    draftOrderId = orderId;
    draftRating = rating;
    draftComment = comment;
  }

  void _clearDraft() {
    draftOrderId = null;
    draftRating = null;
    draftComment = null;
  }

  @override
  void dispose() {
    _reviewSub?.cancel();
    super.dispose();
  }
}
