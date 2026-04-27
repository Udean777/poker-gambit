import 'package:poker_gambit/features/auth/domain/repositories/i_auth_repository.dart';

class UpdateDisplayNameUseCase {
  final IAuthRepository _repository;

  UpdateDisplayNameUseCase(this._repository);

  Future<void> call(String name) async {
    if (name.trim().isEmpty) {
      throw Exception('Display name cannot be empty');
    }
    return _repository.updateDisplayName(name);
  }
}
