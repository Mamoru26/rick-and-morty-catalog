import 'package:rick_and_morty_catalog/features/characters/domain/entities/character.dart';
import 'package:rick_and_morty_catalog/features/characters/domain/entities/paginated_characters.dart';

Map<String, dynamic> characterJson({
  int id = 1,
  String name = 'Rick Sanchez',
  String status = 'Alive',
}) => {
  'id': id,
  'name': name,
  'status': status,
  'species': 'Human',
  'type': '',
  'gender': 'Male',
  'origin': {'name': 'Earth (C-137)', 'url': ''},
  'location': {'name': 'Citadel of Ricks', 'url': ''},
  'image': 'https://rickandmortyapi.com/api/character/avatar/$id.jpeg',
  'episode': <String>[],
  'url': 'https://rickandmortyapi.com/api/character/$id',
  'created': '2017-11-04T18:48:46.250Z',
};

Map<String, dynamic> pageJson({
  required List<Map<String, dynamic>> results,
  String? next,
}) => {
  'info': {'count': results.length, 'pages': 1, 'next': next, 'prev': null},
  'results': results,
};

Character character(int id, {String? name}) => Character(
  id: id,
  name: name ?? 'Character $id',
  status: CharacterStatus.alive,
  species: 'Human',
  type: '',
  gender: 'Male',
  imageUrl: '',
  originName: 'Earth (C-137)',
  locationName: 'Citadel of Ricks',
);

PaginatedCharacters page(List<int> ids, {bool hasNextPage = true}) =>
    PaginatedCharacters(
      characters: ids.map(character).toList(),
      hasNextPage: hasNextPage,
    );
