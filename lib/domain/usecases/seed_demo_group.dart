import '../entities/group.dart';
import '../repositories/ledger_repository.dart';
import 'usecase.dart';

class SeedDemoGroup extends UseCase<Group, NoParams> {
  SeedDemoGroup(this._repository);
  final LedgerRepository _repository;

  @override
  Future<Group> call(NoParams params) => _repository.seedDemoGroup();
}
