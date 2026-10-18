import '../entities/paginated_characters.dart';

abstract interface class CharactersRepository {
  /// Загружает страницу персонажей. Пустой [query] — без фильтра по имени.
  ///
  /// Бросает `AppFailure`, если загрузка не удалась.
  Future<PaginatedCharacters> getCharacters({
    required int page,
    String query = '',
  });
}
