import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:poker_gambit/core/config/app_config.dart';
import 'package:poker_gambit/features/auth/domain/models/app_user.dart';
import 'package:poker_gambit/features/auth/domain/repositories/i_auth_repository.dart';

class FirebaseAuthRepository implements IAuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final GoogleSignIn _googleSignIn;

  FirebaseAuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
    GoogleSignIn? googleSignIn,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _storage = storage ?? FirebaseStorage.instance,
       _googleSignIn =
           googleSignIn ??
           GoogleSignIn(clientId: kIsWeb ? AppConfig.googleWebClientId : null);

  @override
  AppUser? get currentUser => _mapUser(_auth.currentUser);

  @override
  Stream<AppUser?> get authStateChanges =>
      _auth.authStateChanges().map(_mapUser);

  @override
  Future<AppUser> signInAsGuest() async {
    try {
      final credential = await _auth.signInAnonymously();
      final user = _mapUser(credential.user)!;
      await _syncToFirestore(user);
      return user;
    } catch (e) {
      debugPrint('[Auth] Guest Sign-in Error: $e');
      rethrow;
    }
  }

  @override
  Future<AppUser> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw Exception('Login dibatalkan');

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        await _updateUserProfile(user, googleUser);
      }

      return _mapUser(_auth.currentUser)!;
    } catch (e) {
      debugPrint('[Auth] Google Sign-in Error: $e');
      rethrow;
    }
  }

  @override
  Future<AppUser> upgradeGuestToGoogle() async {
    final user = _auth.currentUser;

    // Jika tidak ada user atau sudah bukan guest, lakukan sign in biasa
    if (user == null || !user.isAnonymous) {
      return signInWithGoogle();
    }

    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw Exception('Login dibatalkan');

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      try {
        // Coba hubungkan akun guest ke google
        final userCredential = await user.linkWithCredential(credential);
        if (userCredential.user != null) {
          await _updateUserProfile(userCredential.user!, googleUser);
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'credential-already-in-use') {
          // Jika email google sudah terdaftar, login langsung ke akun tersebut
          final userCredential = await _auth.signInWithCredential(credential);
          if (userCredential.user != null) {
            await _updateUserProfile(userCredential.user!, googleUser);
          }
        } else {
          rethrow;
        }
      }

      return _mapUser(_auth.currentUser)!;
    } catch (e) {
      debugPrint('[Auth] Upgrade Error: $e');
      rethrow;
    }
  }

  Future<void> _updateUserProfile(
    User user,
    GoogleSignInAccount googleUser,
  ) async {
    // Sync profile data from Google if missing
    bool needsUpdate = false;
    String? displayName = user.displayName;
    String? photoUrl = user.photoURL;

    if (displayName == null ||
        displayName == 'Guest' ||
        displayName.startsWith('Player-')) {
      displayName = googleUser.displayName;
      needsUpdate = true;
    }
    if (photoUrl == null) {
      photoUrl = googleUser.photoUrl;
      needsUpdate = true;
    }

    if (needsUpdate) {
      await user.updateDisplayName(displayName);
      await user.updatePhotoURL(photoUrl);
      await user.reload();
    }

    // Always sync to Firestore
    await _syncToFirestore(_mapUser(_auth.currentUser)!);
  }

  @override
  Future<void> updateDisplayName(String name) async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.updateDisplayName(name);
      await user.reload();
      await _syncToFirestore(_mapUser(_auth.currentUser)!);
    }
  }

  @override
  Future<void> updatePhotoUrl(String photoUrl) async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.updatePhotoURL(photoUrl);
      await user.reload();
      await _syncToFirestore(_mapUser(_auth.currentUser)!);
    }
  }

  @override
  Future<String> uploadProfileImage(dynamic imageFile) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    File file;
    if (imageFile is File) {
      file = imageFile;
    } else {
      file = File(imageFile.path);
    }

    final storageRef = _storage
        .ref()
        .child('profile_pictures')
        .child('${user.uid}.jpg');

    await storageRef.putFile(file);
    final downloadUrl = await storageRef.getDownloadURL();

    await updatePhotoUrl(downloadUrl);
    return downloadUrl;
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  Future<void> _syncToFirestore(AppUser user) async {
    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(user.toMap(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('[Auth] Firestore Sync Error: $e');
    }
  }

  AppUser? _mapUser(User? user) {
    if (user == null) return null;

    String? googlePhotoUrl;
    for (final profile in user.providerData) {
      if (profile.providerId == 'google.com') {
        googlePhotoUrl = profile.photoURL;
        break;
      }
    }

    return AppUser(
      uid: user.uid,
      displayName:
          user.displayName ??
          (user.isAnonymous ? 'Guest' : 'Player-${user.uid.substring(0, 6)}'),
      email: user.email,
      photoUrl: user.photoURL,
      googlePhotoUrl: googlePhotoUrl,
      isGuest: user.isAnonymous,
    );
  }
}
