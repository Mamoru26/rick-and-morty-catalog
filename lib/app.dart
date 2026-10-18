import 'package:flutter/material.dart';

import 'features/characters/presentation/pages/characters_screen.dart';

class RickAndMortyApp extends StatelessWidget {
  const RickAndMortyApp({super.key});

  static const _seedColor = Color(0xFF97CE4C);

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Rick and Morty',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(colorSchemeSeed: _seedColor),
    darkTheme: ThemeData(
      colorSchemeSeed: _seedColor,
      brightness: Brightness.dark,
    ),
    home: const CharactersScreen(),
  );
}
