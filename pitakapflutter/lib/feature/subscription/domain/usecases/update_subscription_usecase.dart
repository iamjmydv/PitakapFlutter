import 'package:pitakapflutter/core/usecase/usecase.dart';
import 'package:pitakapflutter/feature/subscription/domain/entities/subscription_entity.dart';
import 'package:pitakapflutter/feature/subscription/domain/repository/subscription_repository.dart';

class UpdateSubscriptionUseCaseParams {
  final SubscriptionEntity subscription;

  const UpdateSubscriptionUseCaseParams(this.subscription);
}

class UpdateSubscriptionUseCase
    implements UseCaseWithParams<void, UpdateSubscriptionUseCaseParams> {
  final SubscriptionRepository repository;

  const UpdateSubscriptionUseCase(this.repository);

  @override
  Future<void> call(UpdateSubscriptionUseCaseParams params) {
    return repository.updateSubscription(params);
  }
}
