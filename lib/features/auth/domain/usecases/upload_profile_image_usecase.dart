import 'package:poker_gambit/features/auth/domain/repositories/i_auth_repository.dart';

class UploadProfileImageUseCase {
  final IAuthRepository _repository;

  UploadProfileImageUseCase(this._repository);

  Future<String> call(dynamic imageFile) =>
      _repository.uploadProfileImage(imageFile);
}
