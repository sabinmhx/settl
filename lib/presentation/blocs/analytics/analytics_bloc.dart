import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/analytics.dart';
import '../../../domain/entities/group.dart';
import '../../../domain/repositories/ledger_repository.dart';
import '../../../domain/usecases/export_pdf_report.dart';
import '../../../domain/usecases/get_analytics.dart';

part 'analytics_event.dart';
part 'analytics_state.dart';

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  AnalyticsBloc(this._getAnalytics, this._exportPdf, this._repository)
      : super(const AnalyticsState()) {
    on<AnalyticsStarted>(_onStarted);
    on<AnalyticsExportPdf>(_onExport);
  }

  final GetAnalytics _getAnalytics;
  final ExportPdfReport _exportPdf;
  final LedgerRepository _repository;

  Future<void> _onStarted(
    AnalyticsStarted event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(state.copyWith(status: AnalyticsStatus.loading, group: event.group));
    try {
      final snapshot = await _getAnalytics(event.group.id);
      final categories =
          await _repository.getCategoryBreakdown(event.group.id);
      emit(state.copyWith(
        status: AnalyticsStatus.success,
        snapshot: snapshot,
        categoryBreakdown: categories,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AnalyticsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onExport(
    AnalyticsExportPdf event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(state.copyWith(isExporting: true));
    try {
      await _exportPdf(ExportPdfReportParams(groupId: state.group!.id));
    } finally {
      emit(state.copyWith(isExporting: false));
    }
  }
}
