import 'package:pitakapflutter/feature/subscription/domain/entities/subscription_entity.dart';
import 'package:pitakapflutter/feature/subscription/domain/repository/subscription_repository.dart';

class WatchSubscriptionsUseCase {
  final SubscriptionRepository repository;

  const WatchSubscriptionsUseCase(this.repository);

  Stream<List<SubscriptionEntity>> call(String userId) {
    return repository.watchSubscriptions(userId);
  }
}
