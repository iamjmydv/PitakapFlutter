import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:pitakapflutter/core/error/failure.dart';
import 'package:pitakapflutter/core/resources/billing_cycle.dart';
import 'package:pitakapflutter/core/resources/strings.dart';
import 'package:pitakapflutter/core/router/app_routes.dart';
import 'package:pitakapflutter/feature/subscription/domain/entities/subscription_entity.dart';
import 'package:pitakapflutter/feature/subscription/domain/repository/subscription_repository.dart';
import 'package:pitakapflutter/feature/subscription/domain/usecases/delete_subscription_usecase.dart';
import 'package:pitakapflutter/feature/subscription/presentation/subscription_detail_page.dart';
import 'package:pitakapflutter/feature/subscription/presentation/widgets/subscription_tile.dart';

import 'helpers.dart';

class MockSubscriptionRepository extends Mock
    implements SubscriptionRepository {}

SubscriptionEntity sub({
  String id = 'sub-1',
  String name = 'Netflix',
  String category = 'entertainment',
  double amount = 549,
  BillingCycle cycle = BillingCycle.monthly,
  int reminderDaysBefore = 3,
  String notes = '',
  DateTime? firstBillDate,
}) {
  return SubscriptionEntity(
    id: id,
    userId: 'uid-1',
    name: name,
    category: category,
    amount: amount,
    billingCycle: cycle,
    reminderDaysBefore: reminderDaysBefore,
    notes: notes,
    firstBillDate: firstBillDate ?? DateTime(2024, 1, 15),
  );
}

Finder dialogAction(String label) {
  return find.descendant(
    of: find.byType(AlertDialog),
    matching: find.text(label),
  );
}

void main() {
  late MockSubscriptionRepository repository;

  setUpAll(() {
    registerAuthFallbacks();
    registerFallbackValue(const DeleteSubscriptionUseCaseParams('sub-1'));
  });

  setUp(() {
    repository = MockSubscriptionRepository();
    when(() => repository.deleteSubscription(any())).thenAnswer((_) async {});
  });

  void sizeViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(420, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  Future<void> pumpDetail(
    WidgetTester tester,
    List<SubscriptionEntity> items, {
    String id = 'sub-1',
  }) async {
    sizeViewport(tester);

    when(
      () => repository.watchSubscriptions(any()),
    ).thenAnswer((_) => Stream.value(items));

    await pumpAppAt(
      tester,
      AppRoutes.subscriptionDetailPath(id),
      signedInUid: 'uid-1',
      subscriptionRepository: repository,
    );
  }

  group('SubscriptionDetailPage', () {
    testWidgets('shows the name, category and billing cycle', (tester) async {
      await pumpDetail(tester, [sub()]);

      expect(find.text(Strings.subscriptionDetailTitle), findsOneWidget);
      expect(find.text('Netflix'), findsOneWidget);
      expect(find.text('Entertainment · Monthly'), findsOneWidget);
    });

    testWidgets('shows the monthly and yearly cost side by side', (
      tester,
    ) async {
      await pumpDetail(tester, [sub(amount: 549)]);

      expect(find.text('₱549.00'), findsOneWidget);
      expect(find.text(Strings.perMonthLabel), findsOneWidget);
      expect(find.text('₱6,588'), findsOneWidget);
      expect(find.text(Strings.perYearLabel), findsOneWidget);
    });

    testWidgets('derives the yearly cost from the billing cycle', (
      tester,
    ) async {
      await pumpDetail(tester, [
        sub(amount: 1200, cycle: BillingCycle.quarterly),
      ]);

      expect(find.text('₱4,800'), findsOneWidget);
      expect(find.text('₱400.00'), findsOneWidget);
    });

    testWidgets('shows the reminder and the first bill date', (tester) async {
      await pumpDetail(tester, [
        sub(reminderDaysBefore: 3, firstBillDate: DateTime(2024, 1, 15)),
      ]);

      expect(find.text(Strings.reminderRowLabel), findsOneWidget);
      expect(find.text('3 days before'), findsOneWidget);
      expect(find.text(Strings.firstBilledLabel), findsOneWidget);
      expect(find.text('Jan 15, 2024'), findsOneWidget);
    });

    testWidgets('lists the next three computed renewals', (tester) async {
      final entity = sub();
      await pumpDetail(tester, [entity]);

      final renewals = entity.upcomingDueDatesAsOf(DateTime.now(), count: 3);

      expect(find.text(Strings.upcomingRenewalsLabel), findsOneWidget);
      expect(find.byIcon(Icons.calendar_today_outlined), findsNWidgets(3));

      for (final renewal in renewals) {
        expect(
          find.text(SubscriptionDetailPage.dateFormat.format(renewal)),
          findsWidgets,
        );
      }
    });

    testWidgets('hides the notes row when there are no notes', (tester) async {
      await pumpDetail(tester, [sub(notes: '')]);

      expect(find.text(Strings.subscriptionNotesLabel), findsNothing);
    });

    testWidgets('shows the notes row when notes exist', (tester) async {
      await pumpDetail(tester, [sub(notes: 'Shared with family')]);

      expect(find.text(Strings.subscriptionNotesLabel), findsOneWidget);
      expect(find.text('Shared with family'), findsOneWidget);
    });

    testWidgets('reports an unknown id instead of rendering an empty page', (
      tester,
    ) async {
      await pumpDetail(tester, [sub(id: 'sub-1')], id: 'gone');

      expect(find.text(Strings.subscriptionNotFound), findsOneWidget);
      expect(find.text(Strings.editAction), findsNothing);
    });
  });

  group('list to detail', () {
    testWidgets('tapping a tile opens its detail page', (tester) async {
      sizeViewport(tester);

      when(() => repository.watchSubscriptions(any())).thenAnswer(
        (_) => Stream.value([sub(id: 'sub-1', name: 'Netflix')]),
      );

      await pumpAppAt(
        tester,
        AppRoutes.subscriptions,
        signedInUid: 'uid-1',
        subscriptionRepository: repository,
      );

      await tester.tap(find.byType(SubscriptionTile));
      await tester.pumpAndSettle();

      expect(find.text(Strings.subscriptionDetailTitle), findsOneWidget);
      expect(find.text(Strings.upcomingRenewalsLabel), findsOneWidget);
    });
  });

  group('delete from the detail page', () {
    testWidgets('asks for confirmation before deleting', (tester) async {
      await pumpDetail(tester, [sub()]);

      await tester.tap(find.text(Strings.deleteAction));
      await tester.pumpAndSettle();

      expect(find.text(Strings.deleteSubscriptionTitle), findsOneWidget);
      verifyNever(() => repository.deleteSubscription(any()));
    });

    testWidgets('cancelling keeps the subscription', (tester) async {
      await pumpDetail(tester, [sub()]);

      await tester.tap(find.text(Strings.deleteAction));
      await tester.pumpAndSettle();

      await tester.tap(dialogAction(Strings.cancelAction));
      await tester.pumpAndSettle();

      verifyNever(() => repository.deleteSubscription(any()));
      expect(find.text('Netflix'), findsOneWidget);
    });

    testWidgets('confirming deletes and pops back to the list', (tester) async {
      sizeViewport(tester);

      when(
        () => repository.watchSubscriptions(any()),
      ).thenAnswer((_) => Stream.value([sub(id: 'sub-1')]));

      await pumpAppAt(
        tester,
        AppRoutes.subscriptions,
        signedInUid: 'uid-1',
        subscriptionRepository: repository,
      );

      await tester.tap(find.byType(SubscriptionTile));
      await tester.pumpAndSettle();

      await tester.tap(find.text(Strings.deleteAction));
      await tester.pumpAndSettle();

      await tester.tap(dialogAction(Strings.deleteAction));
      await tester.pumpAndSettle();

      final captured =
          verify(
                () => repository.deleteSubscription(captureAny()),
              ).captured.single
              as DeleteSubscriptionUseCaseParams;
      expect(captured.subscriptionId, 'sub-1');

      expect(find.text(Strings.subscriptionDetailTitle), findsNothing);
      expect(find.text(Strings.subscriptionsTitle), findsOneWidget);
      expect(find.textContaining(Strings.subscriptionDeleted), findsOneWidget);
    });

    testWidgets('a failed delete keeps the page and reports the error', (
      tester,
    ) async {
      when(
        () => repository.deleteSubscription(any()),
      ).thenThrow(const NetworkFailure('No internet connection'));

      await pumpDetail(tester, [sub()]);

      await tester.tap(find.text(Strings.deleteAction));
      await tester.pumpAndSettle();

      await tester.tap(dialogAction(Strings.deleteAction));
      await tester.pumpAndSettle();

      expect(find.text('No internet connection'), findsOneWidget);
      expect(find.text(Strings.subscriptionDetailTitle), findsOneWidget);
    });
  });
}
