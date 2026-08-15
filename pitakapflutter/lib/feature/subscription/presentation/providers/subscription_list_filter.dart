import 'package:pitakapflutter/core/resources/constants.dart';
import 'package:pitakapflutter/feature/subscription/domain/entities/subscription_entity.dart';

enum SubscriptionSort {
  nextDue('Next due'),
  priceHighToLow('Price: high to low'),
  priceLowToHigh('Price: low to high'),
  name('Name');

  final String label;

  const SubscriptionSort(this.label);
}

class SubscriptionListFilter {
  final String? category;
  final SubscriptionSort sort;

  const SubscriptionListFilter({
    this.category,
    this.sort = SubscriptionSort.nextDue,
  });

  bool get isFiltered => category != null;

  SubscriptionListFilter withCategory(String? value) {
    return SubscriptionListFilter(category: value, sort: sort);
  }

  SubscriptionListFilter withSort(SubscriptionSort value) {
    return SubscriptionListFilter(category: category, sort: value);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is SubscriptionListFilter &&
            other.category == category &&
            other.sort == sort;
  }

  @override
  int get hashCode => Object.hash(category, sort);
}

List<String> availableCategories(List<SubscriptionEntity> subscriptions) {
  final present = subscriptions.map((s) => s.category).toSet();

  final known = Constants.subscriptionCategories
      .where(present.contains)
      .toList();
  final unknown = present.where((c) => !known.contains(c)).toList()..sort();

  return [...known, ...unknown];
}

List<SubscriptionEntity> applyListFilter(
  List<SubscriptionEntity> subscriptions, {
  required SubscriptionListFilter filter,
  required DateTime now,
}) {
  final category = filter.category;

  final result = category == null
      ? [...subscriptions]
      : subscriptions.where((s) => s.category == category).toList();

  result.sort((a, b) {
    final primary = switch (filter.sort) {
      SubscriptionSort.nextDue => a
          .nextDueDateAsOf(now)
          .compareTo(b.nextDueDateAsOf(now)),
      SubscriptionSort.priceHighToLow => b.monthlyCost.compareTo(a.monthlyCost),
      SubscriptionSort.priceLowToHigh => a.monthlyCost.compareTo(b.monthlyCost),
      SubscriptionSort.name => 0,
    };

    if (primary != 0) return primary;

    return a.name.toLowerCase().compareTo(b.name.toLowerCase());
  });

  return result;
}
