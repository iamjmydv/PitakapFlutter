import 'package:flutter_test/flutter_test.dart';

import 'package:pitakapflutter/core/resources/billing_cycle.dart';
import 'package:pitakapflutter/core/resources/constants.dart';
import 'package:pitakapflutter/feature/subscription/domain/entities/subscription_entity.dart';

SubscriptionEntity subscription({
  String id = 'sub-1',
  double amount = 549,
  BillingCycle billingCycle = BillingCycle.monthly,
  DateTime? firstBillDate,
}) {
  return SubscriptionEntity(
    id: id,
    userId: 'user-1',
    name: 'Netflix',
    category: 'entertainment',
    amount: amount,
    billingCycle: billingCycle,
    firstBillDate: firstBillDate ?? DateTime(2026, 1, 31),
  );
}

void main() {
  group('defaults', () {
    test('fills the optional fields from Constants', () {
      final sub = subscription();

      expect(sub.currency, Constants.defaultCurrency);
      expect(sub.reminderDaysBefore, Constants.defaultReminderDaysBefore);
      expect(sub.billingCycle, BillingCycle.monthly);
      expect(sub.isActive, isTrue);
      expect(sub.notes, isEmpty);
      expect(sub.createdAt, isNull);
      expect(sub.updatedAt, isNull);
    });
  });

  group('yearlyCost', () {
    test('multiplies by the periods in a year for every cycle', () {
      expect(
        subscription(amount: 100, billingCycle: BillingCycle.weekly).yearlyCost,
        5200,
      );
      expect(
        subscription(amount: 100, billingCycle: BillingCycle.monthly).yearlyCost,
        1200,
      );
      expect(
        subscription(
          amount: 100,
          billingCycle: BillingCycle.quarterly,
        ).yearlyCost,
        400,
      );
      expect(
        subscription(amount: 100, billingCycle: BillingCycle.yearly).yearlyCost,
        100,
      );
    });
  });

  group('monthlyCost', () {
    test('normalises a monthly subscription to itself', () {
      expect(
        subscription(amount: 549, billingCycle: BillingCycle.monthly)
            .monthlyCost,
        549,
      );
    });

    test('normalises weekly as amount x 52 / 12', () {
      expect(
        subscription(amount: 120, billingCycle: BillingCycle.weekly).monthlyCost,
        closeTo(520, 0.0001),
      );
    });

    test('normalises quarterly as amount / 3', () {
      expect(
        subscription(amount: 900, billingCycle: BillingCycle.quarterly)
            .monthlyCost,
        closeTo(300, 0.0001),
      );
    });

    test('normalises yearly as amount / 12', () {
      expect(
        subscription(amount: 1200, billingCycle: BillingCycle.yearly)
            .monthlyCost,
        closeTo(100, 0.0001),
      );
    });

    test('stays consistent with yearlyCost for every cycle', () {
      for (final cycle in BillingCycle.values) {
        final sub = subscription(amount: 777, billingCycle: cycle);

        expect(
          sub.monthlyCost * 12,
          closeTo(sub.yearlyCost, 0.0001),
          reason: cycle.wireValue,
        );
      }
    });

    test('returns zero for a zero amount', () {
      expect(subscription(amount: 0).monthlyCost, 0);
    });
  });

  group('nextDueDateAsOf', () {
    test('returns the first bill date while it is still ahead', () {
      final sub = subscription(firstBillDate: DateTime(2026, 12, 1));

      expect(sub.nextDueDateAsOf(DateTime(2026, 8, 12)), DateTime(2026, 12, 1));
    });

    test('clamps a 31st anchor to the end of a short month', () {
      final sub = subscription(firstBillDate: DateTime(2026, 1, 31));

      expect(sub.nextDueDateAsOf(DateTime(2026, 2, 1)), DateTime(2026, 2, 28));
    });

    test('honours the billing cycle', () {
      final sub = subscription(
        firstBillDate: DateTime(2026, 1, 15),
        billingCycle: BillingCycle.quarterly,
      );

      expect(sub.nextDueDateAsOf(DateTime(2026, 5, 1)), DateTime(2026, 7, 15));
    });
  });

  group('daysUntilNextDueAsOf', () {
    test('returns zero when the bill falls due today', () {
      final sub = subscription(firstBillDate: DateTime(2026, 8, 12));

      expect(sub.daysUntilNextDueAsOf(DateTime(2026, 8, 12, 22)), 0);
    });

    test('counts whole days to the next renewal', () {
      final sub = subscription(firstBillDate: DateTime(2026, 8, 20));

      expect(sub.daysUntilNextDueAsOf(DateTime(2026, 8, 12)), 8);
    });

    test('rolls into the following period once the day has passed', () {
      final sub = subscription(firstBillDate: DateTime(2026, 8, 1));

      expect(sub.daysUntilNextDueAsOf(DateTime(2026, 8, 12)), 20);
    });
  });

  group('upcomingDueDatesAsOf', () {
    test('returns three renewals by default', () {
      final sub = subscription(firstBillDate: DateTime(2026, 8, 12));

      expect(sub.upcomingDueDatesAsOf(DateTime(2026, 8, 12)), [
        DateTime(2026, 8, 12),
        DateTime(2026, 9, 12),
        DateTime(2026, 10, 12),
      ]);
    });

    test('respects an explicit count', () {
      final sub = subscription(
        firstBillDate: DateTime(2026, 8, 12),
        billingCycle: BillingCycle.yearly,
      );

      expect(
        sub.upcomingDueDatesAsOf(DateTime(2026, 8, 12), count: 2),
        [DateTime(2026, 8, 12), DateTime(2027, 8, 12)],
      );
    });
  });

  group('equality', () {
    test('two identical subscriptions are equal and share a hash code', () {
      final first = subscription();
      final second = subscription();

      expect(first, second);
      expect(first.hashCode, second.hashCode);
    });

    test('a different id breaks equality', () {
      expect(subscription(id: 'sub-1'), isNot(subscription(id: 'sub-2')));
    });

    test('a different amount breaks equality', () {
      expect(subscription(amount: 549), isNot(subscription(amount: 649)));
    });

    test('a different billing cycle breaks equality', () {
      expect(
        subscription(billingCycle: BillingCycle.monthly),
        isNot(subscription(billingCycle: BillingCycle.yearly)),
      );
    });
  });
}
