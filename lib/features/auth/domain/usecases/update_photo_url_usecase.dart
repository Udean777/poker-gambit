import 'package:poker_gambit/features/auth/domain/repositories/i_auth_repository.dart';

class UpdatePhotoUrlUseCase {
  final IAuthRepository _repository;

  UpdatePhotoUrlUseCase(this._repository);

  Future<void> call(String photoUrl) => _repository.updatePhotoUrl(photoUrl);
}
