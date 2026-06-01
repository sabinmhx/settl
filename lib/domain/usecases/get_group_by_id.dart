import '../entities/group.dart';
import '../repositories/ledger_repository.dart';
import 'usecase.dart';

class GetGroupById extends UseCase<Group?, String> {
  GetGroupById(this._repository);
  final LedgerRepository _repository;

  @override
  Future<Group?> call(String id) => _repository.getGroupById(id);
}
