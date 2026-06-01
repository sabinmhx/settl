import 'package:intl/intl.dart';

import '../entities/expense.dart';

class TrendAnalyzer {
  static Map<String, double> monthlySpendingTotals(List<Expense> expenses) {
    final formatter = DateFormat('yyyy-MM');
    final totals = <String, double>{};

    for (final expense in expenses) {
      final key = formatter.format(expense.createdAt);
      totals[key] = (totals[key] ?? 0) + expense.amount;
    }

    final sortedKeys = totals.keys.toList()..sort();
    return {for (final k in sortedKeys) k: totals[k]!};
  }

  static Map<String, double> categoryBreakdown(List<Expense> expenses) {
    final breakdown = <String, double>{};
    for (final expense in expenses) {
      final key = expense.category.label;
      breakdown[key] = (breakdown[key] ?? 0) + expense.amount;
    }
    return breakdown;
  }

  static Map<String, double> memberContributions(
    List<Expense> expenses,
    List<String> memberIds,
  ) {
    final contributions = {for (final id in memberIds) id: 0.0};
    for (final expense in expenses) {
      for (final entry in expense.payerAmounts.entries) {
        contributions[entry.key] =
            (contributions[entry.key] ?? 0) + entry.value;
      }
    }
    return contributions;
  }
}
