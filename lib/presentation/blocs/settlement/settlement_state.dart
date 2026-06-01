part of 'settlement_bloc.dart';

enum SettlementStatus { initial, loading, success, failure }

class SettlementState extends Equatable {
  const SettlementState({
    this.status = SettlementStatus.initial,
    this.optimization,
    this.netBalances = const {},
    this.rawEdgeCount = 0,
    this.expenses = const [],
    this.payments = const [],
    this.errorMessage,
  });

  final SettlementStatus status;
  final SettlementOptimizationResult? optimization;
  final Map<String, double> netBalances;
  final int rawEdgeCount;
  final List<Expense> expenses;
  final List<SettlementPayment> payments;
  final String? errorMessage;

  SettlementState copyWith({
    SettlementStatus? status,
    SettlementOptimizationResult? optimization,
    Map<String, double>? netBalances,
    int? rawEdgeCount,
    List<Expense>? expenses,
    List<SettlementPayment>? payments,
    String? errorMessage,
  }) =>
      SettlementState(
        status: status ?? this.status,
        optimization: optimization ?? this.optimization,
        netBalances: netBalances ?? this.netBalances,
        rawEdgeCount: rawEdgeCount ?? this.rawEdgeCount,
        expenses: expenses ?? this.expenses,
        payments: payments ?? this.payments,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [
        status,
        optimization,
        netBalances,
        rawEdgeCount,
        expenses,
        payments,
        errorMessage,
      ];
}
