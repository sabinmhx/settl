import '../entities/expense.dart';
import '../repositories/ledger_repository.dart';
import 'add_expense.dart';
import 'usecase.dart';

class UpdateExpenseParams {
  UpdateExpenseParams({
    required this.expenseId,
    required this.groupId,
    required this.title,
    required this.amount,
    required this.payerAmounts,
    required this.category,
    required this.splitAmounts,
    required this.createdAt,
    this.note = '',
  });

  final String expenseId;
  final String groupId;
  final String title;
  final double amount;
  final Map<String, double> payerAmounts;
  final ExpenseCategory category;
  final Map<String, double> splitAmounts;
  final DateTime createdAt;
  final String note;
}

class UpdateExpense extends UseCase<void, UpdateExpenseParams> {
  UpdateExpense(this._repository);
  final LedgerRepository _repository;

  @override
  Future<void> call(UpdateExpenseParams params) async {
    if (params.amount <= 0) return;

    await _repository.saveExpense(Expense(
      id: params.expenseId,
      groupId: params.groupId,
      title: params.title.trim().isEmpty ? 'Expense' : params.title.trim(),
      amount: params.amount,
      payerAmounts: params.payerAmounts,
      splitAmounts: params.splitAmounts,
      category: params.category,
      createdAt: params.createdAt,
      note: params.note,
    ));
  }
}

/// Shared expense math helpers.
class ExpenseSplitHelper {
  ExpenseSplitHelper._();

  static Map<String, double> equalSplit(List<String> memberIds, double amount) =>
      AddExpense.equalSplit(memberIds, amount);

  static Map<String, double> parsePositiveAmounts(Map<String, String> texts) =>
      AddExpense.parsePositiveAmounts(texts);
}
