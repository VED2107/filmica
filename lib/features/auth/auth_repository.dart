import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  AuthRepository(this._client);

  final SupabaseClient _client;

  Future<bool> signInWithApple({
    String? redirectTo,
  }) async {
    return _client.auth.signInWithOAuth(
      OAuthProvider.apple,
      redirectTo: redirectTo,
    );
  }

  Future<bool> signInWithGoogle({
    String? redirectTo,
  }) async {
    return _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: redirectTo,
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<void> deleteAccount() async {
    await _client.functions.invoke('delete-account');
    try {
      await _client.auth.signOut();
    } catch (_) {
      // The session may already be invalid after the account is deleted.
    }
  }

  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
}
