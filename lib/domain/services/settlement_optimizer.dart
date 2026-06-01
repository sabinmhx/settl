import '../entities/settlement.dart';

class SettlementOptimizer {
  static const _epsilon = 0.01;

  static List<SettlementTransaction> optimize(
    Map<String, double> netBalances,
  ) {
    final creditors = <_BalanceNode>[];
    final debtors = <_BalanceNode>[];

    for (final entry in netBalances.entries) {
      if (entry.value > _epsilon) {
        creditors.add(_BalanceNode(entry.key, entry.value));
      } else if (entry.value < -_epsilon) {
        debtors.add(_BalanceNode(entry.key, -entry.value));
      }
    }

    creditors.sort((a, b) => b.amount.compareTo(a.amount));
    debtors.sort((a, b) => b.amount.compareTo(a.amount));

    final settlements = <SettlementTransaction>[];
    var i = 0;
    var j = 0;

    while (i < creditors.length && j < debtors.length) {
      final creditor = creditors[i];
      final debtor = debtors[j];
      final transfer = creditor.amount < debtor.amount
          ? creditor.amount
          : debtor.amount;

      if (transfer > _epsilon) {
        settlements.add(SettlementTransaction(
          fromId: debtor.id,
          toId: creditor.id,
          amount: _round(transfer),
        ));
      }

      creditor.amount -= transfer;
      debtor.amount -= transfer;

      if (creditor.amount <= _epsilon) i++;
      if (debtor.amount <= _epsilon) j++;
    }

    return settlements;
  }

  static SettlementOptimizationResult analyze({
    required Map<String, double> netBalances,
    required int rawEdgeCount,
  }) {
    final optimized = optimize(netBalances);
    final naiveCount =
        rawEdgeCount > 0 ? rawEdgeCount : _estimateNaiveCount(netBalances);

    return SettlementOptimizationResult(
      settlements: optimized,
      naiveTransactionCount: naiveCount,
      optimizedTransactionCount: optimized.length,
      savingsCount: (naiveCount - optimized.length).clamp(0, naiveCount),
    );
  }

  static int _estimateNaiveCount(Map<String, double> netBalances) {
    final creditors = netBalances.values.where((v) => v > _epsilon).length;
    final debtors = netBalances.values.where((v) => v < -_epsilon).length;
    return creditors + debtors > 0 ? creditors + debtors - 1 : 0;
  }

  static double _round(double v) => double.parse(v.toStringAsFixed(2));
}

class _BalanceNode {
  _BalanceNode(this.id, this.amount);
  final String id;
  double amount;
}
