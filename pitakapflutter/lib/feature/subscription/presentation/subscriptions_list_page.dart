import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pitakapflutter/core/common/common.dart';
import 'package:pitakapflutter/core/error/failure.dart';
import 'package:pitakapflutter/core/providers/auth_providers.dart';
import 'package:pitakapflutter/core/providers/subscription_providers.dart';
import 'package:pitakapflutter/core/resources/strings.dart';
import 'package:pitakapflutter/core/router/app_routes.dart';
import 'package:pitakapflutter/core/theme/app_theme.dart';
import 'package:pitakapflutter/feature/subscription/domain/entities/subscription_entity.dart';
import 'package:pitakapflutter/feature/subscription/domain/usecases/create_subscription_usecase.dart';
import 'package:pitakapflutter/feature/subscription/domain/usecases/delete_subscription_usecase.dart';
import 'package:pitakapflutter/feature/subscription/presentation/widgets/subscription_tile.dart';

class SubscriptionsListPage extends ConsumerWidget {
  const SubscriptionsListPage({super.key});

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    SubscriptionEntity subscription,
  ) async {
    final messenger = ScaffoldMessenger.of(context);

    try {
      await ref
          .read(deleteSubscriptionUseCaseProvider)
          .call(DeleteSubscriptionUseCaseParams(subscription.id));
    } catch (error) {
      if (!context.mounted) return;
      CommonSnackBar.showError(context, failureMessage(error));
      return;
    }

    if (!context.mounted) return;

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${subscription.name} ${Strings.subscriptionDeleted}'),
          action: SnackBarAction(
            label: Strings.undoAction,
            onPressed: () => _restore(ref, subscription),
          ),
        ),
      );
  }

  void _restore(WidgetRef ref, SubscriptionEntity subscription) {
    ref
        .read(createSubscriptionUseCaseProvider)
        .call(
          CreateSubscriptionUseCaseParams(
            userId: subscription.userId,
            name: subscription.name,
            category: subscription.category,
            amount: subscription.amount,
            firstBillDate: subscription.firstBillDate,
            billingCycle: subscription.billingCycle,
            currency: subscription.currency,
            reminderDaysBefore: subscription.reminderDaysBefore,
            colorHex: subscription.colorHex,
            iconKey: subscription.iconKey,
            notes: subscription.notes,
            isActive: subscription.isActive,
          ),
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(authStateProvider).value;

    return Scaffold(
      appBar: AppBar(title: const Text(Strings.subscriptionsTitle)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.subscriptionNew),
        child: const Icon(Icons.add),
      ),
      body: userId == null
          ? const CommonLoader.page()
          : ref
                .watch(subscriptionsStreamProvider(userId))
                .when(
                  loading: () => const CommonLoader.page(),
                  error: (error, _) => CommonEmptyState(
                    icon: Icons.cloud_off_outlined,
                    title: Strings.subscriptionsLoadFailed,
                    message: failureMessage(error),
                  ),
                  data: (subscriptions) => subscriptions.isEmpty
                      ? const CommonEmptyState(
                          icon: Icons.autorenew_outlined,
                          title: Strings.subscriptionsEmptyTitle,
                          message: Strings.subscriptionsEmptyMessage,
                        )
                      : _SubscriptionList(
                          subscriptions: subscriptions,
                          onDelete: (subscription) =>
                              _delete(context, ref, subscription),
                          onOpen: (subscription) => context.push(
                            AppRoutes.subscriptionDetailPath(subscription.id),
                          ),
                        ),
                ),
    );
  }
}

class _SubscriptionList extends StatelessWidget {
  final List<SubscriptionEntity> subscriptions;
  final ValueChanged<SubscriptionEntity> onDelete;
  final ValueChanged<SubscriptionEntity> onOpen;

  const _SubscriptionList({
    required this.subscriptions,
    required this.onDelete,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.xl * 2,
      ),
      itemCount: subscriptions.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final subscription = subscriptions[index];

        return Dismissible(
          key: ValueKey(subscription.id),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => onDelete(subscription),
          background: const _DeleteBackground(),
          child: SubscriptionTile(
            subscription: subscription,
            now: now,
            onTap: () => onOpen(subscription),
          ),
        );
      },
    );
  }
}

class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.error,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Icon(Icons.delete_outline, color: colorScheme.onError),
    );
  }
}
