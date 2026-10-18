import 'package:dio/dio.dart';

import '../../domain/entities/paginated_characters.dart';
import '../models/character_mapper.dart';

class CharactersRemoteDataSource {
  const CharactersRemoteDataSource(this._dio);

  final Dio _dio;

  Future<PaginatedCharacters> fetchCharacters({
    required int page,
    String query = '',
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/character',
        queryParameters: {'page': page, if (query.isNotEmpty) 'name': query},
      );
      return paginatedCharactersFromJson(response.data ?? const {});
    } on DioException catch (e) {
      // Если по имени ничего не нашлось, API отвечает 404
      // {"error": "There is nothing here"} — это пустой результат, а не ошибка.
      if (e.response?.statusCode == 404) {
        return const PaginatedCharacters.empty();
      }
      rethrow;
    }
  }
}
