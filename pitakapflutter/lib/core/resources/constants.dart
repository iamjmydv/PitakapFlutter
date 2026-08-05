import 'package:flutter/material.dart';

class Constants {
  static const String defaultCurrency = 'PHP';
  static const String currencySymbol = '₱';
  static const int defaultReminderDaysBefore = 3;

  static const List<String> billingCycles = [
    'weekly',
    'monthly',
    'quarterly',
    'yearly',
  ];

  static const List<String> subscriptionCategories = [
    'entertainment',
    'utilities',
    'health',
    'productivity',
    'education',
    'other',
  ];

  static const List<String> expenseCategories = [
    'food',
    'transport',
    'groceries',
    'shopping',
    'bills',
    'health',
    'entertainment',
    'other',
  ];

  static const List<String> paymentMethods = [
    'cash',
    'card',
    'gcash',
    'other',
  ];

  static const Map<String, IconData> categoryIcons = {
    'entertainment': Icons.movie_outlined,
    'utilities': Icons.bolt_outlined,
    'health': Icons.favorite_outline,
    'productivity': Icons.work_outline,
    'education': Icons.school_outlined,
    'food': Icons.restaurant_outlined,
    'transport': Icons.directions_bus_outlined,
    'groceries': Icons.shopping_cart_outlined,
    'shopping': Icons.shopping_bag_outlined,
    'bills': Icons.receipt_long_outlined,
    'other': Icons.category_outlined,
  };

  static const Map<String, Color> categoryColors = {
    'entertainment': Color(0xFFE50914),
    'utilities': Color(0xFFFFB300),
    'health': Color(0xFFE91E63),
    'productivity': Color(0xFF3F51B5),
    'education': Color(0xFF009688),
    'food': Color(0xFFFF7043),
    'transport': Color(0xFF42A5F5),
    'groceries': Color(0xFF66BB6A),
    'shopping': Color(0xFFAB47BC),
    'bills': Color(0xFF8D6E63),
    'other': Color(0xFF78909C),
  };

  static const Map<String, IconData> subscriptionIcons = {
    'movie': Icons.movie_outlined,
    'music': Icons.music_note_outlined,
    'cloud': Icons.cloud_outlined,
    'game': Icons.sports_esports_outlined,
    'fitness': Icons.fitness_center_outlined,
    'news': Icons.newspaper_outlined,
    'wifi': Icons.wifi_outlined,
    'phone': Icons.phone_iphone_outlined,
    'tv': Icons.tv_outlined,
    'book': Icons.menu_book_outlined,
    'other': Icons.subscriptions_outlined,
  };

  static const List<Color> subscriptionColors = [
    Color(0xFFE50914),
    Color(0xFF1DB954),
    Color(0xFF1976D2),
    Color(0xFFFF9800),
    Color(0xFF9C27B0),
    Color(0xFF00BCD4),
    Color(0xFFF44336),
    Color(0xFF607D8B),
  ];
}
