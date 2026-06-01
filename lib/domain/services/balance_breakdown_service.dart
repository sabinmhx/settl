import '../entities/balance_breakdown.dart';
import '../entities/expense.dart';
import '../entities/settlement_payment.dart';
import 'debt_graph_engine.dart';

class BalanceBreakdownService {
  static List<ExpenseMemberBalance> expenseMemberBalances(Expense expense) {
    final totalPaid = expense.totalPaid;
    if (totalPaid <= 0.001) return [];

    final participants = expense.splitAmounts.entries
        .where((e) => e.value > 0.001)
        .map((e) => e.key)
        .toList();

    return participants.map((memberId) {
      final share = expense.splitAmounts[memberId] ?? 0;
      final paid = expense.payerAmounts[memberId] ?? 0;

      final lines = <PayerDebtLine>[];
      for (final payer in expense.payerAmounts.entries) {
        if (payer.value <= 0.001) continue;
        final gross = share * (payer.value / totalPaid);
        final paidVia = paid * (payer.value / totalPaid);
        final remaining = (gross - paidVia).clamp(0.0, double.infinity);
        if (gross > 0.001) {
          lines.add(PayerDebtLine(
            payerId: payer.key,
            grossOwed: _round(gross),
            paidViaContribution: _round(paidVia),
            remaining: _round(remaining),
          ));
        }
      }

      final remainingOwed = (share - paid).clamp(0.0, double.infinity);

      return ExpenseMemberBalance(
        memberId: memberId,
        shareOwed: _round(share),
        paidAmount: _round(paid),
        remainingOwed: _round(remainingOwed),
        linesToPayers: lines,
      );
    }).toList();
  }

  static List<MemberPairBalance> pairBalances(
    List<Expense> expenses, {
    List<SettlementPayment> payments = const [],
  }) {
    final owed = <String, double>{};
    final expensePaid = <String, double>{};
    final settlementPaid = <String, double>{};

    void addExpense(String from, String to, double gross, double paidAmount) {
      if (from == to) return;
      final key = '$from->$to';
      owed[key] = (owed[key] ?? 0) + gross;
      expensePaid[key] = (expensePaid[key] ?? 0) + paidAmount;
    }

    for (final expense in expenses) {
      final total = expense.totalPaid;
      if (total <= 0.001) continue;

      for (final split in expense.splitAmounts.entries) {
        if (split.value <= 0.001) continue;
        final memberPaid = expense.payerAmounts[split.key] ?? 0;

        for (final payer in expense.payerAmounts.entries) {
          if (payer.value <= 0.001) continue;
          final gross = split.value * (payer.value / total);
          final paidVia = memberPaid * (payer.value / total);
          addExpense(split.key, payer.key, gross, paidVia);
        }
      }
    }

    for (final payment in payments) {
      if (payment.fromId == payment.toId) continue;
      final key = '${payment.fromId}->${payment.toId}';
      owed[key] = (owed[key] ?? 0);
      settlementPaid[key] = (settlementPaid[key] ?? 0) + payment.amount;
    }

    final keys = {...owed.keys, ...settlementPaid.keys};
    return keys.map((key) {
      final parts = key.split('->');
      final from = parts[0];
      final to = parts[1];
      final totalOwed = owed[key] ?? 0;
      final expPaid = expensePaid[key] ?? 0;
      final setPaid = settlementPaid[key] ?? 0;
      final remaining = (totalOwed - expPaid - setPaid).clamp(0.0, double.infinity);
      return MemberPairBalance(
        fromId: from,
        toId: to,
        totalOwed: _round(totalOwed),
        expensePaid: _round(expPaid),
        settlementPaid: _round(setPaid),
        remaining: _round(remaining),
      );
    }).where((p) => p.totalOwed > 0.01 || p.settlementPaid > 0.01).toList()
      ..sort((a, b) => b.remaining.compareTo(a.remaining));
  }

  static List<MemberBalanceSummary> memberSummaries({
    required List<String> memberIds,
    required List<Expense> expenses,
    List<SettlementPayment> payments = const [],
  }) {
    final pairs = pairBalances(expenses, payments: payments);
    final nets = DebtGraphEngine.computeNetBalances(
      memberIds: memberIds,
      expenses: expenses,
      payments: payments,
    );

    return memberIds.map((id) {
      final owesTo = pairs
          .where((p) => p.fromId == id && p.remaining > 0.01)
          .toList();
      final owedBy = pairs
          .where((p) => p.toId == id && p.remaining > 0.01)
          .toList();
      return MemberBalanceSummary(
        memberId: id,
        netBalance: _round(nets[id] ?? 0),
        owesTo: owesTo,
        owedBy: owedBy,
      );
    }).toList();
  }

  static double _round(double v) => double.parse(v.toStringAsFixed(2));
}
