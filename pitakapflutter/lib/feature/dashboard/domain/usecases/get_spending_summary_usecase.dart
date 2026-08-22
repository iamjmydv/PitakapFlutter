import 'package:pitakapflutter/feature/dashboard/domain/entities/spending_summary.dart';
import 'package:pitakapflutter/feature/expense/domain/entities/expense_entity.dart';
import 'package:pitakapflutter/feature/expense/domain/expense_totals.dart';
import 'package:pitakapflutter/feature/subscription/domain/entities/subscription_entity.dart';

class GetSpendingSummaryUseCaseParams {
  final List<SubscriptionEntity> subscriptions;
  final List<ExpenseEntity> expensesToday;
  final DateTime now;
  final int upcomingCount;

  const GetSpendingSummaryUseCaseParams({
    required this.subscriptions,
    required this.expensesToday,
    required this.now,
    this.upcomingCount = GetSpendingSummaryUseCase.defaultUpcomingCount,
  });
}

class GetSpendingSummaryUseCase {
  const GetSpendingSummaryUseCase();

  static const int defaultUpcomingCount = 5;

  SpendingSummary call(GetSpendingSummaryUseCaseParams params) {
    final active = params.subscriptions
        .where((subscription) => subscription.isActive)
        .toList();

    final monthly = active.fold<double>(
      0,
      (sum, subscription) => sum + subscription.monthlyCost,
    );

    final yearly = active.fold<double>(
      0,
      (sum, subscription) => sum + subscription.yearlyCost,
    );

    final upcoming =
        active
            .map(
              (subscription) => UpcomingPayment(
                subscription: subscription,
                dueDate: subscription.nextDueDateAsOf(params.now),
                daysUntil: subscription.daysUntilNextDueAsOf(params.now),
              ),
            )
            .toList()
          ..sort((a, b) {
            final byDate = a.dueDate.compareTo(b.dueDate);
            if (byDate != 0) return byDate;

            return a.subscription.name.toLowerCase().compareTo(
              b.subscription.name.toLowerCase(),
            );
          });

    return SpendingSummary(
      spentToday: dailyTotal(params.expensesToday),
      monthlySubscriptionCost: monthly,
      yearlySubscriptionCost: yearly,
      activeSubscriptionCount: active.length,
      upcomingPayments: upcoming.take(params.upcomingCount).toList(),
    );
  }
}
