import 'package:poker_gambit/features/auth/domain/models/app_user.dart';
import 'package:poker_gambit/features/auth/domain/repositories/i_auth_repository.dart';

class SignInGoogleUseCase {
  final IAuthRepository _repository;

  SignInGoogleUseCase(this._repository);

  Future<AppUser> call() => _repository.signInWithGoogle();
}
