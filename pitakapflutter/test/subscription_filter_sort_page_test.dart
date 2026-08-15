import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:pitakapflutter/core/common/common.dart';
import 'package:pitakapflutter/core/resources/billing_cycle.dart';
import 'package:pitakapflutter/core/resources/strings.dart';
import 'package:pitakapflutter/core/router/app_routes.dart';
import 'package:pitakapflutter/feature/subscription/domain/entities/subscription_entity.dart';
import 'package:pitakapflutter/feature/subscription/domain/repository/subscription_repository.dart';
import 'package:pitakapflutter/feature/subscription/presentation/providers/subscription_list_filter.dart';
import 'package:pitakapflutter/feature/subscription/presentation/widgets/subscription_tile.dart';

import 'helpers.dart';

class MockSubscriptionRepository extends Mock
    implements SubscriptionRepository {}

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

void main() {
  late MockSubscriptionRepository repository;

  setUpAll(registerAuthFallbacks);

  setUp(() {
    repository = MockSubscriptionRepository();
  });

  void sizeViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(420, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  Future<void> revealChip(
    WidgetTester tester,
    Finder chip, {
    double delta = 120,
  }) async {
    await tester.scrollUntilVisible(
      chip,
      delta,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
  }

  List<String> visibleNames(WidgetTester tester) {
    return tester
        .widgetList<SubscriptionTile>(find.byType(SubscriptionTile))
        .map((tile) => tile.subscription.name)
        .toList();
  }

  Future<void> pumpList(
    WidgetTester tester,
    Stream<List<SubscriptionEntity>> stream,
  ) async {
    sizeViewport(tester);

    when(() => repository.watchSubscriptions(any())).thenAnswer((_) => stream);

    await pumpAppAt(
      tester,
      AppRoutes.subscriptions,
      signedInUid: 'uid-1',
      subscriptionRepository: repository,
    );
  }

  final mixed = [
    sub(name: 'Netflix', category: 'entertainment', amount: 549),
    sub(name: 'PLDT Fibr', category: 'utilities', amount: 1699),
    sub(name: 'Spotify', category: 'entertainment', amount: 149),
    sub(name: 'iCloud+', category: 'productivity', amount: 49),
  ];

  group('category chips', () {
    testWidgets('shows All plus only the categories actually present', (
      tester,
    ) async {
      await pumpList(tester, Stream.value(mixed));

      expect(find.text(Strings.filterAll), findsOneWidget);
      expect(find.text('Entertainment'), findsOneWidget);
      expect(find.text('Utilities'), findsOneWidget);
      expect(find.text('Health'), findsNothing);

      await revealChip(tester, find.text('Productivity'));
      expect(find.text('Productivity'), findsOneWidget);
    });

    testWidgets('tapping a category narrows the list to it', (tester) async {
      await pumpList(tester, Stream.value(mixed));

      expect(visibleNames(tester), hasLength(4));

      await tester.tap(find.text('Entertainment'));
      await tester.pumpAndSettle();

      expect(visibleNames(tester), ['Netflix', 'Spotify']);
    });

    testWidgets('tapping All restores every subscription', (tester) async {
      await pumpList(tester, Stream.value(mixed));

      await revealChip(tester, find.text('Utilities'));
      await tester.tap(find.text('Utilities'));
      await tester.pumpAndSettle();
      expect(visibleNames(tester), ['PLDT Fibr']);

      await revealChip(tester, find.text(Strings.filterAll), delta: -120);
      await tester.tap(find.text(Strings.filterAll));
      await tester.pumpAndSettle();
      expect(visibleNames(tester), hasLength(4));
    });
  });

  group('sort menu', () {
    testWidgets('the page applies the default next-due sort', (tester) async {
      final items = [
        sub(name: 'Day 28', firstBillDate: DateTime(2024, 1, 28)),
        sub(name: 'Day 2', firstBillDate: DateTime(2024, 1, 2)),
        sub(name: 'Day 17', firstBillDate: DateTime(2024, 1, 17)),
      ];

      await pumpList(tester, Stream.value(items));

      final expected = applyListFilter(
        items,
        filter: const SubscriptionListFilter(),
        now: DateTime.now(),
      ).map((s) => s.name).toList();

      expect(visibleNames(tester), expected);
      expect(visibleNames(tester), isNot(items.map((s) => s.name).toList()));
    });

    testWidgets('price high to low reorders the list', (tester) async {
      await pumpList(tester, Stream.value(mixed));

      await tester.tap(find.byIcon(Icons.swap_vert));
      await tester.pumpAndSettle();

      await tester.tap(find.text(SubscriptionSort.priceHighToLow.label));
      await tester.pumpAndSettle();

      expect(visibleNames(tester), [
        'PLDT Fibr',
        'Netflix',
        'Spotify',
        'iCloud+',
      ]);
    });

    testWidgets('sorting by name is case-insensitive alphabetical', (
      tester,
    ) async {
      await pumpList(tester, Stream.value(mixed));

      await tester.tap(find.byIcon(Icons.swap_vert));
      await tester.pumpAndSettle();

      await tester.tap(find.text(SubscriptionSort.name.label));
      await tester.pumpAndSettle();

      expect(visibleNames(tester), [
        'iCloud+',
        'Netflix',
        'PLDT Fibr',
        'Spotify',
      ]);
    });

    testWidgets('a chosen sort survives a category change', (tester) async {
      await pumpList(tester, Stream.value(mixed));

      await tester.tap(find.byIcon(Icons.swap_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text(SubscriptionSort.priceLowToHigh.label));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Entertainment'));
      await tester.pumpAndSettle();

      expect(visibleNames(tester), ['Spotify', 'Netflix']);
    });
  });

  group('filtered empty state', () {
    testWidgets('emptying the selected category offers a way back', (
      tester,
    ) async {
      final controller = StreamController<List<SubscriptionEntity>>();
      addTearDown(controller.close);

      controller.add(mixed);

      await pumpList(tester, controller.stream);

      await revealChip(tester, find.text('Utilities'));
      await tester.tap(find.text('Utilities'));
      await tester.pumpAndSettle();
      expect(visibleNames(tester), ['PLDT Fibr']);

      controller.add(
        mixed.where((s) => s.category != 'utilities').toList(),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CommonEmptyState), findsOneWidget);
      expect(find.text(Strings.subscriptionsFilterEmptyTitle), findsOneWidget);
      expect(find.text(Strings.subscriptionsEmptyTitle), findsNothing);

      await tester.tap(find.text(Strings.showAllAction));
      await tester.pumpAndSettle();

      expect(visibleNames(tester), hasLength(3));
    });

    testWidgets('an account with no subscriptions keeps the original empty '
        'state and shows no chips', (tester) async {
      await pumpList(tester, Stream.value(const []));

      expect(find.text(Strings.subscriptionsEmptyTitle), findsOneWidget);
      expect(find.text(Strings.filterAll), findsNothing);
    });
  });
}
