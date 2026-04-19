import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/services.dart'; // TAMBAHAN: untuk PlatformException

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _mapException(e);
    } on PlatformException catch (e) {
      throw _mapPlatformException(e);
    } catch (e) {
      throw 'Terjadi kesalahan: $e';
    }
  }

  Future<UserCredential> registerWithEmail(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _mapException(e);
    } on PlatformException catch (e) {
      throw _mapPlatformException(e);
    } catch (e) {
      throw 'Terjadi kesalahan: $e';
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Sign in dibatalkan oleh user');
      }

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _mapException(e);
    } on PlatformException catch (e) {
      throw _mapPlatformException(e);
    } catch (e) {
      throw 'Terjadi kesalahan: $e';
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _mapException(e);
    } on PlatformException catch (e) {
      throw _mapPlatformException(e);
    } catch (e) {
      throw 'Terjadi kesalahan: $e';
    }
  }

  String _mapException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Akun tidak ditemukan';
      case 'wrong-password':
        return 'Password salah';
      case 'email-already-in-use':
        return 'Email sudah terdaftar';
      case 'weak-password':
        return 'Password terlalu lemah (minimal 6 karakter)';
      case 'invalid-email':
        return 'Format email tidak valid';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan, coba lagi nanti';
      case 'invalid-credential':
        return 'Email atau password salah';
      case 'network-request-failed':
        return 'Tidak ada koneksi internet';
      default:
        return 'Firebase error: ${e.message}';
    }
  }

  // TAMBAHAN: khusus tangkap PlatformException
  String _mapPlatformException(PlatformException e) {
    if (e.message != null && e.message!.isNotEmpty) {
      return e.message!;
    }
    return 'Kesalahan perangkat (${e.code})';
  }
}