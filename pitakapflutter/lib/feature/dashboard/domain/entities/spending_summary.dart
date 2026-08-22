import 'package:pitakapflutter/feature/subscription/domain/entities/subscription_entity.dart';

class UpcomingPayment {
  final SubscriptionEntity subscription;
  final DateTime dueDate;
  final int daysUntil;

  const UpcomingPayment({
    required this.subscription,
    required this.dueDate,
    required this.daysUntil,
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is UpcomingPayment &&
            other.subscription == subscription &&
            other.dueDate == dueDate &&
            other.daysUntil == daysUntil;
  }

  @override
  int get hashCode => Object.hash(subscription, dueDate, daysUntil);
}

class SpendingSummary {
  final double spentToday;
  final double monthlySubscriptionCost;
  final double yearlySubscriptionCost;
  final int activeSubscriptionCount;
  final List<UpcomingPayment> upcomingPayments;

  const SpendingSummary({
    required this.spentToday,
    required this.monthlySubscriptionCost,
    required this.yearlySubscriptionCost,
    required this.activeSubscriptionCount,
    required this.upcomingPayments,
  });

  static const SpendingSummary empty = SpendingSummary(
    spentToday: 0,
    monthlySubscriptionCost: 0,
    yearlySubscriptionCost: 0,
    activeSubscriptionCount: 0,
    upcomingPayments: [],
  );

  bool get hasSubscriptions => activeSubscriptionCount > 0;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is SpendingSummary &&
            other.spentToday == spentToday &&
            other.monthlySubscriptionCost == monthlySubscriptionCost &&
            other.yearlySubscriptionCost == yearlySubscriptionCost &&
            other.activeSubscriptionCount == activeSubscriptionCount &&
            _sameUpcoming(other.upcomingPayments, upcomingPayments);
  }

  static bool _sameUpcoming(List<UpcomingPayment> a, List<UpcomingPayment> b) {
    if (a.length != b.length) return false;

    for (var index = 0; index < a.length; index++) {
      if (a[index] != b[index]) return false;
    }

    return true;
  }

  @override
  int get hashCode => Object.hash(
    spentToday,
    monthlySubscriptionCost,
    yearlySubscriptionCost,
    activeSubscriptionCount,
    Object.hashAll(upcomingPayments),
  );
}
