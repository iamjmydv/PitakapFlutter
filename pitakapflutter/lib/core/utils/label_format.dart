String categoryLabel(String category) {
  if (category.isEmpty) return category;

  return category[0].toUpperCase() + category.substring(1);
}
