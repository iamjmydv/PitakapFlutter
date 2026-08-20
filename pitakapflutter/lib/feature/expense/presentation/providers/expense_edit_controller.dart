import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pitakapflutter/core/error/failure.dart';
import 'package:pitakapflutter/core/providers/expense_providers.dart';
import 'package:pitakapflutter/feature/expense/domain/entities/expense_entity.dart';
import 'package:pitakapflutter/feature/expense/domain/usecases/create_expense_usecase.dart';
import 'package:pitakapflutter/feature/expense/domain/usecases/update_expense_usecase.dart';
import 'package:pitakapflutter/feature/expense/presentation/providers/expense_edit_state.dart';

class ExpenseEditController extends AsyncNotifier<ExpenseEditState> {
  @override
  FutureOr<ExpenseEditState> build() => const ExpenseEditInitialState();

  bool get isBusy => state.value is ExpenseEditLoadingState;

  Future<void> create(CreateExpenseUseCaseParams params) async {
    await _run(
      () => ref.read(createExpenseUseCaseProvider).call(params),
      onSuccess: const ExpenseEditSuccessState(wasExisting: false),
    );
  }

  Future<void> updateExisting(ExpenseEntity expense) async {
    await _run(
      () => ref
          .read(updateExpenseUseCaseProvider)
          .call(UpdateExpenseUseCaseParams(expense)),
      onSuccess: const ExpenseEditSuccessState(wasExisting: true),
    );
  }

  Future<void> _run(
    Future<void> Function() action, {
    required ExpenseEditState onSuccess,
  }) async {
    if (isBusy) return;

    state = const AsyncValue.data(ExpenseEditLoadingState());

    final result = await AsyncValue.guard(action);

    state = AsyncValue.data(switch (result) {
      AsyncData() => onSuccess,
      AsyncError(:final error) => ExpenseEditFailedState(
        failureMessage(error),
      ),
      _ => const ExpenseEditLoadingState(),
    });
  }

  void reset() => state = const AsyncValue.data(ExpenseEditInitialState());
}

final expenseEditControllerProvider =
    AsyncNotifierProvider.autoDispose<ExpenseEditController, ExpenseEditState>(
      ExpenseEditController.new,
    );
