import '../entities/expense.dart';
import '../repositories/ledger_repository.dart';
import 'usecase.dart';

class DeleteExpense extends UseCase<void, Expense> {
  DeleteExpense(this._repository);
  final LedgerRepository _repository;

  @override
  Future<void> call(Expense expense) => _repository.deleteExpense(expense);
}
