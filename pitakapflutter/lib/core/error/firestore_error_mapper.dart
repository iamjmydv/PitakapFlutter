import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pitakapflutter/core/error/failure.dart';

abstract final class FirestoreErrorMapper {
  static Failure from(Object error) {
    if (error is Failure) return error;

    if (error is FirebaseException) {
      switch (error.code) {
        case 'unavailable':
        case 'deadline-exceeded':
          return const NetworkFailure('No internet connection');
        case 'permission-denied':
          return const ServerFailure('You do not have access to this data');
        case 'not-found':
          return const ServerFailure('That record no longer exists');
        case 'already-exists':
          return const ServerFailure('That record already exists');
        case 'resource-exhausted':
          return const ServerFailure('Too many requests, please try again later');
        case 'unauthenticated':
          return const ServerFailure('Please sign in again to continue');
        default:
          return ServerFailure(error.message ?? 'Server error (${error.code})');
      }
    }

    return UnknownFailure(error.toString());
  }
}
