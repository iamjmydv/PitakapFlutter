import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pitakapflutter/core/error/failure.dart';
import 'package:pitakapflutter/core/resources/keys.dart';
import 'package:pitakapflutter/feature/auth/data/datasources/auth_error_mapper.dart';
import 'package:pitakapflutter/feature/auth/data/model/user_details_model.dart';
import 'package:pitakapflutter/feature/auth/domain/usecases/login_user_usecase.dart';
import 'package:pitakapflutter/feature/auth/domain/usecases/send_password_reset_usecase.dart';
import 'package:pitakapflutter/feature/auth/domain/usecases/sign_up_user_usecase.dart';

abstract interface class AuthRemoteDatasource {
  Future<UserDetailsModel> signUp(SignUpUseCaseParams params);

  Future<UserDetailsModel> login(LoginUseCaseParams params);

  Future<void> sendPasswordReset(SendPasswordResetUseCaseParams params);

  Future<void> signOut();
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  const AuthRemoteDatasourceImpl({required this.auth, required this.firestore});

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) {
    return firestore.collection(Keys.userDetailsCollection).doc(uid);
  }

  @override
  Future<UserDetailsModel> signUp(SignUpUseCaseParams params) async {
    try {
      final credential = await auth.createUserWithEmailAndPassword(
        email: params.email,
        password: params.password,
      );

      final uid = credential.user?.uid;
      if (uid == null) {
        throw const UnknownFailure('Sign up did not return an account');
      }

      final profile = UserDetailsModel(
        uid: uid,
        firstName: params.firstName,
        lastName: params.lastName,
        email: params.email,
      );

      await _userDoc(uid).set(profile.toCreateMap());

      return profile;
    } catch (error) {
      throw AuthErrorMapper.from(error);
    }
  }

  @override
  Future<UserDetailsModel> login(LoginUseCaseParams params) async {
    try {
      final credential = await auth.signInWithEmailAndPassword(
        email: params.email,
        password: params.password,
      );

      final uid = credential.user?.uid;
      if (uid == null) {
        throw const UnknownFailure('Sign in did not return an account');
      }

      final snapshot = await _userDoc(uid).get();
      if (!snapshot.exists) {
        throw const ServerFailure('No profile found for this account');
      }

      return UserDetailsModel.fromDoc(snapshot);
    } catch (error) {
      throw AuthErrorMapper.from(error);
    }
  }

  @override
  Future<void> sendPasswordReset(SendPasswordResetUseCaseParams params) async {
    try {
      await auth.sendPasswordResetEmail(email: params.email);
    } catch (error) {
      throw AuthErrorMapper.from(error);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await auth.signOut();
    } catch (error) {
      throw AuthErrorMapper.from(error);
    }
  }
}
