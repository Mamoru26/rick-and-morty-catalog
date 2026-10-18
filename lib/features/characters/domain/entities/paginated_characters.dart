import 'package:equatable/equatable.dart';

import 'character.dart';

class PaginatedCharacters extends Equatable {
  const PaginatedCharacters({
    required this.characters,
    required this.hasNextPage,
  });

  const PaginatedCharacters.empty()
    : characters = const [],
      hasNextPage = false;

  final List<Character> characters;
  final bool hasNextPage;

  @override
  List<Object?> get props => [characters, hasNextPage];
}
