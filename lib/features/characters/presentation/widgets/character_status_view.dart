import 'package:flutter/material.dart';

import '../../domain/entities/character.dart';

extension CharacterStatusX on CharacterStatus {
  String get label => switch (this) {
    CharacterStatus.alive => 'Жив',
    CharacterStatus.dead => 'Мёртв',
    CharacterStatus.unknown => 'Неизвестно',
  };

  Color get color => switch (this) {
    CharacterStatus.alive => const Color(0xFF55CC44),
    CharacterStatus.dead => const Color(0xFFD63D2E),
    CharacterStatus.unknown => const Color(0xFF9E9E9E),
  };
}

/// Цветная точка статуса и подпись «Жив · Human».
class CharacterStatusView extends StatelessWidget {
  const CharacterStatusView({
    super.key,
    required this.status,
    this.species,
    this.style,
  });

  final CharacterStatus status;
  final String? species;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final text = [
      status.label,
      if (species != null && species!.isNotEmpty) species!,
    ].join(' · ');
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: status.color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            style: style ?? Theme.of(context).textTheme.bodyMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
