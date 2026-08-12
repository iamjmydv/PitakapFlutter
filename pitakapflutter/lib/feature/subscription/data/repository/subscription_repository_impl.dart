import 'package:pitakapflutter/feature/subscription/data/datasources/subscription_remote_datasource.dart';
import 'package:pitakapflutter/feature/subscription/domain/entities/subscription_entity.dart';
import 'package:pitakapflutter/feature/subscription/domain/repository/subscription_repository.dart';
import 'package:pitakapflutter/feature/subscription/domain/usecases/create_subscription_usecase.dart';
import 'package:pitakapflutter/feature/subscription/domain/usecases/delete_subscription_usecase.dart';
import 'package:pitakapflutter/feature/subscription/domain/usecases/update_subscription_usecase.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final SubscriptionRemoteDatasource remote;

  const SubscriptionRepositoryImpl(this.remote);

  @override
  Stream<List<SubscriptionEntity>> watchSubscriptions(String userId) {
    return remote.watchSubscriptions(userId);
  }

  @override
  Future<void> createSubscription(CreateSubscriptionUseCaseParams params) {
    return remote.createSubscription(params);
  }

  @override
  Future<void> updateSubscription(UpdateSubscriptionUseCaseParams params) {
    return remote.updateSubscription(params);
  }

  @override
  Future<void> deleteSubscription(DeleteSubscriptionUseCaseParams params) {
    return remote.deleteSubscription(params);
  }
}
