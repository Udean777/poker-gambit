import 'package:card_games/features/auth/domain/models/app_user.dart';

abstract class IAuthRepository {
  Stream<AppUser?> get authStateChanges;

  AppUser? get currentUser;

  Future<AppUser> signInWithGoogle();

  Future<AppUser> signInAsGuest();

  Future<AppUser> upgradeGuestToGoogle();

  Future<void> signOut();
}
