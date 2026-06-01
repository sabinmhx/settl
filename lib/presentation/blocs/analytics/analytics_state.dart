part of 'analytics_bloc.dart';

enum AnalyticsStatus { initial, loading, success, failure }

class AnalyticsState extends Equatable {
  const AnalyticsState({
    this.status = AnalyticsStatus.initial,
    this.group,
    this.snapshot,
    this.categoryBreakdown = const {},
    this.isExporting = false,
    this.errorMessage,
  });

  final AnalyticsStatus status;
  final Group? group;
  final GroupAnalyticsSnapshot? snapshot;
  final Map<String, double> categoryBreakdown;
  final bool isExporting;
  final String? errorMessage;

  AnalyticsState copyWith({
    AnalyticsStatus? status,
    Group? group,
    GroupAnalyticsSnapshot? snapshot,
    Map<String, double>? categoryBreakdown,
    bool? isExporting,
    String? errorMessage,
  }) =>
      AnalyticsState(
        status: status ?? this.status,
        group: group ?? this.group,
        snapshot: snapshot ?? this.snapshot,
        categoryBreakdown: categoryBreakdown ?? this.categoryBreakdown,
        isExporting: isExporting ?? this.isExporting,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props =>
      [status, group, snapshot, categoryBreakdown, isExporting, errorMessage];
}
