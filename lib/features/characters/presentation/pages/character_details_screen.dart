import 'package:flutter/material.dart';

import '../../domain/entities/character.dart';
import '../widgets/character_image.dart';
import '../widgets/character_list_tile.dart';
import '../widgets/character_status_view.dart';

class CharacterDetailsScreen extends StatelessWidget {
  const CharacterDetailsScreen({super.key, required this.character});

  final Character character;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 360,
            // Кнопка на подложке, чтобы её было видно на любой картинке.
            leading: Padding(
              padding: const EdgeInsets.all(6),
              child: IconButton.filledTonal(
                tooltip: 'Назад',
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: characterHeroTag(character),
                child: CharacterImage(url: character.imageUrl),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
            sliver: SliverList.list(
              children: [
                Text(character.name, style: theme.textTheme.headlineSmall),
                const SizedBox(height: 8),
                CharacterStatusView(
                  status: character.status,
                  species: character.species,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                _InfoTile(
                  icon: Icons.favorite_outline,
                  label: 'Статус',
                  value: character.status.label,
                ),
                _InfoTile(
                  icon: Icons.pets_outlined,
                  label: 'Вид',
                  value: character.species,
                ),
                if (character.type.isNotEmpty)
                  _InfoTile(
                    icon: Icons.category_outlined,
                    label: 'Подвид',
                    value: character.type,
                  ),
                _InfoTile(
                  icon: Icons.wc_outlined,
                  label: 'Пол',
                  value: character.gender,
                ),
                _InfoTile(
                  icon: Icons.public_outlined,
                  label: 'Происхождение',
                  value: character.originName,
                ),
                _InfoTile(
                  icon: Icons.place_outlined,
                  label: 'Текущая локация',
                  value: character.locationName,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Icon(icon),
    title: Text(label),
    subtitle: Text(value.isEmpty ? '—' : value),
  );
}
