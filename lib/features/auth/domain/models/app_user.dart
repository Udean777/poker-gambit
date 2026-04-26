import 'package:flutter/foundation.dart';

@immutable
class AppUser {
  final String uid;
  final String displayName;
  final String? email;
  final String? photoUrl;
  final bool isGuest;

  const AppUser({
    required this.uid,
    required this.displayName,
    this.email,
    this.photoUrl,
    required this.isGuest,
  });

  AppUser copyWith({
    String? uid,
    String? displayName,
    String? email,
    String? photoUrl,
    bool? isGuest,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      isGuest: isGuest ?? this.isGuest,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
      'isGuest': isGuest,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppUser &&
          runtimeType == other.runtimeType &&
          uid == other.uid &&
          displayName == other.displayName &&
          email == other.email &&
          photoUrl == other.photoUrl &&
          isGuest == other.isGuest;

  @override
  int get hashCode =>
      uid.hashCode ^
      displayName.hashCode ^
      email.hashCode ^
      photoUrl.hashCode ^
      isGuest.hashCode;
}
