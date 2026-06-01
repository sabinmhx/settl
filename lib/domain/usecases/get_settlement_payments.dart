import '../entities/settlement_payment.dart';
import '../repositories/ledger_repository.dart';
import 'usecase.dart';

class GetSettlementPayments extends UseCase<List<SettlementPayment>, String> {
  GetSettlementPayments(this._repository);
  final LedgerRepository _repository;

  @override
  Future<List<SettlementPayment>> call(String groupId) =>
      _repository.getSettlementPayments(groupId);
}
