import 'package:card_games/core/services/connectivity_service.dart';
import 'package:card_games/features/auth/data/repositories/firebase_auth_repository.dart';
import 'package:card_games/features/auth/domain/models/app_user.dart';
import 'package:card_games/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:card_games/features/auth/domain/usecases/sign_in_google_usecase.dart';
import 'package:card_games/features/auth/domain/usecases/sign_in_guest_usecase.dart';
import 'package:card_games/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:card_games/features/auth/domain/usecases/upgrade_guest_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRepositoryProvider = Provider<IAuthRepository>(
  (ref) => FirebaseAuthRepository(),
);

final connectivityServiceProvider = Provider<IConnectivityService>(
  (ref) => ConnectivityService(),
);

final authStateProvider = StreamProvider<AppUser?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

final signInGoogleUseCaseProvider = Provider((ref) {
  return SignInGoogleUseCase(ref.watch(authRepositoryProvider));
});

final signInGuestUseCaseProvider = Provider((ref) {
  return SignInGuestUseCase(ref.watch(authRepositoryProvider));
});

final signOutUseCaseProvider = Provider((ref) {
  return SignOutUseCase(ref.watch(authRepositoryProvider));
});

final upgradeGuestUseCaseProvider = Provider((ref) {
  return UpgradeGuestUseCase(ref.watch(authRepositoryProvider));
});

class AuthNotifier extends StateNotifier<AsyncValue<AppUser?>> {
  final SignInGoogleUseCase _signInGoogle;
  final SignInGuestUseCase _signInGuest;
  final SignOutUseCase _signOut;
  final UpgradeGuestUseCase _upgradeGuest;

  AuthNotifier({
    required SignInGoogleUseCase signInGoogle,
    required SignInGuestUseCase signInGuest,
    required SignOutUseCase signOut,
    required UpgradeGuestUseCase upgradeGuest,
  })  : _signInGoogle = signInGoogle,
        _signInGuest = signInGuest,
        _signOut = signOut,
        _upgradeGuest = upgradeGuest,
        super(const AsyncValue.data(null));

  Future<void> signInAsGuest() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _signInGuest());
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _signInGoogle());
  }

  Future<void> upgradeToGoogle() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _upgradeGuest());
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    await AsyncValue.guard(() => _signOut());
    state = const AsyncValue.data(null);
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<AppUser?>>((ref) {
  return AuthNotifier(
    signInGoogle: ref.watch(signInGoogleUseCaseProvider),
    signInGuest: ref.watch(signInGuestUseCaseProvider),
    signOut: ref.watch(signOutUseCaseProvider),
    upgradeGuest: ref.watch(upgradeGuestUseCaseProvider),
  );
});
