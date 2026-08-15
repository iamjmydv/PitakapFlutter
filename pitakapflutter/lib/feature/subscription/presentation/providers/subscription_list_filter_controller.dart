import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pitakapflutter/feature/subscription/presentation/providers/subscription_list_filter.dart';

class SubscriptionListFilterController extends Notifier<SubscriptionListFilter> {
  @override
  SubscriptionListFilter build() => const SubscriptionListFilter();

  void selectCategory(String? category) {
    state = state.withCategory(category);
  }

  void selectSort(SubscriptionSort sort) {
    state = state.withSort(sort);
  }

  void clear() => state = const SubscriptionListFilter();
}

final subscriptionListFilterProvider =
    NotifierProvider<SubscriptionListFilterController, SubscriptionListFilter>(
      SubscriptionListFilterController.new,
    );
