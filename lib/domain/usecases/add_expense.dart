import 'package:uuid/uuid.dart';

import '../entities/expense.dart';
import '../repositories/ledger_repository.dart';
import 'usecase.dart';

class AddExpenseParams {
  AddExpenseParams({
    required this.groupId,
    required this.title,
    required this.payerAmounts,
    required this.category,
    required this.splitAmounts,
    this.note = '',
  });

  final String groupId;
  final String title;
  final Map<String, double> payerAmounts;
  final ExpenseCategory category;
  final Map<String, double> splitAmounts;
  final String note;

  double get amount =>
      payerAmounts.values.fold(0.0, (sum, value) => sum + value);
}

class AddExpense extends UseCase<void, AddExpenseParams> {
  AddExpense(this._repository);
  final LedgerRepository _repository;
  final _uuid = const Uuid();

  @override
  Future<void> call(AddExpenseParams params) async {
    if (params.amount <= 0) return;

    await _repository.saveExpense(Expense(
      id: _uuid.v4(),
      groupId: params.groupId,
      title: params.title.trim().isEmpty ? 'Expense' : params.title.trim(),
      amount: params.amount,
      payerAmounts: params.payerAmounts,
      splitAmounts: params.splitAmounts,
      category: params.category,
      createdAt: DateTime.now(),
      note: params.note,
    ));
  }

  static Map<String, double> equalSplit(List<String> memberIds, double amount) {
    if (memberIds.isEmpty) return {};
    final share = double.parse((amount / memberIds.length).toStringAsFixed(2));
    final splits = {for (final id in memberIds) id: share};
    final diff = amount - splits.values.reduce((a, b) => a + b);
    if (diff.abs() > 0.001) {
      splits[memberIds.first] = (splits[memberIds.first] ?? 0) + diff;
    }
    return splits;
  }

  static Map<String, double> parsePositiveAmounts(Map<String, String> texts) {
    final result = <String, double>{};
    for (final entry in texts.entries) {
      final value = double.tryParse(entry.value.replaceAll(',', '').trim());
      if (value != null && value > 0) {
        result[entry.key] = double.parse(value.toStringAsFixed(2));
      }
    }
    return result;
  }
}
