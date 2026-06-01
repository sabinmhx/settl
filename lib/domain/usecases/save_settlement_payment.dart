import 'package:uuid/uuid.dart';

import '../entities/settlement_payment.dart';
import '../repositories/ledger_repository.dart';
import 'usecase.dart';

class SaveSettlementPaymentParams {
  SaveSettlementPaymentParams({
    required this.groupId,
    required this.fromId,
    required this.toId,
    required this.amount,
    this.note = '',
    this.existingId,
    this.createdAt,
  });

  final String groupId;
  final String fromId;
  final String toId;
  final double amount;
  final String note;
  final String? existingId;
  final DateTime? createdAt;
}

class SaveSettlementPayment extends UseCase<void, SaveSettlementPaymentParams> {
  SaveSettlementPayment(this._repository);
  final LedgerRepository _repository;
  final _uuid = const Uuid();

  @override
  Future<void> call(SaveSettlementPaymentParams params) async {
    if (params.amount <= 0) return;
    if (params.fromId == params.toId) return;

    await _repository.saveSettlementPayment(SettlementPayment(
      id: params.existingId ?? _uuid.v4(),
      groupId: params.groupId,
      fromId: params.fromId,
      toId: params.toId,
      amount: double.parse(params.amount.toStringAsFixed(2)),
      createdAt: params.createdAt ?? DateTime.now(),
      note: params.note,
    ));
  }
}
