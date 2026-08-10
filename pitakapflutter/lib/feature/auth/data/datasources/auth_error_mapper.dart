import 'package:firebase_auth/firebase_auth.dart';
import 'package:pitakapflutter/core/error/failure.dart';

abstract final class AuthErrorMapper {
  static Failure from(Object error) {
    if (error is Failure) return error;

    if (error is FirebaseAuthException) {
      if (error.code == 'network-request-failed') {
        return const NetworkFailure('No internet connection');
      }
      return ServerFailure(_authMessage(error));
    }

    if (error is FirebaseException) {
      if (error.code == 'unavailable') {
        return const NetworkFailure('No internet connection');
      }
      return ServerFailure(error.message ?? 'Server error (${error.code})');
    }

    return UnknownFailure(error.toString());
  }

  static String _authMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'Enter a valid email';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password';
      case 'email-already-in-use':
        return 'That email is already registered';
      case 'weak-password':
        return 'Password is too weak, use at least 6 characters';
      case 'too-many-requests':
        return 'Too many attempts, please try again later';
      case 'requires-recent-login':
        return 'Please sign in again to continue';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled';
      default:
        return error.message ?? 'Authentication error (${error.code})';
    }
  }
}
