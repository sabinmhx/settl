import '../entities/expense.dart';
import '../entities/settlement.dart';
import '../entities/settlement_payment.dart';

/// Builds weighted directed debt edges and net balances from expenses.
class DebtGraphEngine {
  static Map<String, double> computeNetBalances({
    required List<String> memberIds,
    required List<Expense> expenses,
    List<SettlementPayment> payments = const [],
  }) {
    final balances = {for (final id in memberIds) id: 0.0};

    for (final expense in expenses) {
      for (final entry in expense.payerAmounts.entries) {
        balances[entry.key] = (balances[entry.key] ?? 0) + entry.value;
      }
      for (final entry in expense.splitAmounts.entries) {
        balances[entry.key] = (balances[entry.key] ?? 0) - entry.value;
      }
    }

    applySettlementPayments(balances, payments);
    return balances;
  }

  static void applySettlementPayments(
    Map<String, double> balances,
    List<SettlementPayment> payments,
  ) {
    for (final payment in payments) {
      balances[payment.fromId] = (balances[payment.fromId] ?? 0) + payment.amount;
      balances[payment.toId] = (balances[payment.toId] ?? 0) - payment.amount;
    }
  }

  static List<DebtEdge> buildRawEdges(List<Expense> expenses) {
    final edgeMap = <String, double>{};

    void addEdge(String from, String to, double amount) {
      if (from == to || amount <= 0.0001) return;
      final key = '$from->$to';
      edgeMap[key] = (edgeMap[key] ?? 0) + amount;
    }

    for (final expense in expenses) {
      final totalPaid = expense.totalPaid;
      if (totalPaid <= 0.0001) continue;

      for (final split in expense.splitAmounts.entries) {
        for (final payer in expense.payerAmounts.entries) {
          final owedToPayer = split.value * (payer.value / totalPaid);
          addEdge(split.key, payer.key, owedToPayer);
        }
      }
    }

    return edgeMap.entries
        .map((e) {
          final parts = e.key.split('->');
          return DebtEdge(fromId: parts[0], toId: parts[1], amount: e.value);
        })
        .where((edge) => edge.amount > 0.0001)
        .toList();
  }

  static Map<String, double> eliminateCyclesViaNetBalances(
    Map<String, double> netBalances,
  ) {
    const epsilon = 0.01;
    return Map.fromEntries(
      netBalances.entries.where((e) => e.value.abs() > epsilon),
    );
  }

  static int countNonZeroEdges(List<DebtEdge> edges) =>
      edges.where((e) => e.amount > 0.01).length;
}
