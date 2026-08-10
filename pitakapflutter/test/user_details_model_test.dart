import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pitakapflutter/core/resources/constants.dart';
import 'package:pitakapflutter/core/resources/keys.dart';
import 'package:pitakapflutter/feature/auth/data/model/user_details_model.dart';
import 'package:pitakapflutter/feature/auth/domain/entities/user_details_entity.dart';

void main() {
  group('UserDetailsEntity', () {
    test('joins the name parts and defaults the currency to PHP', () {
      const user = UserDetailsEntity(
        uid: 'uid-1',
        firstName: 'Diane',
        lastName: 'Magno',
        email: 'diane@pitakap.app',
      );

      expect(user.fullName, 'Diane Magno');
      expect(user.defaultCurrency, Constants.defaultCurrency);
    });

    test('compares by value, not identity', () {
      const a = UserDetailsEntity(
        uid: 'uid-1',
        firstName: 'Diane',
        lastName: 'Magno',
        email: 'diane@pitakap.app',
      );
      const b = UserDetailsEntity(
        uid: 'uid-1',
        firstName: 'Diane',
        lastName: 'Magno',
        email: 'diane@pitakap.app',
      );
      const other = UserDetailsEntity(
        uid: 'uid-2',
        firstName: 'Diane',
        lastName: 'Magno',
        email: 'diane@pitakap.app',
      );

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(other));
    });
  });

  group('UserDetailsModel.fromMap', () {
    test('reads the uid from the document id, not the payload', () {
      final model = UserDetailsModel.fromMap('uid-from-doc', {
        Keys.firstName: 'Diane',
        Keys.lastName: 'Magno',
        Keys.email: 'diane@pitakap.app',
      });

      expect(model.uid, 'uid-from-doc');
    });

    test('maps every stored field', () {
      final created = DateTime.utc(2026, 8, 9, 12, 30);

      final model = UserDetailsModel.fromMap('uid-1', {
        Keys.firstName: 'Diane',
        Keys.lastName: 'Magno',
        Keys.email: 'diane@pitakap.app',
        Keys.defaultCurrency: 'USD',
        Keys.createdAt: Timestamp.fromDate(created),
      });

      expect(model.firstName, 'Diane');
      expect(model.lastName, 'Magno');
      expect(model.email, 'diane@pitakap.app');
      expect(model.defaultCurrency, 'USD');
      expect(model.createdAt?.toUtc(), created);
    });

    test('survives a document with missing fields', () {
      final model = UserDetailsModel.fromMap('uid-1', {});

      expect(model.firstName, isEmpty);
      expect(model.lastName, isEmpty);
      expect(model.email, isEmpty);
      expect(model.defaultCurrency, Constants.defaultCurrency);
      expect(model.createdAt, isNull);
    });

    test('survives a document with no data at all', () {
      final model = UserDetailsModel.fromMap('uid-1', null);

      expect(model.uid, 'uid-1');
      expect(model.firstName, isEmpty);
    });

    test('leaves createdAt null while the server timestamp is pending', () {
      final model = UserDetailsModel.fromMap('uid-1', {Keys.createdAt: null});

      expect(model.createdAt, isNull);
    });
  });

  group('UserDetailsModel maps', () {
    const model = UserDetailsModel(
      uid: 'uid-1',
      firstName: 'Diane',
      lastName: 'Magno',
      email: 'diane@pitakap.app',
    );

    test('toCreateMap writes a server timestamp and never the uid', () {
      final map = model.toCreateMap();

      expect(map[Keys.firstName], 'Diane');
      expect(map[Keys.lastName], 'Magno');
      expect(map[Keys.email], 'diane@pitakap.app');
      expect(map[Keys.defaultCurrency], Constants.defaultCurrency);
      expect(map[Keys.createdAt], isA<FieldValue>());
      expect(map.containsKey('uid'), isFalse);
    });

    test('toUpdateMap never rewrites the email or createdAt', () {
      final map = model.toUpdateMap();

      expect(map.containsKey(Keys.email), isFalse);
      expect(map.containsKey(Keys.createdAt), isFalse);
      expect(map[Keys.firstName], 'Diane');
    });
  });

  group('UserDetailsModel.fromEntity', () {
    test('copies every field across', () {
      final created = DateTime.utc(2026, 8, 9);
      final entity = UserDetailsEntity(
        uid: 'uid-1',
        firstName: 'Diane',
        lastName: 'Magno',
        email: 'diane@pitakap.app',
        defaultCurrency: 'USD',
        createdAt: created,
      );

      final model = UserDetailsModel.fromEntity(entity);

      expect(model, entity);
      expect(model.defaultCurrency, 'USD');
      expect(model.createdAt, created);
    });
  });
}
