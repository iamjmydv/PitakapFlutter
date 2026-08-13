import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pitakapflutter/core/error/failure.dart';
import 'package:pitakapflutter/core/providers/subscription_providers.dart';
import 'package:pitakapflutter/feature/subscription/domain/entities/subscription_entity.dart';
import 'package:pitakapflutter/feature/subscription/domain/usecases/create_subscription_usecase.dart';
import 'package:pitakapflutter/feature/subscription/domain/usecases/delete_subscription_usecase.dart';
import 'package:pitakapflutter/feature/subscription/domain/usecases/update_subscription_usecase.dart';
import 'package:pitakapflutter/feature/subscription/presentation/providers/subscription_edit_state.dart';

class SubscriptionEditController extends AsyncNotifier<SubscriptionEditState> {
  @override
  FutureOr<SubscriptionEditState> build() =>
      const SubscriptionEditInitialState();

  bool get isBusy => state.value is SubscriptionEditLoadingState;

  Future<void> create(CreateSubscriptionUseCaseParams params) async {
    await _run(
      () => ref.read(createSubscriptionUseCaseProvider).call(params),
      onSuccess: const SubscriptionEditSuccessState(wasExisting: false),
    );
  }

  Future<void> updateExisting(SubscriptionEntity subscription) async {
    await _run(
      () => ref
          .read(updateSubscriptionUseCaseProvider)
          .call(UpdateSubscriptionUseCaseParams(subscription)),
      onSuccess: const SubscriptionEditSuccessState(wasExisting: true),
    );
  }

  Future<void> delete(String subscriptionId) async {
    await _run(
      () => ref
          .read(deleteSubscriptionUseCaseProvider)
          .call(DeleteSubscriptionUseCaseParams(subscriptionId)),
      onSuccess: const SubscriptionEditDeletedState(),
    );
  }

  Future<void> _run(
    Future<void> Function() action, {
    required SubscriptionEditState onSuccess,
  }) async {
    if (isBusy) return;

    state = const AsyncValue.data(SubscriptionEditLoadingState());

    final result = await AsyncValue.guard(action);

    state = AsyncValue.data(switch (result) {
      AsyncData() => onSuccess,
      AsyncError(:final error) => SubscriptionEditFailedState(
        failureMessage(error),
      ),
      _ => const SubscriptionEditLoadingState(),
    });
  }

  void reset() => state = const AsyncValue.data(SubscriptionEditInitialState());
}

final subscriptionEditControllerProvider =
    AsyncNotifierProvider.autoDispose<
      SubscriptionEditController,
      SubscriptionEditState
    >(SubscriptionEditController.new);
