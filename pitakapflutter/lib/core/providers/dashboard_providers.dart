import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pitakapflutter/feature/dashboard/domain/usecases/get_spending_summary_usecase.dart';

final getSpendingSummaryUseCaseProvider = Provider<GetSpendingSummaryUseCase>(
  (ref) => const GetSpendingSummaryUseCase(),
);
