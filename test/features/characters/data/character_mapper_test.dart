import 'package:flutter_test/flutter_test.dart';
import 'package:rick_and_morty_catalog/features/characters/data/models/character_mapper.dart';
import 'package:rick_and_morty_catalog/features/characters/domain/entities/character.dart';

import '../../../fixtures.dart';

void main() {
  group('characterFromJson', () {
    test('maps API fields to entity', () {
      final result = characterFromJson(characterJson());

      expect(result.id, 1);
      expect(result.name, 'Rick Sanchez');
      expect(result.status, CharacterStatus.alive);
      expect(result.species, 'Human');
      expect(result.gender, 'Male');
      expect(result.originName, 'Earth (C-137)');
      expect(result.locationName, 'Citadel of Ricks');
      expect(result.imageUrl, endsWith('/1.jpeg'));
    });

    test('maps status case-insensitively, unknown values to unknown', () {
      expect(characterStatusFromJson('Dead'), CharacterStatus.dead);
      expect(characterStatusFromJson('alive'), CharacterStatus.alive);
      expect(characterStatusFromJson('unknown'), CharacterStatus.unknown);
      expect(characterStatusFromJson(null), CharacterStatus.unknown);
    });
  });

  group('paginatedCharactersFromJson', () {
    test('hasNextPage is true when info.next is set', () {
      final result = paginatedCharactersFromJson(
        pageJson(results: [characterJson()], next: 'https://next'),
      );

      expect(result.characters, hasLength(1));
      expect(result.hasNextPage, isTrue);
    });

    test('hasNextPage is false on the last page', () {
      final result = paginatedCharactersFromJson(
        pageJson(results: [characterJson()]),
      );

      expect(result.hasNextPage, isFalse);
    });
  });
}
