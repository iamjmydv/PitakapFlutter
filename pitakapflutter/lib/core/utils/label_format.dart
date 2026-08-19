String categoryLabel(String category) {
  if (category.isEmpty) return category;

  return category[0].toUpperCase() + category.substring(1);
}

const Map<String, String> _paymentMethodLabels = {'gcash': 'GCash'};

String paymentMethodLabel(String paymentMethod) {
  return _paymentMethodLabels[paymentMethod] ?? categoryLabel(paymentMethod);
}
