part of 'settlement_bloc.dart';

abstract class SettlementEvent extends Equatable {
  const SettlementEvent();
  @override
  List<Object?> get props => [];
}

class SettlementStarted extends SettlementEvent {
  const SettlementStarted(this.groupId);
  final String groupId;
  @override
  List<Object?> get props => [groupId];
}

class SettlementPaymentSaved extends SettlementEvent {
  const SettlementPaymentSaved(this.params);
  final SaveSettlementPaymentParams params;
  @override
  List<Object?> get props => [params];
}

class SettlementPaymentDeleted extends SettlementEvent {
  const SettlementPaymentDeleted(this.payment);
  final SettlementPayment payment;
  @override
  List<Object?> get props => [payment];
}
