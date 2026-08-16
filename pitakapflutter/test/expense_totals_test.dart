import 'package:flutter_test/flutter_test.dart';

import 'package:pitakapflutter/feature/expense/domain/entities/expense_entity.dart';
import 'package:pitakapflutter/feature/expense/domain/expense_totals.dart';

ExpenseEntity expense({
  String id = 'exp-1',
  double amount = 250,
  String category = 'food',
  DateTime? date,
}) {
  return ExpenseEntity(
    id: id,
    userId: 'uid-1',
    description: 'Something',
    category: category,
    amount: amount,
    date: date ?? DateTime(2026, 8, 15),
  );
}

void main() {
  group('dailyTotal', () {
    test('an empty day totals zero, not null', () {
      expect(dailyTotal(const []), 0);
    });

    test('sums every amount', () {
      final total = dailyTotal([
        expense(id: 'a', amount: 250),
        expense(id: 'b', amount: 125),
        expense(id: 'c', amount: 60.50),
      ]);

      expect(total, 435.50);
    });

    test('a single expense totals itself', () {
      expect(dailyTotal([expense(amount: 99.99)]), 99.99);
    });
  });

  group('totalForDay', () {
    final week = [
      expense(id: 'a', amount: 250, date: DateTime(2026, 8, 15, 12)),
      expense(id: 'b', amount: 125, date: DateTime(2026, 8, 15, 19, 30)),
      expense(id: 'c', amount: 999, date: DateTime(2026, 8, 16, 8)),
    ];

    test('counts only the expenses on that day', () {
      expect(totalForDay(week, DateTime(2026, 8, 15)), 375);
      expect(totalForDay(week, DateTime(2026, 8, 16)), 999);
    });

    test('a day with nothing logged totals zero', () {
      expect(totalForDay(week, DateTime(2026, 8, 17)), 0);
    });

    test('the time on the requested day is ignored', () {
      expect(totalForDay(week, DateTime(2026, 8, 15, 23, 59, 59)), 375);
    });

    test('an expense logged at 11:59 PM counts toward that day', () {
      final lateNight = [
        expense(amount: 80, date: DateTime(2026, 8, 15, 23, 59)),
      ];

      expect(totalForDay(lateNight, DateTime(2026, 8, 15)), 80);
      expect(totalForDay(lateNight, DateTime(2026, 8, 16)), 0);
    });
  });
}
