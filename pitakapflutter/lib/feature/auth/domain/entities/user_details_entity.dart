import 'package:pitakapflutter/core/resources/constants.dart';

class UserDetailsEntity {
  final String uid;
  final String firstName;
  final String lastName;
  final String email;
  final String defaultCurrency;
  final DateTime? createdAt;

  const UserDetailsEntity({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.defaultCurrency = Constants.defaultCurrency,
    this.createdAt,
  });

  String get fullName => '$firstName $lastName'.trim();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is UserDetailsEntity &&
            other.uid == uid &&
            other.firstName == firstName &&
            other.lastName == lastName &&
            other.email == email &&
            other.defaultCurrency == defaultCurrency &&
            other.createdAt == createdAt;
  }

  @override
  int get hashCode =>
      Object.hash(uid, firstName, lastName, email, defaultCurrency, createdAt);
}
