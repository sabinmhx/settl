import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/entities/group.dart';
import '../../../domain/usecases/create_group.dart';

part 'create_group_state.dart';

class CreateGroupCubit extends Cubit<CreateGroupState> {
  CreateGroupCubit(this._createGroup) : super(const CreateGroupState());

  final CreateGroup _createGroup;

  void updateName(String name) => emit(state.copyWith(name: name));
  void updateDescription(String desc) => emit(state.copyWith(description: desc));

  void addMemberName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty || state.memberNames.contains(trimmed)) return;
    emit(state.copyWith(memberNames: [...state.memberNames, trimmed]));
  }

  void removeMemberName(String name) {
    emit(state.copyWith(
      memberNames: state.memberNames.where((m) => m != name).toList(),
    ));
  }

  Future<Group?> submit() async {
    emit(state.copyWith(status: CreateGroupStatus.submitting));
    final group = await _createGroup(CreateGroupParams(
      name: state.name,
      description: state.description,
      memberNames: state.memberNames,
    ));
    if (group == null) {
      emit(state.copyWith(
        status: CreateGroupStatus.failure,
        errorMessage: 'Enter a group name and at least one member.',
      ));
      return null;
    }
    emit(state.copyWith(status: CreateGroupStatus.success));
    return group;
  }
}
