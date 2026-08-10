import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pitakapflutter/core/resources/constants.dart';
import 'package:pitakapflutter/core/resources/keys.dart';
import 'package:pitakapflutter/feature/auth/domain/entities/user_details_entity.dart';

class UserDetailsModel extends UserDetailsEntity {
  const UserDetailsModel({
    required super.uid,
    required super.firstName,
    required super.lastName,
    required super.email,
    super.defaultCurrency,
    super.createdAt,
  });

  factory UserDetailsModel.fromEntity(UserDetailsEntity entity) {
    return UserDetailsModel(
      uid: entity.uid,
      firstName: entity.firstName,
      lastName: entity.lastName,
      email: entity.email,
      defaultCurrency: entity.defaultCurrency,
      createdAt: entity.createdAt,
    );
  }

  factory UserDetailsModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    return UserDetailsModel.fromMap(doc.id, doc.data());
  }

  factory UserDetailsModel.fromMap(String uid, Map<String, dynamic>? data) {
    final map = data ?? const <String, dynamic>{};

    return UserDetailsModel(
      uid: uid,
      firstName: map[Keys.firstName] as String? ?? '',
      lastName: map[Keys.lastName] as String? ?? '',
      email: map[Keys.email] as String? ?? '',
      defaultCurrency:
          map[Keys.defaultCurrency] as String? ?? Constants.defaultCurrency,
      createdAt: (map[Keys.createdAt] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toCreateMap() => {
    Keys.firstName: firstName,
    Keys.lastName: lastName,
    Keys.email: email,
    Keys.defaultCurrency: defaultCurrency,
    Keys.createdAt: FieldValue.serverTimestamp(),
  };

  Map<String, dynamic> toUpdateMap() => {
    Keys.firstName: firstName,
    Keys.lastName: lastName,
    Keys.defaultCurrency: defaultCurrency,
  };
}
