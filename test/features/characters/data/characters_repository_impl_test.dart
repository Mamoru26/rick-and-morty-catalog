import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rick_and_morty_catalog/core/error/app_failure.dart';
import 'package:rick_and_morty_catalog/features/characters/data/datasources/characters_remote_data_source.dart';
import 'package:rick_and_morty_catalog/features/characters/data/repositories/characters_repository_impl.dart';

import '../../../fixtures.dart';

class _MockRemote extends Mock implements CharactersRemoteDataSource {}

void main() {
  late _MockRemote remote;
  late CharactersRepositoryImpl repository;

  setUp(() {
    remote = _MockRemote();
    repository = CharactersRepositoryImpl(remote);
  });

  void stubError(Object error) {
    when(
      () => remote.fetchCharacters(
        page: any(named: 'page'),
        query: any(named: 'query'),
      ),
    ).thenThrow(error);
  }

  test('trims the query before requesting', () async {
    when(() => remote.fetchCharacters(page: 1, query: 'rick'))
        .thenAnswer((_) async => page([1]));

    final result = await repository.getCharacters(page: 1, query: '  rick ');

    expect(result, page([1]));
  });

  test('maps connection errors to network failure', () {
    stubError(
      DioException(
        requestOptions: RequestOptions(),
        type: DioExceptionType.connectionError,
      ),
    );

    expect(
      () => repository.getCharacters(page: 1),
      throwsA(const AppFailure(FailureType.network)),
    );
  });

  test('maps bad responses to server failure', () {
    stubError(
      DioException(
        requestOptions: RequestOptions(),
        type: DioExceptionType.badResponse,
      ),
    );

    expect(
      () => repository.getCharacters(page: 1),
      throwsA(const AppFailure(FailureType.server)),
    );
  });

  test('maps unexpected exceptions to unknown failure', () {
    stubError(const FormatException('bad json'));

    expect(
      () => repository.getCharacters(page: 1),
      throwsA(const AppFailure(FailureType.unknown)),
    );
  });
}
