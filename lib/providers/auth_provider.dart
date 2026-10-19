import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/cloud_sync_service.dart';

class AuthState {
  final UserProfile user;
  final bool isLoading;
  final bool isSyncing;
  final String? syncMessage;
  final String? errorMessage;

  const AuthState({
    required this.user,
    this.isLoading = false,
    this.isSyncing = false,
    this.syncMessage,
    this.errorMessage,
  });

  AuthState copyWith({
    UserProfile? user,
    bool? isLoading,
    bool? isSyncing,
    String? syncMessage,
    String? errorMessage,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      isSyncing: isSyncing ?? this.isSyncing,
      syncMessage: syncMessage,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier()
      : super(AuthState(
          user: UserProfile.guest(),
          isLoading: true,
        )) {
    _init();
  }

  final AuthService _authService = AuthService.instance;
  final CloudSyncService _cloudSync = CloudSyncService.instance;

  Future<void> _init() async {
    try {
      final user = await _authService.loadCurrentUser();
      state = state.copyWith(user: user, isLoading: false);
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> signInWithGoogle({String? name, String? email}) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      final profile = await _authService.signInWithGoogle(
        customName: name,
        customEmail: email,
      );
      state = state.copyWith(user: profile, isLoading: false);
      // Sincroniza dados com a nuvem automaticamente após login
      await syncToCloud();
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Falha no login Google: $e',
      );
      return false;
    }
  }

  Future<bool> signInWithEmail({required String email, required String name}) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      final profile = await _authService.signInWithEmail(email: email, name: name);
      state = state.copyWith(user: profile, isLoading: false);
      await syncToCloud();
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Falha no login por email: $e',
      );
      return false;
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    await _authService.signOut();
    state = state.copyWith(
      user: UserProfile.guest(),
      isLoading: false,
      syncMessage: null,
    );
  }

  Future<void> syncToCloud() async {
    state = state.copyWith(isSyncing: true, errorMessage: null);
    final result = await _cloudSync.backupToCloud(userId: state.user.id);
    state = state.copyWith(
      isSyncing: false,
      syncMessage: result.message,
      user: state.user.copyWith(lastSyncAt: result.syncTime),
    );
  }

  Future<void> restoreFromCloud() async {
    state = state.copyWith(isSyncing: true, errorMessage: null);
    final result = await _cloudSync.restoreFromCloud(userId: state.user.id);
    state = state.copyWith(
      isSyncing: false,
      syncMessage: result.message,
    );
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
