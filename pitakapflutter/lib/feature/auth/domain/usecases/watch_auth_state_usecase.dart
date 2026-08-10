import 'package:pitakapflutter/feature/auth/domain/repository/auth_repository.dart';

class WatchAuthStateUseCase {
  final AuthRepository repository;

  const WatchAuthStateUseCase(this.repository);

  Stream<String?> call() => repository.authStateChanges();
}
