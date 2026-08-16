import 'package:pitakapflutter/core/usecase/usecase.dart';
import 'package:pitakapflutter/feature/expense/domain/repository/expense_repository.dart';

class DeleteExpenseUseCaseParams {
  final String expenseId;

  const DeleteExpenseUseCaseParams(this.expenseId);
}

class DeleteExpenseUseCase
    implements UseCaseWithParams<void, DeleteExpenseUseCaseParams> {
  final ExpenseRepository repository;

  const DeleteExpenseUseCase(this.repository);

  @override
  Future<void> call(DeleteExpenseUseCaseParams params) {
    return repository.deleteExpense(params);
  }
}
