import 'package:card_games/features/auth/domain/models/app_user.dart';
import 'package:card_games/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthRepository implements IAuthRepository {
  final FirebaseAuth _firebaseAuth;

  FirebaseAuthRepository({FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  @override
  AppUser? get currentUser => _mapUser(_firebaseAuth.currentUser);

  @override
  Stream<AppUser?> get authStateChanges =>
      _firebaseAuth.authStateChanges().map(_mapUser);

  @override
  Future<AppUser> signInAsGuest() async {
    final credential = await _firebaseAuth.signInAnonymously();
    return _mapUser(credential.user)!;
  }

  Future<AuthCredential> _getGoogleCredential() async {
    // Pastikan tidak ada cached session yang bisa menyebabkan conflict
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {}

    final googleUser = await GoogleSignIn.instance.authenticate();

    final idToken = googleUser.authentication.idToken;
    return GoogleAuthProvider.credential(idToken: idToken);
  }

  @override
  Future<AppUser> signInWithGoogle() async {
    final credential = await _getGoogleCredential();
    final userCredential = await _firebaseAuth.signInWithCredential(credential);
    return _mapUser(userCredential.user)!;
  }

  @override
  Future<AppUser> upgradeGuestToGoogle() async {
    final currentFirebaseUser = _firebaseAuth.currentUser;

    if (currentFirebaseUser == null || !currentFirebaseUser.isAnonymous) {
      return signInWithGoogle();
    }

    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {}

    final googleUser = await GoogleSignIn.instance.authenticate();

    AuthCredential buildCredential() {
      final idToken = googleUser.authentication.idToken;
      return GoogleAuthProvider.credential(idToken: idToken);
    }

    try {
      final userCredential = await currentFirebaseUser
          .linkWithCredential(buildCredential());
      return _mapUser(userCredential.user)!;
    } catch (_) {
      final userCredential = await _firebaseAuth
          .signInWithCredential(buildCredential());
      return _mapUser(userCredential.user)!;
    }
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {}
  }

  AppUser? _mapUser(User? user) {
    if (user == null) return null;
    return AppUser(
      uid: user.uid,
      displayName: user.isAnonymous
          ? 'Guest'
          : (user.displayName ?? user.email ?? 'Player'),
      email: user.email,
      photoUrl: user.photoURL,
      isGuest: user.isAnonymous,
    );
  }
}
