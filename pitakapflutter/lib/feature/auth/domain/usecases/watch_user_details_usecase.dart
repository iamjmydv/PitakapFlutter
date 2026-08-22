import 'package:pitakapflutter/feature/auth/domain/entities/user_details_entity.dart';
import 'package:pitakapflutter/feature/auth/domain/repository/auth_repository.dart';

class WatchUserDetailsUseCase {
  final AuthRepository repository;

  const WatchUserDetailsUseCase(this.repository);

  Stream<UserDetailsEntity?> call(String uid) {
    return repository.watchUserDetails(uid);
  }
}
