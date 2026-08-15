import 'package:flutter_test/flutter_test.dart';

import 'package:pitakapflutter/core/resources/billing_cycle.dart';
import 'package:pitakapflutter/feature/subscription/domain/entities/subscription_entity.dart';
import 'package:pitakapflutter/feature/subscription/presentation/providers/subscription_list_filter.dart';

SubscriptionEntity sub({
  required String name,
  String category = 'entertainment',
  double amount = 100,
  BillingCycle cycle = BillingCycle.monthly,
  DateTime? firstBillDate,
}) {
  return SubscriptionEntity(
    id: name,
    userId: 'uid-1',
    name: name,
    category: category,
    amount: amount,
    billingCycle: cycle,
    firstBillDate: firstBillDate ?? DateTime(2024, 1, 15),
  );
}

List<String> names(List<SubscriptionEntity> subscriptions) {
  return subscriptions.map((s) => s.name).toList();
}

void main() {
  final now = DateTime(2026, 8, 13);

  group('availableCategories', () {
    test('lists only the categories actually present', () {
      final categories = availableCategories([
        sub(name: 'Netflix', category: 'entertainment'),
        sub(name: 'PLDT', category: 'utilities'),
        sub(name: 'Spotify', category: 'entertainment'),
      ]);

      expect(categories, ['entertainment', 'utilities']);
    });

    test('orders them by the canonical category list, not by arrival', () {
      final categories = availableCategories([
        sub(name: 'Gym', category: 'health'),
        sub(name: 'Netflix', category: 'entertainment'),
        sub(name: 'PLDT', category: 'utilities'),
      ]);

      expect(categories, ['entertainment', 'utilities', 'health']);
    });

    test('keeps an unknown category rather than dropping the item', () {
      final categories = availableCategories([
        sub(name: 'Netflix', category: 'entertainment'),
        sub(name: 'Mystery', category: 'zzz-legacy'),
      ]);

      expect(categories, ['entertainment', 'zzz-legacy']);
    });

    test('is empty for an empty list', () {
      expect(availableCategories(const []), isEmpty);
    });
  });

  group('applyListFilter — filtering', () {
    final items = [
      sub(name: 'Netflix', category: 'entertainment'),
      sub(name: 'PLDT', category: 'utilities'),
      sub(name: 'Spotify', category: 'entertainment'),
    ];

    test('a null category keeps everything', () {
      final result = applyListFilter(
        items,
        filter: const SubscriptionListFilter(),
        now: now,
      );

      expect(result, hasLength(3));
    });

    test('a category keeps only that category', () {
      final result = applyListFilter(
        items,
        filter: const SubscriptionListFilter(category: 'entertainment'),
        now: now,
      );

      expect(names(result), ['Netflix', 'Spotify']);
    });

    test('a category with no matches yields an empty list', () {
      final result = applyListFilter(
        items,
        filter: const SubscriptionListFilter(category: 'health'),
        now: now,
      );

      expect(result, isEmpty);
    });

    test('does not mutate the source list', () {
      final source = [sub(name: 'B'), sub(name: 'A')];

      applyListFilter(
        source,
        filter: const SubscriptionListFilter(sort: SubscriptionSort.name),
        now: now,
      );

      expect(names(source), ['B', 'A']);
    });
  });

  group('applyListFilter — sorting', () {
    test('next due orders by the computed due date, not the anchor', () {
      final result = applyListFilter(
        [
          sub(name: 'Sep 5', firstBillDate: DateTime(2024, 1, 5)),
          sub(name: 'Aug 20', firstBillDate: DateTime(2024, 1, 20)),
          sub(name: 'Aug 15', firstBillDate: DateTime(2024, 1, 15)),
        ],
        filter: const SubscriptionListFilter(),
        now: now,
      );

      expect(names(result), ['Aug 15', 'Aug 20', 'Sep 5']);
    });

    test('price sorts on monthly cost so cycles compare fairly', () {
      final result = applyListFilter(
        [
          sub(name: 'Yearly', amount: 6588, cycle: BillingCycle.yearly),
          sub(name: 'Monthly', amount: 1000),
        ],
        filter: const SubscriptionListFilter(
          sort: SubscriptionSort.priceHighToLow,
        ),
        now: now,
      );

      expect(names(result), ['Monthly', 'Yearly']);
    });

    test('price low to high is the exact reverse', () {
      final items = [
        sub(name: 'Cheap', amount: 49),
        sub(name: 'Mid', amount: 549),
        sub(name: 'Dear', amount: 1699),
      ];

      final high = applyListFilter(
        items,
        filter: const SubscriptionListFilter(
          sort: SubscriptionSort.priceHighToLow,
        ),
        now: now,
      );
      final low = applyListFilter(
        items,
        filter: const SubscriptionListFilter(
          sort: SubscriptionSort.priceLowToHigh,
        ),
        now: now,
      );

      expect(names(high), ['Dear', 'Mid', 'Cheap']);
      expect(names(low), high.reversed.map((s) => s.name).toList());
    });

    test('name sorts case-insensitively', () {
      final result = applyListFilter(
        [sub(name: 'apple'), sub(name: 'Banana'), sub(name: 'Cherry')],
        filter: const SubscriptionListFilter(sort: SubscriptionSort.name),
        now: now,
      );

      expect(names(result), ['apple', 'Banana', 'Cherry']);
    });

    test('ties break by name so the order is stable', () {
      final result = applyListFilter(
        [
          sub(name: 'Zeta', amount: 100),
          sub(name: 'Alpha', amount: 100),
          sub(name: 'Mid', amount: 100),
        ],
        filter: const SubscriptionListFilter(
          sort: SubscriptionSort.priceHighToLow,
        ),
        now: now,
      );

      expect(names(result), ['Alpha', 'Mid', 'Zeta']);
    });
  });

  group('applyListFilter — composition', () {
    test('filter and sort apply together', () {
      final result = applyListFilter(
        [
          sub(name: 'Netflix', category: 'entertainment', amount: 549),
          sub(name: 'PLDT', category: 'utilities', amount: 1699),
          sub(name: 'Spotify', category: 'entertainment', amount: 149),
          sub(name: 'YouTube', category: 'entertainment', amount: 239),
        ],
        filter: const SubscriptionListFilter(
          category: 'entertainment',
          sort: SubscriptionSort.priceHighToLow,
        ),
        now: now,
      );

      expect(names(result), ['Netflix', 'YouTube', 'Spotify']);
    });
  });

  group('SubscriptionListFilter', () {
    test('withCategory can clear back to all', () {
      const filter = SubscriptionListFilter(category: 'utilities');

      expect(filter.isFiltered, isTrue);
      expect(filter.withCategory(null).isFiltered, isFalse);
    });

    test('changing one field preserves the other', () {
      const filter = SubscriptionListFilter(category: 'health');

      final sorted = filter.withSort(SubscriptionSort.name);

      expect(sorted.category, 'health');
      expect(sorted.sort, SubscriptionSort.name);
      expect(sorted.withCategory('utilities').sort, SubscriptionSort.name);
    });

    test('defaults to every category, next due first', () {
      const filter = SubscriptionListFilter();

      expect(filter.category, isNull);
      expect(filter.sort, SubscriptionSort.nextDue);
    });

    test('compares by value', () {
      expect(
        const SubscriptionListFilter(category: 'health'),
        const SubscriptionListFilter(category: 'health'),
      );
      expect(
        const SubscriptionListFilter(category: 'health'),
        isNot(const SubscriptionListFilter(category: 'utilities')),
      );
    });
  });
}
