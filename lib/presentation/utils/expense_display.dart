import '../../domain/entities/expense.dart';
import '../../domain/entities/member.dart';
import '../../core/utils/currency_formatter.dart';

/// Display helpers for expense payers in the UI.
class ExpenseDisplay {
  static String payerSummary(Expense expense, List<Member> members) {
    if (expense.payerAmounts.isEmpty) return 'Unknown';

    final names = {for (final m in members) m.id: m.name};

    if (expense.payerAmounts.length == 1) {
      final id = expense.payerAmounts.keys.first;
      return names[id] ?? id;
    }

    final parts = expense.payerAmounts.entries.map((e) {
      final name = names[e.key] ?? e.key;
      return '$name ${formatMoney(e.value)}';
    });
    return parts.join(' · ');
  }

  static String splitSummary(Expense expense, List<Member> members) {
    final names = {for (final m in members) m.id: m.name};
    final shares = expense.splitAmounts.entries.where((e) => e.value > 0.001).toList();
    if (shares.isEmpty) return '';

    if (shares.length == 1) {
      final e = shares.first;
      return '${names[e.key] ?? e.key} owes ${formatMoney(e.value)}';
    }

    final values = shares.map((e) => e.value).toList();
    final mean = values.reduce((a, b) => a + b) / values.length;
    final isEqual = values.every((v) => (v - mean).abs() < 0.03);

    if (isEqual) {
      return '${shares.length} people · ${formatMoney(mean)} each';
    }

    return shares
        .map((e) => '${names[e.key] ?? e.key} ${formatMoney(e.value)}')
        .join(' · ');
  }

  static String payerLabel(Expense expense) {
    final count = expense.payerAmounts.length;
    if (count <= 1) return 'paid';
    return '$count people paid';
  }
}
