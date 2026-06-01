import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/analytics.dart';
import '../../../domain/usecases/get_graph_snapshot.dart';

part 'graph_event.dart';
part 'graph_state.dart';

class GraphBloc extends Bloc<GraphEvent, GraphState> {
  GraphBloc(this._getGraph) : super(const GraphState()) {
    on<GraphStarted>(_onStarted);
    on<GraphMemberSelected>(_onSelect);
  }

  final GetGraphSnapshot _getGraph;

  Future<void> _onStarted(GraphStarted event, Emitter<GraphState> emit) async {
    emit(state.copyWith(status: GraphStatus.loading));
    try {
      final snapshot = await _getGraph(event.groupId);
      emit(state.copyWith(status: GraphStatus.success, snapshot: snapshot));
    } catch (e) {
      emit(state.copyWith(
        status: GraphStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onSelect(GraphMemberSelected event, Emitter<GraphState> emit) {
    emit(state.copyWith(
      selectedMemberId: event.memberId == state.selectedMemberId
          ? null
          : event.memberId,
    ));
  }
}
