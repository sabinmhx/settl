import '../entities/settlement.dart';
import '../repositories/ledger_repository.dart';
import 'usecase.dart';

class GetSettlement extends UseCase<SettlementOptimizationResult, String> {
  GetSettlement(this._repository);
  final LedgerRepository _repository;

  @override
  Future<SettlementOptimizationResult> call(String groupId) =>
      _repository.getSettlementOptimization(groupId);
}
