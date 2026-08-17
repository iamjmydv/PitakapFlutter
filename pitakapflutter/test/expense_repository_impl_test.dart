import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:pitakapflutter/core/error/failure.dart';
import 'package:pitakapflutter/feature/expense/data/datasources/expense_remote_datasource.dart';
import 'package:pitakapflutter/feature/expense/data/model/expense_model.dart';
import 'package:pitakapflutter/feature/expense/data/repository/expense_repository_impl.dart';
import 'package:pitakapflutter/feature/expense/domain/usecases/create_expense_usecase.dart';
import 'package:pitakapflutter/feature/expense/domain/usecases/delete_expense_usecase.dart';
import 'package:pitakapflutter/feature/expense/domain/usecases/update_expense_usecase.dart';
import 'package:pitakapflutter/feature/expense/domain/usecases/watch_expenses_for_day_usecase.dart';

class MockExpenseRemoteDatasource extends Mock
    implements ExpenseRemoteDatasource {}

ExpenseModel model({
  String id = 'exp-1',
  double amount = 250,
  DateTime? createdAt,
}) {
  return ExpenseModel(
    id: id,
    userId: 'uid-1',
    description: 'Lunch at Jollibee',
    category: 'food',
    amount: amount,
    date: DateTime(2026, 8, 15),
    createdAt: createdAt,
  );
}

void main() {
  late MockExpenseRemoteDatasource remote;
  late ExpenseRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(
      CreateExpenseUseCaseParams(
        userId: '',
        description: '',
        category: '',
        amount: 0,
        date: DateTime(2026),
      ),
    );
    registerFallbackValue(UpdateExpenseUseCaseParams(model()));
    registerFallbackValue(const DeleteExpenseUseCaseParams(''));
    registerFallbackValue(
      WatchExpensesForDayParams(userId: '', day: DateTime(2026)),
    );
  });

  setUp(() {
    remote = MockExpenseRemoteDatasource();
    repository = ExpenseRepositoryImpl(remote);
  });

  group('watchExpensesForDay', () {
    test('passes the params through and returns the models as entities', () {
      final params = WatchExpensesForDayParams(
        userId: 'uid-1',
        day: DateTime(2026, 8, 15),
      );

      when(
        () => remote.watchExpensesForDay(any()),
      ).thenAnswer((_) => Stream.value([model()]));

      expect(repository.watchExpensesForDay(params), emits([model()]));
      verify(() => remote.watchExpensesForDay(params)).called(1);
    });

    test('lets a mapped failure reach the caller', () {
      when(() => remote.watchExpensesForDay(any())).thenAnswer(
        (_) => Stream.error(const ServerFailure('Not allowed')),
      );

      expect(
        repository.watchExpensesForDay(
          WatchExpensesForDayParams(userId: 'uid-1', day: DateTime(2026)),
        ),
        emitsError(isA<ServerFailure>()),
      );
    });
  });

  group('write operations delegate without reshaping', () {
    test('create', () async {
      when(() => remote.createExpense(any())).thenAnswer((_) async {});

      final params = CreateExpenseUseCaseParams(
        userId: 'uid-1',
        description: 'Milk tea',
        category: 'food',
        amount: 150,
        date: DateTime(2026, 8, 15),
      );

      await repository.createExpense(params);

      verify(() => remote.createExpense(params)).called(1);
    });

    test('update', () async {
      when(() => remote.updateExpense(any())).thenAnswer((_) async {});

      final params = UpdateExpenseUseCaseParams(model());

      await repository.updateExpense(params);

      verify(() => remote.updateExpense(params)).called(1);
    });

    test('delete', () async {
      when(() => remote.deleteExpense(any())).thenAnswer((_) async {});

      const params = DeleteExpenseUseCaseParams('exp-1');

      await repository.deleteExpense(params);

      verify(() => remote.deleteExpense(params)).called(1);
    });

    test('a write failure propagates unchanged', () {
      when(
        () => remote.deleteExpense(any()),
      ).thenThrow(const NetworkFailure('No internet connection'));

      expect(
        () => repository.deleteExpense(const DeleteExpenseUseCaseParams('x')),
        throwsA(isA<NetworkFailure>()),
      );
    });
  });

  group('compareNewest', () {
    test('orders the most recently created first', () {
      final older = model(id: 'a', createdAt: DateTime(2026, 8, 15, 9));
      final newer = model(id: 'b', createdAt: DateTime(2026, 8, 15, 18));

      final sorted = [older, newer]..sort(compareNewest);

      expect(sorted.map((e) => e.id), ['b', 'a']);
    });

    test('a pending server timestamp sorts first, because it was just '
        'written on this device', () {
      final saved = model(id: 'a', createdAt: DateTime(2026, 8, 15, 9));
      final pending = model(id: 'b');

      final sorted = [saved, pending]..sort(compareNewest);

      expect(sorted.map((e) => e.id), ['b', 'a']);
    });

    test('equal timestamps break by id so the order never wobbles', () {
      final at = DateTime(2026, 8, 15, 9);
      final first = model(id: 'a', createdAt: at);
      final second = model(id: 'b', createdAt: at);

      expect(([second, first]..sort(compareNewest)).map((e) => e.id), [
        'a',
        'b',
      ]);
      expect(([first, second]..sort(compareNewest)).map((e) => e.id), [
        'a',
        'b',
      ]);
    });

    test('two pending writes still order deterministically', () {
      final a = model(id: 'a');
      final b = model(id: 'b');

      expect(([b, a]..sort(compareNewest)).map((e) => e.id), ['a', 'b']);
    });
  });
}
