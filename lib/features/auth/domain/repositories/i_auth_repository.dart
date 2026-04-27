import 'package:poker_gambit/features/auth/domain/models/app_user.dart';

abstract class IAuthRepository {
  Stream<AppUser?> get authStateChanges;

  AppUser? get currentUser;

  Future<AppUser> signInWithGoogle();

  Future<AppUser> signInAsGuest();

  Future<AppUser> upgradeGuestToGoogle();

  Future<void> updateDisplayName(String name);

  Future<void> updatePhotoUrl(String photoUrl);
  Future<String> uploadProfileImage(dynamic imageFile);
  Future<void> signOut();
}
