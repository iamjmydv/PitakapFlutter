import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pitakapflutter/core/resources/billing_cycle.dart';
import 'package:pitakapflutter/core/resources/constants.dart';
import 'package:pitakapflutter/core/resources/keys.dart';
import 'package:pitakapflutter/feature/subscription/data/model/subscription_model.dart';
import 'package:pitakapflutter/feature/subscription/domain/entities/subscription_entity.dart';

void main() {
  group('SubscriptionModel.fromMap', () {
    test('reads the id from the document id, not the payload', () {
      final model = SubscriptionModel.fromMap('sub-from-doc', {
        Keys.userId: 'uid-1',
        Keys.name: 'Netflix',
      });

      expect(model.id, 'sub-from-doc');
    });

    test('maps every stored field', () {
      final firstBill = DateTime(2026, 1, 31);
      final created = DateTime.utc(2026, 8, 9, 12, 30);

      final model = SubscriptionModel.fromMap('sub-1', {
        Keys.userId: 'uid-1',
        Keys.name: 'Netflix',
        Keys.category: 'entertainment',
        Keys.amount: 549.0,
        Keys.currency: 'PHP',
        Keys.billingCycle: 'monthly',
        Keys.firstBillDate: Timestamp.fromDate(firstBill),
        Keys.reminderDaysBefore: 5,
        Keys.colorHex: '#E50914',
        Keys.iconKey: 'movie',
        Keys.notes: 'Family plan',
        Keys.isActive: true,
        Keys.createdAt: Timestamp.fromDate(created),
        Keys.updatedAt: Timestamp.fromDate(created),
      });

      expect(model.userId, 'uid-1');
      expect(model.name, 'Netflix');
      expect(model.category, 'entertainment');
      expect(model.amount, 549.0);
      expect(model.currency, 'PHP');
      expect(model.billingCycle, BillingCycle.monthly);
      expect(model.firstBillDate, firstBill);
      expect(model.reminderDaysBefore, 5);
      expect(model.colorHex, '#E50914');
      expect(model.iconKey, 'movie');
      expect(model.notes, 'Family plan');
      expect(model.isActive, isTrue);
      expect(model.createdAt?.toUtc(), created);
      expect(model.updatedAt?.toUtc(), created);
    });

    test('widens an integer amount to a double', () {
      final model = SubscriptionModel.fromMap('sub-1', {Keys.amount: 549});

      expect(model.amount, isA<double>());
      expect(model.amount, 549.0);
    });

    test('falls back to monthly for an unknown billing cycle', () {
      final model = SubscriptionModel.fromMap('sub-1', {
        Keys.billingCycle: 'fortnightly',
      });

      expect(model.billingCycle, BillingCycle.monthly);
    });

    test('survives a document with missing fields', () {
      final model = SubscriptionModel.fromMap('sub-1', {});

      expect(model.userId, isEmpty);
      expect(model.name, isEmpty);
      expect(model.category, 'other');
      expect(model.amount, 0);
      expect(model.currency, Constants.defaultCurrency);
      expect(model.billingCycle, BillingCycle.monthly);
      expect(model.reminderDaysBefore, Constants.defaultReminderDaysBefore);
      expect(model.iconKey, 'other');
      expect(model.isActive, isTrue);
      expect(model.createdAt, isNull);
      expect(model.updatedAt, isNull);
    });

    test('survives a document with no data at all', () {
      final model = SubscriptionModel.fromMap('sub-1', null);

      expect(model.id, 'sub-1');
      expect(model.name, isEmpty);
    });

    test('leaves the timestamps null while the server fills them in', () {
      final model = SubscriptionModel.fromMap('sub-1', {
        Keys.createdAt: null,
        Keys.updatedAt: null,
      });

      expect(model.createdAt, isNull);
      expect(model.updatedAt, isNull);
    });
  });

  group('SubscriptionModel.toCreateMap', () {
    final model = SubscriptionModel(
      id: 'sub-1',
      userId: 'uid-1',
      name: 'Netflix',
      category: 'entertainment',
      amount: 549,
      firstBillDate: DateTime(2026, 1, 31, 14, 30),
    );

    test('writes the ownership field so the security rule can match it', () {
      expect(model.toCreateMap()[Keys.userId], 'uid-1');
    });

    test('writes server timestamps for both created and updated', () {
      final map = model.toCreateMap();

      expect(map[Keys.createdAt], isA<FieldValue>());
      expect(map[Keys.updatedAt], isA<FieldValue>());
    });

    test('never writes the document id into the payload', () {
      expect(model.toCreateMap().containsKey('id'), isFalse);
    });

    test('stores the billing cycle as its wire value', () {
      expect(model.toCreateMap()[Keys.billingCycle], 'monthly');
    });

    test('normalises the first bill date to midnight local', () {
      final stored = model.toCreateMap()[Keys.firstBillDate] as Timestamp;

      expect(stored.toDate(), DateTime(2026, 1, 31));
    });
  });

  group('SubscriptionModel.toUpdateMap', () {
    final model = SubscriptionModel(
      id: 'sub-1',
      userId: 'uid-1',
      name: 'Netflix',
      category: 'entertainment',
      amount: 649,
      firstBillDate: DateTime(2026, 1, 31),
    );

    test('never rewrites the ownership field', () {
      expect(model.toUpdateMap().containsKey(Keys.userId), isFalse);
    });

    test('never rewrites createdAt', () {
      expect(model.toUpdateMap().containsKey(Keys.createdAt), isFalse);
    });

    test('bumps updatedAt with a server timestamp', () {
      expect(model.toUpdateMap()[Keys.updatedAt], isA<FieldValue>());
    });

    test('carries the edited fields', () {
      final map = model.toUpdateMap();

      expect(map[Keys.name], 'Netflix');
      expect(map[Keys.amount], 649);
    });
  });

  group('SubscriptionModel.fromEntity', () {
    test('copies every field across and stays equal to the entity', () {
      final entity = SubscriptionEntity(
        id: 'sub-1',
        userId: 'uid-1',
        name: 'Spotify',
        category: 'entertainment',
        amount: 194,
        currency: 'PHP',
        billingCycle: BillingCycle.yearly,
        firstBillDate: DateTime(2026, 3, 1),
        reminderDaysBefore: 7,
        colorHex: '#1DB954',
        iconKey: 'music',
        notes: 'Duo plan',
        isActive: false,
        createdAt: DateTime.utc(2026, 8, 9),
        updatedAt: DateTime.utc(2026, 8, 10),
      );

      final model = SubscriptionModel.fromEntity(entity);

      expect(model, entity);
      expect(model.billingCycle, BillingCycle.yearly);
      expect(model.isActive, isFalse);
      expect(model.notes, 'Duo plan');
    });
  });

  group('round trip', () {
    test('a written subscription reads back with the same values', () {
      final original = SubscriptionModel(
        id: 'sub-1',
        userId: 'uid-1',
        name: 'Netflix',
        category: 'entertainment',
        amount: 549,
        billingCycle: BillingCycle.quarterly,
        firstBillDate: DateTime(2026, 1, 31),
        reminderDaysBefore: 5,
        colorHex: '#E50914',
        iconKey: 'movie',
        notes: 'Family plan',
      );

      final written = Map<String, dynamic>.from(original.toCreateMap())
        ..remove(Keys.createdAt)
        ..remove(Keys.updatedAt);

      final read = SubscriptionModel.fromMap('sub-1', written);

      expect(read, original);
    });
  });
}
