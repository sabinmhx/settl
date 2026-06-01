import '../entities/analytics.dart';
import '../repositories/ledger_repository.dart';
import 'usecase.dart';

class GetAnalytics extends UseCase<GroupAnalyticsSnapshot, String> {
  GetAnalytics(this._repository);
  final LedgerRepository _repository;

  @override
  Future<GroupAnalyticsSnapshot> call(String groupId) =>
      _repository.getAnalytics(groupId);
}
