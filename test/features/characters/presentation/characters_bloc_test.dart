import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rick_and_morty_catalog/core/error/app_failure.dart';
import 'package:rick_and_morty_catalog/features/characters/domain/entities/paginated_characters.dart';
import 'package:rick_and_morty_catalog/features/characters/domain/repositories/characters_repository.dart';
import 'package:rick_and_morty_catalog/features/characters/presentation/bloc/characters_bloc.dart';

import '../../../fixtures.dart';

class _MockRepository extends Mock implements CharactersRepository {}

void main() {
  late _MockRepository repository;

  setUp(() => repository = _MockRepository());

  void stubPage(
    int pageNumber,
    PaginatedCharacters result, {
    String query = '',
  }) {
    when(() => repository.getCharacters(page: pageNumber, query: query))
        .thenAnswer((_) async => result);
  }

  final firstPageState = CharactersState(
    status: CharactersStatus.success,
    characters: page([1, 2]).characters,
    page: 1,
  );

  test('initial state', () {
    expect(CharactersBloc(repository).state, const CharactersState());
  });

  blocTest<CharactersBloc, CharactersState>(
    'loads the first page on start',
    setUp: () => stubPage(1, page([1, 2])),
    build: () => CharactersBloc(repository),
    act: (bloc) => bloc.add(const CharactersStarted()),
    expect: () => [
      const CharactersState(status: CharactersStatus.loading),
      firstPageState,
    ],
  );

  blocTest<CharactersBloc, CharactersState>(
    'emits failure when the first page fails',
    setUp: () =>
        when(() => repository.getCharacters(page: 1))
            .thenThrow(const AppFailure(FailureType.network)),
    build: () => CharactersBloc(repository),
    act: (bloc) => bloc.add(const CharactersStarted()),
    expect: () => [
      const CharactersState(status: CharactersStatus.loading),
      const CharactersState(
        status: CharactersStatus.failure,
        failure: AppFailure(FailureType.network),
      ),
    ],
  );

  blocTest<CharactersBloc, CharactersState>(
    'appends the next page and stops at the last one',
    setUp: () => stubPage(2, page([3], hasNextPage: false)),
    build: () => CharactersBloc(repository),
    seed: () => firstPageState,
    act: (bloc) => bloc.add(const CharactersNextPageRequested()),
    expect: () => [
      firstPageState.copyWith(isLoadingMore: true),
      firstPageState.copyWith(
        characters: page([1, 2, 3]).characters,
        page: 2,
        hasReachedMax: true,
      ),
    ],
  );

  blocTest<CharactersBloc, CharactersState>(
    'does not request more after the last page',
    build: () => CharactersBloc(repository),
    seed: () => firstPageState.copyWith(hasReachedMax: true),
    act: (bloc) => bloc.add(const CharactersNextPageRequested()),
    expect: () => <CharactersState>[],
    verify: (_) => verifyNever(
      () => repository.getCharacters(
        page: any(named: 'page'),
        query: any(named: 'query'),
      ),
    ),
  );

  blocTest<CharactersBloc, CharactersState>(
    'keeps loaded items when the next page fails',
    setUp: () =>
        when(() => repository.getCharacters(page: 2))
            .thenThrow(const AppFailure(FailureType.server)),
    build: () => CharactersBloc(repository),
    seed: () => firstPageState,
    act: (bloc) => bloc.add(const CharactersNextPageRequested()),
    expect: () => [
      firstPageState.copyWith(isLoadingMore: true),
      firstPageState.copyWith(
        loadMoreFailure: () => const AppFailure(FailureType.server),
      ),
    ],
  );

  blocTest<CharactersBloc, CharactersState>(
    'searches by trimmed name from the first page',
    setUp: () => stubPage(1, page([7], hasNextPage: false), query: 'rick'),
    build: () => CharactersBloc(repository),
    seed: () => firstPageState,
    act: (bloc) => bloc.add(const CharactersQueryChanged(' rick ')),
    expect: () => [
      const CharactersState(status: CharactersStatus.loading, query: 'rick'),
      CharactersState(
        status: CharactersStatus.success,
        characters: page([7]).characters,
        query: 'rick',
        page: 1,
        hasReachedMax: true,
      ),
    ],
  );

  blocTest<CharactersBloc, CharactersState>(
    'empty search result is a success with no items',
    setUp: () =>
        stubPage(1, const PaginatedCharacters.empty(), query: 'nobody'),
    build: () => CharactersBloc(repository),
    act: (bloc) => bloc.add(const CharactersQueryChanged('nobody')),
    skip: 1,
    verify: (bloc) => expect(bloc.state.isEmpty, isTrue),
  );
}
