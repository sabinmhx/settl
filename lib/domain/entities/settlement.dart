import 'package:equatable/equatable.dart';

class SettlementTransaction extends Equatable {
  const SettlementTransaction({
    required this.fromId,
    required this.toId,
    required this.amount,
  });

  final String fromId;
  final String toId;
  final double amount;

  @override
  List<Object?> get props => [fromId, toId, amount];
}

class DebtEdge extends Equatable {
  const DebtEdge({
    required this.fromId,
    required this.toId,
    required this.amount,
  });

  final String fromId;
  final String toId;
  final double amount;

  @override
  List<Object?> get props => [fromId, toId, amount];
}

class SettlementOptimizationResult extends Equatable {
  const SettlementOptimizationResult({
    required this.settlements,
    required this.naiveTransactionCount,
    required this.optimizedTransactionCount,
    required this.savingsCount,
  });

  final List<SettlementTransaction> settlements;
  final int naiveTransactionCount;
  final int optimizedTransactionCount;
  final int savingsCount;

  String get summaryMessage {
    if (naiveTransactionCount <= optimizedTransactionCount) {
      return '$optimizedTransactionCount transaction(s) needed to settle all balances.';
    }
    return 'Instead of $naiveTransactionCount transactions, only '
        '$optimizedTransactionCount ${optimizedTransactionCount == 1 ? 'is' : 'are'} needed.';
  }

  @override
  List<Object?> get props =>
      [settlements, naiveTransactionCount, optimizedTransactionCount, savingsCount];
}
