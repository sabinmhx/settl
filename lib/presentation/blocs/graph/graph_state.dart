part of 'graph_bloc.dart';

enum GraphStatus { initial, loading, success, failure }

class GraphState extends Equatable {
  const GraphState({
    this.status = GraphStatus.initial,
    this.snapshot,
    this.selectedMemberId,
    this.errorMessage,
  });

  final GraphStatus status;
  final GraphSnapshot? snapshot;
  final String? selectedMemberId;
  final String? errorMessage;

  GraphState copyWith({
    GraphStatus? status,
    GraphSnapshot? snapshot,
    String? selectedMemberId,
    String? errorMessage,
    bool clearSelection = false,
  }) =>
      GraphState(
        status: status ?? this.status,
        snapshot: snapshot ?? this.snapshot,
        selectedMemberId:
            clearSelection ? null : (selectedMemberId ?? this.selectedMemberId),
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [status, snapshot, selectedMemberId, errorMessage];
}
