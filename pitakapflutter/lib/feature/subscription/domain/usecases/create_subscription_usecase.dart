import 'package:pitakapflutter/core/resources/billing_cycle.dart';
import 'package:pitakapflutter/core/resources/constants.dart';
import 'package:pitakapflutter/core/usecase/usecase.dart';
import 'package:pitakapflutter/feature/subscription/domain/repository/subscription_repository.dart';

class CreateSubscriptionUseCaseParams {
  final String userId;
  final String name;
  final String category;
  final double amount;
  final String currency;
  final BillingCycle billingCycle;
  final DateTime firstBillDate;
  final int reminderDaysBefore;
  final String colorHex;
  final String iconKey;
  final String notes;
  final bool isActive;

  const CreateSubscriptionUseCaseParams({
    required this.userId,
    required this.name,
    required this.category,
    required this.amount,
    required this.firstBillDate,
    this.billingCycle = BillingCycle.monthly,
    this.currency = Constants.defaultCurrency,
    this.reminderDaysBefore = Constants.defaultReminderDaysBefore,
    this.colorHex = '',
    this.iconKey = 'other',
    this.notes = '',
    this.isActive = true,
  });
}

class CreateSubscriptionUseCase
    implements UseCaseWithParams<void, CreateSubscriptionUseCaseParams> {
  final SubscriptionRepository repository;

  const CreateSubscriptionUseCase(this.repository);

  @override
  Future<void> call(CreateSubscriptionUseCaseParams params) {
    return repository.createSubscription(params);
  }
}
