import '../repositories/ledger_repository.dart';
import 'usecase.dart';

class ExportPdfReportParams {
  ExportPdfReportParams({required this.groupId});
  final String groupId;
}

class ExportPdfReport extends UseCase<void, ExportPdfReportParams> {
  ExportPdfReport(this._repository);
  final LedgerRepository _repository;

  @override
  Future<void> call(ExportPdfReportParams params) =>
      _repository.exportGroupPdf(params.groupId);
}
