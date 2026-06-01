import '../entities/analytics.dart';
import '../repositories/ledger_repository.dart';
import 'usecase.dart';

class GetGraphSnapshot extends UseCase<GraphSnapshot, String> {
  GetGraphSnapshot(this._repository);
  final LedgerRepository _repository;

  @override
  Future<GraphSnapshot> call(String groupId) =>
      _repository.getGraphSnapshot(groupId);
}
