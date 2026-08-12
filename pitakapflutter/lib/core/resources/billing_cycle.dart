enum BillingCycle {
  weekly('weekly', 'Weekly'),
  monthly('monthly', 'Monthly'),
  quarterly('quarterly', 'Quarterly'),
  yearly('yearly', 'Yearly');

  final String wireValue;
  final String label;

  const BillingCycle(this.wireValue, this.label);

  static BillingCycle fromWire(String? value) {
    return BillingCycle.values.firstWhere(
      (cycle) => cycle.wireValue == value,
      orElse: () => BillingCycle.monthly,
    );
  }

  double get periodsPerYear => switch (this) {
    BillingCycle.weekly => 52,
    BillingCycle.monthly => 12,
    BillingCycle.quarterly => 4,
    BillingCycle.yearly => 1,
  };
}
