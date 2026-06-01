import '../entities/settlement_payment.dart';
import '../repositories/ledger_repository.dart';
import 'usecase.dart';

class DeleteSettlementPayment extends UseCase<void, SettlementPayment> {
  DeleteSettlementPayment(this._repository);
  final LedgerRepository _repository;

  @override
  Future<void> call(SettlementPayment payment) =>
      _repository.deleteSettlementPayment(payment);
}
