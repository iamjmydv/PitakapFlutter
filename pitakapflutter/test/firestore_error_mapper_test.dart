import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pitakapflutter/core/error/failure.dart';
import 'package:pitakapflutter/core/error/firestore_error_mapper.dart';

FirebaseException firestoreError(String code, {String? message}) {
  return FirebaseException(
    plugin: 'cloud_firestore',
    code: code,
    message: message,
  );
}

void main() {
  group('FirestoreErrorMapper', () {
    test('passes an existing Failure straight through', () {
      const failure = ServerFailure('Already mapped');

      expect(FirestoreErrorMapper.from(failure), same(failure));
    });

    test('maps offline codes to a NetworkFailure', () {
      for (final code in ['unavailable', 'deadline-exceeded']) {
        expect(
          FirestoreErrorMapper.from(firestoreError(code)),
          isA<NetworkFailure>().having(
            (failure) => failure.message,
            'message',
            'No internet connection',
          ),
          reason: code,
        );
      }
    });

    test('maps a rules rejection to a readable ServerFailure', () {
      expect(
        FirestoreErrorMapper.from(firestoreError('permission-denied')),
        isA<ServerFailure>().having(
          (failure) => failure.message,
          'message',
          'You do not have access to this data',
        ),
      );
    });

    test('maps a missing document to a readable ServerFailure', () {
      expect(
        FirestoreErrorMapper.from(firestoreError('not-found')),
        isA<ServerFailure>().having(
          (failure) => failure.message,
          'message',
          'That record no longer exists',
        ),
      );
    });

    test('maps an expired session to a sign-in prompt', () {
      expect(
        FirestoreErrorMapper.from(firestoreError('unauthenticated')),
        isA<ServerFailure>().having(
          (failure) => failure.message,
          'message',
          'Please sign in again to continue',
        ),
      );
    });

    test('keeps the plugin message for an unmapped code', () {
      expect(
        FirestoreErrorMapper.from(
          firestoreError('aborted', message: 'Transaction aborted'),
        ),
        isA<ServerFailure>().having(
          (failure) => failure.message,
          'message',
          'Transaction aborted',
        ),
      );
    });

    test('names the code when an unmapped error carries no message', () {
      expect(
        FirestoreErrorMapper.from(firestoreError('aborted')),
        isA<ServerFailure>().having(
          (failure) => failure.message,
          'message',
          'Server error (aborted)',
        ),
      );
    });

    test('wraps anything else as an UnknownFailure', () {
      expect(
        FirestoreErrorMapper.from(StateError('boom')),
        isA<UnknownFailure>(),
      );
    });
  });
}
