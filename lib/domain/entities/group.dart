import 'package:equatable/equatable.dart';

import 'member.dart';

class Group extends Equatable {
  const Group({
    required this.id,
    required this.name,
    required this.members,
    required this.createdAt,
    this.description = '',
  });

  final String id;
  final String name;
  final String description;
  final List<Member> members;
  final DateTime createdAt;

  Group copyWith({
    String? name,
    String? description,
    List<Member>? members,
  }) =>
      Group(
        id: id,
        name: name ?? this.name,
        description: description ?? this.description,
        members: members ?? this.members,
        createdAt: createdAt,
      );

  @override
  List<Object?> get props => [id, name, description, members, createdAt];
}
