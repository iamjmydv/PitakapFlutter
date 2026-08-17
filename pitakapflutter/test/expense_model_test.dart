import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pitakapflutter/core/resources/constants.dart';
import 'package:pitakapflutter/core/resources/keys.dart';
import 'package:pitakapflutter/feature/expense/data/model/expense_model.dart';
import 'package:pitakapflutter/feature/expense/domain/entities/expense_entity.dart';

void main() {
  group('ExpenseModel.fromMap', () {
    test('reads the id from the document id, not the payload', () {
      final model = ExpenseModel.fromMap('exp-from-doc', {
        Keys.userId: 'uid-1',
        Keys.description: 'Lunch',
      });

      expect(model.id, 'exp-from-doc');
    });

    test('maps every stored field', () {
      final date = DateTime(2026, 8, 15);
      final created = DateTime.utc(2026, 8, 15, 4, 30);

      final model = ExpenseModel.fromMap('exp-1', {
        Keys.userId: 'uid-1',
        Keys.description: 'Lunch at Jollibee',
        Keys.category: 'food',
        Keys.amount: 250.0,
        Keys.currency: 'PHP',
        Keys.paymentMethod: 'gcash',
        Keys.date: Timestamp.fromDate(date),
        Keys.createdAt: Timestamp.fromDate(created),
        Keys.updatedAt: Timestamp.fromDate(created),
      });

      expect(model.userId, 'uid-1');
      expect(model.description, 'Lunch at Jollibee');
      expect(model.category, 'food');
      expect(model.amount, 250);
      expect(model.currency, 'PHP');
      expect(model.paymentMethod, 'gcash');
      expect(model.date, date);
      expect(model.createdAt, created.toLocal());
      expect(model.updatedAt, created.toLocal());
    });

    test('an int amount from the console still reads as a double', () {
      final model = ExpenseModel.fromMap('exp-1', {Keys.amount: 250});

      expect(model.amount, 250.0);
      expect(model.amount, isA<double>());
    });

    test('a missing payment method is empty, never null', () {
      final model = ExpenseModel.fromMap('exp-1', const {});

      expect(model.paymentMethod, isEmpty);
      expect(model.hasPaymentMethod, isFalse);
    });

    test('survives a document with no data at all', () {
      final model = ExpenseModel.fromMap('exp-1', null);

      expect(model.userId, isEmpty);
      expect(model.description, isEmpty);
      expect(model.category, 'other');
      expect(model.amount, 0);
      expect(model.currency, Constants.defaultCurrency);
      expect(model.date, DateTime(1970));
    });

    test('leaves timestamps null while the server value is pending', () {
      final model = ExpenseModel.fromMap('exp-1', {Keys.userId: 'uid-1'});

      expect(model.createdAt, isNull);
      expect(model.updatedAt, isNull);
    });
  });

  group('ExpenseModel.toCreateMap', () {
    final model = ExpenseModel(
      id: '',
      userId: 'uid-1',
      description: 'Grab to BGC',
      category: 'transport',
      amount: 215,
      paymentMethod: 'cash',
      date: DateTime(2026, 8, 15, 19, 42),
    );

    test('writes the ownership field', () {
      expect(model.toCreateMap()[Keys.userId], 'uid-1');
    });

    test('normalises the date to midnight local so the day query matches', () {
      final stored = model.toCreateMap()[Keys.date] as Timestamp;

      expect(stored.toDate(), DateTime(2026, 8, 15));
    });

    test('sets both server timestamps', () {
      final map = model.toCreateMap();

      expect(map[Keys.createdAt], isA<FieldValue>());
      expect(map[Keys.updatedAt], isA<FieldValue>());
    });

    test('never writes the document id into the payload', () {
      expect(model.toCreateMap().containsKey('id'), isFalse);
    });
  });

  group('ExpenseModel.toUpdateMap', () {
    final model = ExpenseModel(
      id: 'exp-1',
      userId: 'uid-1',
      description: 'Grab to BGC',
      category: 'transport',
      amount: 215,
      date: DateTime(2026, 8, 15, 19, 42),
      createdAt: DateTime(2026, 8, 15),
    );

    test('omits userId so an edit can never reassign ownership', () {
      expect(model.toUpdateMap().containsKey(Keys.userId), isFalse);
    });

    test('omits createdAt so the original creation time survives', () {
      expect(model.toUpdateMap().containsKey(Keys.createdAt), isFalse);
    });

    test('bumps only updatedAt', () {
      expect(model.toUpdateMap()[Keys.updatedAt], isA<FieldValue>());
    });

    test('still normalises the date', () {
      final stored = model.toUpdateMap()[Keys.date] as Timestamp;

      expect(stored.toDate(), DateTime(2026, 8, 15));
    });

    test('carries every editable field', () {
      final map = model.toUpdateMap();

      expect(map[Keys.description], 'Grab to BGC');
      expect(map[Keys.category], 'transport');
      expect(map[Keys.amount], 215);
      expect(map[Keys.currency], Constants.defaultCurrency);
      expect(map.containsKey(Keys.paymentMethod), isTrue);
    });
  });

  group('ExpenseModel.fromEntity', () {
    test('round-trips every field', () {
      final entity = ExpenseEntity(
        id: 'exp-1',
        userId: 'uid-1',
        description: 'Milk tea',
        category: 'food',
        amount: 150,
        currency: 'PHP',
        paymentMethod: 'card',
        date: DateTime(2026, 8, 15),
        createdAt: DateTime(2026, 8, 15, 9),
        updatedAt: DateTime(2026, 8, 15, 10),
      );

      expect(ExpenseModel.fromEntity(entity), entity);
    });
  });
}
