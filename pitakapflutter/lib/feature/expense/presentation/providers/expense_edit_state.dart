sealed class ExpenseEditState {
  const ExpenseEditState();
}

class ExpenseEditInitialState extends ExpenseEditState {
  const ExpenseEditInitialState();
}

class ExpenseEditLoadingState extends ExpenseEditState {
  const ExpenseEditLoadingState();
}

class ExpenseEditSuccessState extends ExpenseEditState {
  final bool wasExisting;

  const ExpenseEditSuccessState({required this.wasExisting});
}

class ExpenseEditFailedState extends ExpenseEditState {
  final String message;

  const ExpenseEditFailedState(this.message);
}
