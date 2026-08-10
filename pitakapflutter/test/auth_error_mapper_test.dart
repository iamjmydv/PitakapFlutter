import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pitakapflutter/core/error/failure.dart';
import 'package:pitakapflutter/feature/auth/data/datasources/auth_error_mapper.dart';

void main() {
  group('AuthErrorMapper', () {
    test('passes an existing Failure straight through', () {
      const original = ServerFailure('already mapped');

      expect(identical(AuthErrorMapper.from(original), original), isTrue);
    });

    test('maps wrong credentials to one message that leaks nothing', () {
      const codes = ['user-not-found', 'wrong-password', 'invalid-credential'];

      for (final code in codes) {
        final failure = AuthErrorMapper.from(FirebaseAuthException(code: code));

        expect(failure, isA<ServerFailure>(), reason: code);
        expect(failure.message, 'Incorrect email or password', reason: code);
      }
    });

    test('maps a duplicate email to a distinct message', () {
      final failure = AuthErrorMapper.from(
        FirebaseAuthException(code: 'email-already-in-use'),
      );

      expect(failure.message, 'That email is already registered');
    });

    test('maps auth network trouble to NetworkFailure', () {
      final failure = AuthErrorMapper.from(
        FirebaseAuthException(code: 'network-request-failed'),
      );

      expect(failure, isA<NetworkFailure>());
      expect(failure.message, 'No internet connection');
    });

    test('maps an unreachable Firestore to NetworkFailure', () {
      final failure = AuthErrorMapper.from(
        FirebaseException(plugin: 'cloud_firestore', code: 'unavailable'),
      );

      expect(failure, isA<NetworkFailure>());
    });

    test('falls back to the Firebase message for unknown auth codes', () {
      final failure = AuthErrorMapper.from(
        FirebaseAuthException(code: 'weird-code', message: 'Something odd'),
      );

      expect(failure, isA<ServerFailure>());
      expect(failure.message, 'Something odd');
    });

    test('includes the code when Firebase gives no message', () {
      final failure = AuthErrorMapper.from(
        FirebaseAuthException(code: 'weird-code'),
      );

      expect(failure.message, contains('weird-code'));
    });

    test('maps anything else to UnknownFailure', () {
      final failure = AuthErrorMapper.from(StateError('boom'));

      expect(failure, isA<UnknownFailure>());
      expect(failure.message, contains('boom'));
    });

    test('every mapped failure is a sealed Failure', () {
      final errors = <Object>[
        FirebaseAuthException(code: 'user-disabled'),
        FirebaseAuthException(code: 'too-many-requests'),
        FirebaseAuthException(code: 'requires-recent-login'),
        FirebaseAuthException(code: 'operation-not-allowed'),
        FirebaseAuthException(code: 'weak-password'),
        FirebaseAuthException(code: 'invalid-email'),
        FirebaseException(plugin: 'cloud_firestore', code: 'permission-denied'),
        Exception('generic'),
      ];

      for (final error in errors) {
        final failure = AuthErrorMapper.from(error);

        expect(failure, isA<Failure>());
        expect(failure.message, isNotEmpty);
      }
    });
  });
}
