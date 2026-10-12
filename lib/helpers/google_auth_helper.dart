import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Google sign-in through Firebase (project `collectionbolw`). The app only
/// gets a Firebase ID token here; the API verifies it and creates or finds
/// the account in our own database (POST /auth/google).
class GoogleAuthHelper {
  static bool _ready = false;
  static bool get ready => _ready;

  /// Needs android/app/google-services.json and
  /// ios/Runner/GoogleService-Info.plist. Without them the app still runs,
  /// the Google buttons just report that it isn't set up.
  static Future<void> init() async {
    try {
      await Firebase.initializeApp();
      _ready = true;
    } catch (e) {
      debugPrint("!!! [firebase] not configured: $e");
    }
  }

  /// Opens the Google account picker. Returns the Firebase ID token, or
  /// null if the person closed the sheet. Throws on real failures.
  static Future<String?> idToken() async {
    if (!_ready) throw StateError("Google sign-in is not set up yet.");
    try {
      final cred = await FirebaseAuth.instance.signInWithProvider(
        GoogleAuthProvider()..addScope('email'),
      );
      return await cred.user?.getIdToken(true);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'canceled' ||
          e.code == 'web-context-canceled' ||
          e.code == 'popup-closed-by-user') {
        return null;
      }
      rethrow;
    }
  }

  static Future<void> signOut() async {
    if (!_ready) return;
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {}
  }
}
