part of 'create_group_cubit.dart';

enum CreateGroupStatus { editing, submitting, success, failure }

class CreateGroupState extends Equatable {
  const CreateGroupState({
    this.status = CreateGroupStatus.editing,
    this.name = '',
    this.description = '',
    this.memberNames = const [],
    this.errorMessage,
  });

  final CreateGroupStatus status;
  final String name;
  final String description;
  final List<String> memberNames;
  final String? errorMessage;

  CreateGroupState copyWith({
    CreateGroupStatus? status,
    String? name,
    String? description,
    List<String>? memberNames,
    String? errorMessage,
  }) =>
      CreateGroupState(
        status: status ?? this.status,
        name: name ?? this.name,
        description: description ?? this.description,
        memberNames: memberNames ?? this.memberNames,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [status, name, description, memberNames, errorMessage];
}
