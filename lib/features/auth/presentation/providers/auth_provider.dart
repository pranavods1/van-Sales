import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';

// 1. ApiClient Provider
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

// 2. AuthRepository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthRepositoryImpl(apiClient);
});

// 3. Auth Notifier Provider (Strict Riverpod 3.0 Standard)
final authStateProvider = NotifierProvider<AuthNotifier, AsyncValue<void>>(() {
  return AuthNotifier();
});

class AuthNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  Future<bool> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.login(email, password);
      state = const AsyncValue.data(null);
      return true; // Success
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false; // Failed
    }
  }
}

