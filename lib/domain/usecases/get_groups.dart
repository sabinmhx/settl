import '../entities/group.dart';
import '../repositories/ledger_repository.dart';
import 'usecase.dart';

class GetGroups extends UseCase<List<Group>, NoParams> {
  GetGroups(this._repository);
  final LedgerRepository _repository;

  @override
  Future<List<Group>> call(NoParams params) => _repository.getGroups();
}
