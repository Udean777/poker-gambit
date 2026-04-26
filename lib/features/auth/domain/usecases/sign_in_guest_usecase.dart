import 'package:card_games/features/auth/domain/models/app_user.dart';
import 'package:card_games/features/auth/domain/repositories/i_auth_repository.dart';

class SignInGuestUseCase {
  final IAuthRepository _repository;

  SignInGuestUseCase(this._repository);

  Future<AppUser> call() => _repository.signInAsGuest();
}
