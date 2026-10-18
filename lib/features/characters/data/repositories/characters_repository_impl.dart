import 'package:dio/dio.dart';

import '../../../../core/error/app_failure.dart';
import '../../domain/entities/paginated_characters.dart';
import '../../domain/repositories/characters_repository.dart';
import '../datasources/characters_remote_data_source.dart';

class CharactersRepositoryImpl implements CharactersRepository {
  const CharactersRepositoryImpl(this._remote);

  final CharactersRemoteDataSource _remote;

  @override
  Future<PaginatedCharacters> getCharacters({
    required int page,
    String query = '',
  }) async {
    try {
      return await _remote.fetchCharacters(page: page, query: query.trim());
    } on DioException catch (e) {
      throw AppFailure(_failureType(e));
    } on Exception {
      throw const AppFailure(FailureType.unknown);
    }
  }

  FailureType _failureType(DioException e) => switch (e.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout ||
    DioExceptionType.connectionError => FailureType.network,
    DioExceptionType.badResponse => FailureType.server,
    _ => FailureType.unknown,
  };
}
