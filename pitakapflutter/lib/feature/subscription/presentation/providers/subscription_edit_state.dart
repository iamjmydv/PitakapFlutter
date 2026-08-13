sealed class SubscriptionEditState {
  const SubscriptionEditState();
}

class SubscriptionEditInitialState extends SubscriptionEditState {
  const SubscriptionEditInitialState();
}

class SubscriptionEditLoadingState extends SubscriptionEditState {
  const SubscriptionEditLoadingState();
}

class SubscriptionEditSuccessState extends SubscriptionEditState {
  final bool wasExisting;

  const SubscriptionEditSuccessState({required this.wasExisting});
}

class SubscriptionEditFailedState extends SubscriptionEditState {
  final String message;

  const SubscriptionEditFailedState(this.message);
}
