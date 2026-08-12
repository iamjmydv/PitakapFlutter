import 'package:pitakapflutter/core/usecase/usecase.dart';
import 'package:pitakapflutter/feature/subscription/domain/repository/subscription_repository.dart';

class DeleteSubscriptionUseCaseParams {
  final String subscriptionId;

  const DeleteSubscriptionUseCaseParams(this.subscriptionId);
}

class DeleteSubscriptionUseCase
    implements UseCaseWithParams<void, DeleteSubscriptionUseCaseParams> {
  final SubscriptionRepository repository;

  const DeleteSubscriptionUseCase(this.repository);

  @override
  Future<void> call(DeleteSubscriptionUseCaseParams params) {
    return repository.deleteSubscription(params);
  }
}
