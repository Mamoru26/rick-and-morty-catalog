import '../../domain/entities/character.dart';
import '../../domain/entities/paginated_characters.dart';

CharacterStatus characterStatusFromJson(String? raw) =>
    switch (raw?.toLowerCase()) {
      'alive' => CharacterStatus.alive,
      'dead' => CharacterStatus.dead,
      _ => CharacterStatus.unknown,
    };

Character characterFromJson(Map<String, dynamic> json) => Character(
  id: json['id'] as int,
  name: json['name'] as String? ?? '',
  status: characterStatusFromJson(json['status'] as String?),
  species: json['species'] as String? ?? '',
  type: json['type'] as String? ?? '',
  gender: json['gender'] as String? ?? '',
  imageUrl: json['image'] as String? ?? '',
  originName: _nestedName(json['origin']),
  locationName: _nestedName(json['location']),
);

PaginatedCharacters paginatedCharactersFromJson(Map<String, dynamic> json) {
  final info = json['info'] as Map<String, dynamic>? ?? const {};
  final results = json['results'] as List<dynamic>? ?? const [];
  return PaginatedCharacters(
    characters: results
        .cast<Map<String, dynamic>>()
        .map(characterFromJson)
        .toList(growable: false),
    hasNextPage: info['next'] != null,
  );
}

String _nestedName(Object? value) =>
    (value as Map<String, dynamic>?)?['name'] as String? ?? '';
