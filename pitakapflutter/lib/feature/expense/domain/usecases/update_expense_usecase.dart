import 'package:pitakapflutter/core/usecase/usecase.dart';
import 'package:pitakapflutter/feature/expense/domain/entities/expense_entity.dart';
import 'package:pitakapflutter/feature/expense/domain/repository/expense_repository.dart';

class UpdateExpenseUseCaseParams {
  final ExpenseEntity expense;

  const UpdateExpenseUseCaseParams(this.expense);
}

class UpdateExpenseUseCase
    implements UseCaseWithParams<void, UpdateExpenseUseCaseParams> {
  final ExpenseRepository repository;

  const UpdateExpenseUseCase(this.repository);

  @override
  Future<void> call(UpdateExpenseUseCaseParams params) {
    return repository.updateExpense(params);
  }
}
