import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pitakapflutter/feature/expense/domain/entities/expense_entity.dart';
import 'package:pitakapflutter/feature/expense/presentation/widgets/expense_day_total_card.dart';
import 'package:pitakapflutter/feature/expense/presentation/widgets/expense_tile.dart';

import 'helpers.dart';

ExpenseEntity expense({
  String id = 'e1',
  String description = 'Lunch at Jollibee',
  String category = 'food',
  double amount = 250,
  String paymentMethod = 'cash',
  DateTime? date,
}) {
  return ExpenseEntity(
    id: id,
    userId: 'uid-1',
    description: description,
    category: category,
    amount: amount,
    paymentMethod: paymentMethod,
    date: date ?? DateTime(2026, 8, 19),
  );
}

void main() {
  group('ExpenseTile.subtitleLabel', () {
    test('joins category and payment method', () {
      expect(
        ExpenseTile.subtitleLabel(expense(paymentMethod: 'gcash')),
        'Food · GCash',
      );
    });

    test('capitalises a plain payment method', () {
      expect(
        ExpenseTile.subtitleLabel(expense(paymentMethod: 'card')),
        'Food · Card',
      );
    });

    test('is the category alone when no payment method was recorded', () {
      expect(
        ExpenseTile.subtitleLabel(
          expense(category: 'transport', paymentMethod: ''),
        ),
        'Transport',
      );
    });
  });

  group('ExpenseTile.amountLabel', () {
    test('renders an outflow with a leading minus', () {
      expect(ExpenseTile.amountLabel(expense(amount: 250)), '-₱250.00');
    });

    test('keeps centavos', () {
      expect(ExpenseTile.amountLabel(expense(amount: 250.5)), '-₱250.50');
    });
  });

  group('ExpenseDayTotalCard.dayLabel', () {
    final today = DateTime(2026, 8, 19);

    test('names today', () {
      expect(
        ExpenseDayTotalCard.dayLabel(DateTime(2026, 8, 19), today),
        'Today · Aug 19',
      );
    });

    test('names yesterday', () {
      expect(
        ExpenseDayTotalCard.dayLabel(DateTime(2026, 8, 18), today),
        'Yesterday · Aug 18',
      );
    });

    test('falls back to a weekday and date', () {
      expect(
        ExpenseDayTotalCard.dayLabel(DateTime(2026, 8, 15), today),
        'Sat, Aug 15',
      );
    });

    test('crosses a month boundary for yesterday', () {
      expect(
        ExpenseDayTotalCard.dayLabel(
          DateTime(2026, 7, 31),
          DateTime(2026, 8, 1),
        ),
        'Yesterday · Jul 31',
      );
    });
  });

  group('ExpenseDayTotalCard.entriesLabel', () {
    test('is singular for one entry', () {
      expect(ExpenseDayTotalCard.entriesLabel(1), '1 entry');
    });

    test('is plural for none and for many', () {
      expect(ExpenseDayTotalCard.entriesLabel(0), '0 entries');
      expect(ExpenseDayTotalCard.entriesLabel(4), '4 entries');
    });
  });

  group('ExpenseTile widget', () {
    testWidgets('renders description, subtitle and amount', (tester) async {
      await pumpPage(
        tester,
        Scaffold(body: ExpenseTile(expense: expense(paymentMethod: 'gcash'))),
      );

      expect(find.text('Lunch at Jollibee'), findsOneWidget);
      expect(find.text('Food · GCash'), findsOneWidget);
      expect(find.text('-₱250.00'), findsOneWidget);
    });

    testWidgets('renders the category icon', (tester) async {
      await pumpPage(
        tester,
        Scaffold(
          body: ExpenseTile(expense: expense(category: 'transport')),
        ),
      );

      expect(find.byIcon(Icons.directions_bus_outlined), findsOneWidget);
    });

    testWidgets('renders in dark mode', (tester) async {
      await pumpPage(
        tester,
        Scaffold(body: ExpenseTile(expense: expense())),
        brightness: Brightness.dark,
      );

      expect(find.text('Lunch at Jollibee'), findsOneWidget);
    });
  });
}
