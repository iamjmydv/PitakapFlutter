import 'package:pitakapflutter/feature/expense/domain/entities/expense_entity.dart';

double dailyTotal(List<ExpenseEntity> expenses) {
  return expenses.fold(0, (sum, expense) => sum + expense.amount);
}

double totalForDay(List<ExpenseEntity> expenses, DateTime day) {
  return dailyTotal(expenses.where((e) => e.belongsTo(day)).toList());
}
