import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rick_and_morty_catalog/features/characters/data/datasources/characters_remote_data_source.dart';

import '../../../fixtures.dart';

class _MockDio extends Mock implements Dio {}

void main() {
  late _MockDio dio;
  late CharactersRemoteDataSource dataSource;
  final requestOptions = RequestOptions(path: '/character');

  setUp(() {
    dio = _MockDio();
    dataSource = CharactersRemoteDataSource(dio);
  });

  void stubGet(Future<Response<Map<String, dynamic>>> Function() answer) {
    when(
      () => dio.get<Map<String, dynamic>>(
        any(),
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer((_) => answer());
  }

  test('passes page and name to the API', () async {
    stubGet(
      () async => Response(
        data: pageJson(results: [characterJson()]),
        statusCode: 200,
        requestOptions: requestOptions,
      ),
    );

    final result = await dataSource.fetchCharacters(page: 2, query: 'rick');

    expect(result.characters.single.name, 'Rick Sanchez');
    verify(
      () => dio.get<Map<String, dynamic>>(
        '/character',
        queryParameters: {'page': 2, 'name': 'rick'},
      ),
    ).called(1);
  });

  test('does not send empty name', () async {
    stubGet(
      () async => Response(
        data: pageJson(results: []),
        statusCode: 200,
        requestOptions: requestOptions,
      ),
    );

    await dataSource.fetchCharacters(page: 1);

    verify(
      () => dio.get<Map<String, dynamic>>(
        '/character',
        queryParameters: {'page': 1},
      ),
    ).called(1);
  });

  test('treats 404 as an empty result', () async {
    stubGet(
      () => Future.error(
        DioException(
          requestOptions: requestOptions,
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 404,
            data: {'error': 'There is nothing here'},
            requestOptions: requestOptions,
          ),
        ),
      ),
    );

    final result = await dataSource.fetchCharacters(page: 1, query: 'zzz');

    expect(result.characters, isEmpty);
    expect(result.hasNextPage, isFalse);
  });
}
