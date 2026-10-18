import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rick_and_morty_catalog/core/error/app_failure.dart';
import 'package:rick_and_morty_catalog/features/characters/presentation/bloc/characters_bloc.dart';
import 'package:rick_and_morty_catalog/features/characters/presentation/pages/characters_screen.dart';

import '../../../fixtures.dart';

class _MockCharactersBloc extends MockBloc<CharactersEvent, CharactersState>
    implements CharactersBloc {}

void main() {
  late _MockCharactersBloc bloc;

  setUp(() => bloc = _MockCharactersBloc());

  Future<void> pumpScreen(WidgetTester tester, CharactersState state) {
    when(() => bloc.state).thenReturn(state);
    return tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<CharactersBloc>.value(
          value: bloc,
          child: const CharactersView(),
        ),
      ),
    );
  }

  testWidgets('shows a progress indicator while loading', (tester) async {
    await pumpScreen(
      tester,
      const CharactersState(status: CharactersStatus.loading),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows characters', (tester) async {
    await pumpScreen(
      tester,
      CharactersState(
        status: CharactersStatus.success,
        characters: [character(1, name: 'Rick Sanchez')],
        page: 1,
        hasReachedMax: true,
      ),
    );

    expect(find.text('Rick Sanchez'), findsOneWidget);
    expect(find.text('Жив · Human'), findsOneWidget);
  });

  testWidgets('shows empty state for a search without results', (tester) async {
    await pumpScreen(
      tester,
      const CharactersState(status: CharactersStatus.success, query: 'nobody'),
    );

    expect(find.text('Ничего не найдено'), findsOneWidget);
  });

  testWidgets('retries after an error', (tester) async {
    await pumpScreen(
      tester,
      const CharactersState(
        status: CharactersStatus.failure,
        failure: AppFailure(FailureType.network),
      ),
    );

    await tester.tap(find.text('Повторить'));

    verify(() => bloc.add(const CharactersRetryRequested())).called(1);
  });

  testWidgets('sends the search query after the debounce', (tester) async {
    await pumpScreen(
      tester,
      const CharactersState(status: CharactersStatus.loading),
    );

    await tester.enterText(find.byType(TextField), 'morty');
    verifyNever(() => bloc.add(const CharactersQueryChanged('morty')));

    await tester.pump(const Duration(milliseconds: 400));
    verify(() => bloc.add(const CharactersQueryChanged('morty'))).called(1);
  });

  testWidgets('opens details on tap', (tester) async {
    await pumpScreen(
      tester,
      CharactersState(
        status: CharactersStatus.success,
        characters: [character(1, name: 'Rick Sanchez')],
        page: 1,
        hasReachedMax: true,
      ),
    );

    await tester.tap(find.text('Rick Sanchez'));
    await tester.pumpAndSettle();

    expect(find.text('Статус'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Текущая локация'), 200);
    expect(find.text('Происхождение'), findsOneWidget);
    expect(find.text('Earth (C-137)'), findsOneWidget);
    expect(find.text('Citadel of Ricks'), findsOneWidget);
  });
}
