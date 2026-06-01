import 'package:equatable/equatable.dart';

/// One person's debt to a specific payer for an expense (after partial payment).
class PayerDebtLine extends Equatable {
  const PayerDebtLine({
    required this.payerId,
    required this.grossOwed,
    required this.paidViaContribution,
    required this.remaining,
  });

  final String payerId;
  final double grossOwed;
  final double paidViaContribution;
  final double remaining;

  @override
  List<Object?> get props => [payerId, grossOwed, paidViaContribution, remaining];
}

/// Per-member status on a single expense.
class ExpenseMemberBalance extends Equatable {
  const ExpenseMemberBalance({
    required this.memberId,
    required this.shareOwed,
    required this.paidAmount,
    required this.remainingOwed,
    required this.linesToPayers,
  });

  final String memberId;
  final double shareOwed;
  final double paidAmount;
  final double remainingOwed;
  final List<PayerDebtLine> linesToPayers;

  @override
  List<Object?> get props =>
      [memberId, shareOwed, paidAmount, remainingOwed, linesToPayers];
}

/// Aggregated who-owes-whom across all expenses.
class MemberPairBalance extends Equatable {
  const MemberPairBalance({
    required this.fromId,
    required this.toId,
    required this.totalOwed,
    required this.expensePaid,
    required this.settlementPaid,
    required this.remaining,
  });

  final String fromId;
  final String toId;
  final double totalOwed;
  final double expensePaid;
  final double settlementPaid;
  final double remaining;

  double get totalPaid => expensePaid + settlementPaid;

  @override
  List<Object?> get props =>
      [fromId, toId, totalOwed, expensePaid, settlementPaid, remaining];
}

/// Summary for one member: who they owe and who owes them.
class MemberBalanceSummary extends Equatable {
  const MemberBalanceSummary({
    required this.memberId,
    required this.netBalance,
    required this.owesTo,
    required this.owedBy,
  });

  final String memberId;
  final double netBalance;
  final List<MemberPairBalance> owesTo;
  final List<MemberPairBalance> owedBy;

  @override
  List<Object?> get props => [memberId, netBalance, owesTo, owedBy];
}
