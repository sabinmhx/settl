import 'package:equatable/equatable.dart';

class Member extends Equatable {
  const Member({
    required this.id,
    required this.name,
    this.colorHex = 0xFF3D5AFE,
  });

  final String id;
  final String name;
  final int colorHex;

  Member copyWith({String? name, int? colorHex}) => Member(
        id: id,
        name: name ?? this.name,
        colorHex: colorHex ?? this.colorHex,
      );

  @override
  List<Object?> get props => [id, name, colorHex];
}
