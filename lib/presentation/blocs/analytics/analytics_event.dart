part of 'analytics_bloc.dart';

abstract class AnalyticsEvent extends Equatable {
  const AnalyticsEvent();
  @override
  List<Object?> get props => [];
}

class AnalyticsStarted extends AnalyticsEvent {
  const AnalyticsStarted(this.group);
  final Group group;
  @override
  List<Object?> get props => [group];
}

class AnalyticsExportPdf extends AnalyticsEvent {}
