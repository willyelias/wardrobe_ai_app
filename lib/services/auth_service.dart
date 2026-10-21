import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import 'database_service.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  static const String _kIsLoggedInKey = 'auth_is_logged_in';
  static const String _kUserIdKey = 'auth_user_id';
  static const String _kUserNameKey = 'auth_user_name';
  static const String _kUserEmailKey = 'auth_user_email';
  static const String _kUserPhotoKey = 'auth_user_photo';
  static const String _kAuthMethodKey = 'auth_method';

  UserProfile? _currentUser;

  UserProfile? get currentUser => _currentUser;

  Future<UserProfile> loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_kIsLoggedInKey) ?? false;

    if (!isLoggedIn) {
      final guest = UserProfile.guest();
      _currentUser = guest;
      return guest;
    }

    final id = prefs.getString(_kUserIdKey) ?? 'user_default';
    final name = prefs.getString(_kUserNameKey) ?? 'Usuário Fashion';
    final email = prefs.getString(_kUserEmailKey) ?? 'usuario@wardrobe.ai';
    final photo = prefs.getString(_kUserPhotoKey);
    final colorPalette = prefs.getString('auth_user_color_palette');
    final methodStr = prefs.getString(_kAuthMethodKey) ?? 'google';

    final method = methodStr == 'google'
        ? AuthMethod.google
        : methodStr == 'email'
            ? AuthMethod.email
            : AuthMethod.guest;

    final profile = UserProfile(
      id: id,
      displayName: name,
      email: email,
      photoUrl: photo,
      colorPalette: colorPalette,
      authMethod: method,
      isLoggedIn: true,
      lastSyncAt: DateTime.now(),
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    );

    _currentUser = profile;
    await DatabaseService.instance.saveUserProfile(profile);
    return profile;
  }

  /// Login com Google (fluxo seguro, com mock imediato de alta fidelidade e persistência)
  Future<UserProfile> signInWithGoogle({String? customEmail, String? customName}) async {
    final prefs = await SharedPreferences.getInstance();
    final name = customName ?? 'Willy Alves';
    final email = customEmail ?? 'willy.alves@gmail.com';
    const photo = 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80';
    final id = 'google_${email.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}';

    final profile = UserProfile(
      id: id,
      displayName: name,
      email: email,
      photoUrl: photo,
      authMethod: AuthMethod.google,
      isLoggedIn: true,
      lastSyncAt: DateTime.now(),
      createdAt: DateTime.now(),
    );

    await prefs.setBool(_kIsLoggedInKey, true);
    await prefs.setString(_kUserIdKey, id);
    await prefs.setString(_kUserNameKey, name);
    await prefs.setString(_kUserEmailKey, email);
    await prefs.setString(_kUserPhotoKey, photo);
    await prefs.setString(_kAuthMethodKey, 'google');

    _currentUser = profile;
    await DatabaseService.instance.saveUserProfile(profile);
    return profile;
  }

  /// Login com E-mail e Senha
  Future<UserProfile> signInWithEmail({required String email, required String name}) async {
    final prefs = await SharedPreferences.getInstance();
    final id = 'email_${email.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}';

    final profile = UserProfile(
      id: id,
      displayName: name.isEmpty ? 'Usuário Fashion' : name,
      email: email,
      photoUrl: null,
      authMethod: AuthMethod.email,
      isLoggedIn: true,
      lastSyncAt: DateTime.now(),
      createdAt: DateTime.now(),
    );

    await prefs.setBool(_kIsLoggedInKey, true);
    await prefs.setString(_kUserIdKey, id);
    await prefs.setString(_kUserNameKey, profile.displayName);
    await prefs.setString(_kUserEmailKey, email);
    await prefs.remove(_kUserPhotoKey);
    await prefs.setString(_kAuthMethodKey, 'email');

    _currentUser = profile;
    await DatabaseService.instance.saveUserProfile(profile);
    return profile;
  }

  /// Atualiza a cartela de cores do usuário de forma persistente
  Future<void> updateColorPalette(String palette) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_user_color_palette', palette);
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(colorPalette: palette);
      await DatabaseService.instance.saveUserProfile(_currentUser!);
    }
  }

  /// Logout
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await DatabaseService.instance.clearUserProfile();
    _currentUser = UserProfile.guest();
  }
}
