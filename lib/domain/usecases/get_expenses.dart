import '../entities/expense.dart';
import '../repositories/ledger_repository.dart';
import 'usecase.dart';

class GetExpenses extends UseCase<List<Expense>, String> {
  GetExpenses(this._repository);
  final LedgerRepository _repository;

  @override
  Future<List<Expense>> call(String groupId) => _repository.getExpenses(groupId);
}
