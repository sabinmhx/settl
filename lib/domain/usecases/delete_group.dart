import '../repositories/ledger_repository.dart';
import 'usecase.dart';

class DeleteGroup extends UseCase<void, String> {
  DeleteGroup(this._repository);
  final LedgerRepository _repository;

  @override
  Future<void> call(String id) => _repository.deleteGroup(id);
}
