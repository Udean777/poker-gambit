import 'package:poker_gambit/core/services/connectivity_service.dart';
import 'package:poker_gambit/features/auth/data/repositories/firebase_auth_repository.dart';
import 'package:poker_gambit/features/auth/domain/models/app_user.dart';
import 'package:poker_gambit/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:poker_gambit/features/auth/domain/usecases/sign_in_google_usecase.dart';
import 'package:poker_gambit/features/auth/domain/usecases/sign_in_guest_usecase.dart';
import 'package:poker_gambit/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:poker_gambit/features/auth/domain/usecases/upgrade_guest_usecase.dart';
import 'package:poker_gambit/features/auth/domain/usecases/update_display_name_usecase.dart';
import 'package:poker_gambit/features/auth/domain/usecases/update_photo_url_usecase.dart';
import 'package:poker_gambit/features/auth/domain/usecases/upload_profile_image_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRepositoryProvider = Provider<IAuthRepository>(
  (ref) => FirebaseAuthRepository(),
);

final connectivityServiceProvider = Provider<IConnectivityService>(
  (ref) => ConnectivityService(),
);

// Stream for raw auth changes
final authStateProvider = StreamProvider<AppUser?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

// A notifier for the user profile that stays in sync with auth state
class UserProfileNotifier extends Notifier<AppUser?> {
  AppUser? _manualOverride;

  @override
  AppUser? build() {
    // Watch authStateProvider to keep the profile in sync with the stream
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        // If the stream data matches our manual override, we can clear the override
        if (_manualOverride != null && _manualOverride == user) {
          _manualOverride = null;
        }
        // Return override if present, otherwise stream data
        return _manualOverride ?? user;
      },
      loading: () =>
          _manualOverride ?? ref.read(authRepositoryProvider).currentUser,
      error: (_, _) =>
          _manualOverride ?? ref.read(authRepositoryProvider).currentUser,
    );
  }

  void updateProfile(AppUser user) {
    _manualOverride = user;
    state = user;
  }
}

final userProfileProvider = NotifierProvider<UserProfileNotifier, AppUser?>(
  UserProfileNotifier.new,
);

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

final updateDisplayNameUseCaseProvider = Provider((ref) {
  return UpdateDisplayNameUseCase(ref.watch(authRepositoryProvider));
});

final updatePhotoUrlUseCaseProvider = Provider((ref) {
  return UpdatePhotoUrlUseCase(ref.watch(authRepositoryProvider));
});

final uploadProfileImageUseCaseProvider = Provider((ref) {
  return UploadProfileImageUseCase(ref.watch(authRepositoryProvider));
});

class AuthNotifier extends StateNotifier<AsyncValue<AppUser?>> {
  final SignInGoogleUseCase _signInGoogle;
  final SignInGuestUseCase _signInGuest;
  final SignOutUseCase _signOut;
  final UpgradeGuestUseCase _upgradeGuest;
  final UpdateDisplayNameUseCase _updateDisplayName;
  final UpdatePhotoUrlUseCase _updatePhotoUrl;
  final UploadProfileImageUseCase _uploadProfileImage;
  final Ref _ref;

  AuthNotifier({
    required SignInGoogleUseCase signInGoogle,
    required SignInGuestUseCase signInGuest,
    required SignOutUseCase signOut,
    required UpgradeGuestUseCase upgradeGuest,
    required UpdateDisplayNameUseCase updateDisplayName,
    required UpdatePhotoUrlUseCase updatePhotoUrl,
    required UploadProfileImageUseCase uploadProfileImage,
    required Ref ref,
  }) : _signInGoogle = signInGoogle,
       _signInGuest = signInGuest,
       _signOut = signOut,
       _upgradeGuest = upgradeGuest,
       _updateDisplayName = updateDisplayName,
       _updatePhotoUrl = updatePhotoUrl,
       _uploadProfileImage = uploadProfileImage,
       _ref = ref,
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

  Future<void> updateDisplayName(String name) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _updateDisplayName(name);

      // Get current user and update locally for immediate UI feedback
      final currentUser = _ref.read(userProfileProvider);
      if (currentUser != null) {
        final updatedUser = currentUser.copyWith(displayName: name);
        _ref.read(userProfileProvider.notifier).updateProfile(updatedUser);
        return updatedUser;
      }

      return _ref.read(authRepositoryProvider).currentUser;
    });
  }

  Future<void> updatePhotoUrl(String photoUrl) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _updatePhotoUrl(photoUrl);

      // Get current user and update locally for immediate UI feedback
      final currentUser = _ref.read(userProfileProvider);
      if (currentUser != null) {
        final updatedUser = currentUser.copyWith(photoUrl: photoUrl);
        _ref.read(userProfileProvider.notifier).updateProfile(updatedUser);
        return updatedUser;
      }

      return _ref.read(authRepositoryProvider).currentUser;
    });
  }

  Future<void> uploadProfileImage(dynamic imageFile) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _uploadProfileImage(imageFile);
      return _ref.read(authRepositoryProvider).currentUser;
    });
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<AppUser?>>((ref) {
      return AuthNotifier(
        signInGoogle: ref.watch(signInGoogleUseCaseProvider),
        signInGuest: ref.watch(signInGuestUseCaseProvider),
        signOut: ref.watch(signOutUseCaseProvider),
        upgradeGuest: ref.watch(upgradeGuestUseCaseProvider),
        updateDisplayName: ref.watch(updateDisplayNameUseCaseProvider),
        updatePhotoUrl: ref.watch(updatePhotoUrlUseCaseProvider),
        uploadProfileImage: ref.watch(uploadProfileImageUseCaseProvider),
        ref: ref,
      );
    });
