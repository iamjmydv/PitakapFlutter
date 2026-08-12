import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:pitakapflutter/core/error/failure.dart';
import 'package:pitakapflutter/feature/subscription/data/datasources/subscription_remote_datasource.dart';
import 'package:pitakapflutter/feature/subscription/data/model/subscription_model.dart';
import 'package:pitakapflutter/feature/subscription/data/repository/subscription_repository_impl.dart';
import 'package:pitakapflutter/feature/subscription/domain/usecases/create_subscription_usecase.dart';
import 'package:pitakapflutter/feature/subscription/domain/usecases/delete_subscription_usecase.dart';
import 'package:pitakapflutter/feature/subscription/domain/usecases/update_subscription_usecase.dart';

class MockSubscriptionRemoteDatasource extends Mock
    implements SubscriptionRemoteDatasource {}

final netflix = SubscriptionModel(
  id: 'sub-1',
  userId: 'uid-1',
  name: 'Netflix',
  category: 'entertainment',
  amount: 549,
  firstBillDate: DateTime(2026, 1, 31),
);

void main() {
  late MockSubscriptionRemoteDatasource remote;
  late SubscriptionRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(
      CreateSubscriptionUseCaseParams(
        userId: '',
        name: '',
        category: '',
        amount: 0,
        firstBillDate: DateTime(2026, 1, 1),
      ),
    );
    registerFallbackValue(UpdateSubscriptionUseCaseParams(netflix));
    registerFallbackValue(const DeleteSubscriptionUseCaseParams(''));
  });

  setUp(() {
    remote = MockSubscriptionRemoteDatasource();
    repository = SubscriptionRepositoryImpl(remote);
  });

  group('watchSubscriptions', () {
    test('forwards the datasource stream as entities', () {
      when(() => remote.watchSubscriptions(any()))
          .thenAnswer((_) => Stream.value([netflix]));

      expect(repository.watchSubscriptions('uid-1'), emits([netflix]));
      verify(() => remote.watchSubscriptions('uid-1')).called(1);
    });

    test('forwards stream errors without re-wrapping them', () {
      when(() => remote.watchSubscriptions(any())).thenAnswer(
        (_) => Stream.error(const NetworkFailure('No internet connection')),
      );

      expect(
        repository.watchSubscriptions('uid-1'),
        emitsError(isA<NetworkFailure>()),
      );
    });
  });

  group('createSubscription', () {
    final params = CreateSubscriptionUseCaseParams(
      userId: 'uid-1',
      name: 'Netflix',
      category: 'entertainment',
      amount: 549,
      firstBillDate: DateTime(2026, 1, 31),
    );

    test('delegates to the datasource', () async {
      when(() => remote.createSubscription(any())).thenAnswer((_) async {});

      await repository.createSubscription(params);

      verify(() => remote.createSubscription(params)).called(1);
      verifyNoMoreInteractions(remote);
    });

    test('lets mapped failures propagate', () {
      when(() => remote.createSubscription(any()))
          .thenThrow(const ServerFailure('You do not have access to this data'));

      expect(
        () => repository.createSubscription(params),
        throwsA(isA<ServerFailure>()),
      );
    });
  });

  group('updateSubscription', () {
    final params = UpdateSubscriptionUseCaseParams(netflix);

    test('delegates to the datasource', () async {
      when(() => remote.updateSubscription(any())).thenAnswer((_) async {});

      await repository.updateSubscription(params);

      verify(() => remote.updateSubscription(params)).called(1);
      verifyNoMoreInteractions(remote);
    });
  });

  group('deleteSubscription', () {
    const params = DeleteSubscriptionUseCaseParams('sub-1');

    test('delegates to the datasource', () async {
      when(() => remote.deleteSubscription(any())).thenAnswer((_) async {});

      await repository.deleteSubscription(params);

      verify(() => remote.deleteSubscription(params)).called(1);
      verifyNoMoreInteractions(remote);
    });

    test('lets mapped failures propagate', () {
      when(() => remote.deleteSubscription(any()))
          .thenThrow(const ServerFailure('That record no longer exists'));

      expect(
        () => repository.deleteSubscription(params),
        throwsA(isA<ServerFailure>()),
      );
    });
  });
}
