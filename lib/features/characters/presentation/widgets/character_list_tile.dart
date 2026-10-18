import 'package:flutter/material.dart';

import '../../domain/entities/character.dart';
import 'character_image.dart';
import 'character_status_view.dart';

String characterHeroTag(Character character) => 'character-${character.id}';

class CharacterListTile extends StatelessWidget {
  const CharacterListTile({
    super.key,
    required this.character,
    required this.onTap,
  });

  final Character character;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Hero(
                tag: characterHeroTag(character),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CharacterImage(
                    url: character.imageUrl,
                    width: 72,
                    height: 72,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      character.name,
                      style: textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    CharacterStatusView(
                      status: character.status,
                      species: character.species,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
