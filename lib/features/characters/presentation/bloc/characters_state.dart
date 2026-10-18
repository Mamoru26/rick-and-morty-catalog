part of 'characters_bloc.dart';

enum CharactersStatus { initial, loading, success, failure }

final class CharactersState extends Equatable {
  const CharactersState({
    this.status = CharactersStatus.initial,
    this.characters = const [],
    this.query = '',
    this.page = 0,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
    this.failure,
    this.loadMoreFailure,
  });

  final CharactersStatus status;
  final List<Character> characters;
  final String query;

  /// Номер последней загруженной страницы (0 — ничего не загружено).
  final int page;
  final bool hasReachedMax;
  final bool isLoadingMore;

  /// Ошибка загрузки первой страницы.
  final AppFailure? failure;

  /// Ошибка подгрузки следующей страницы — список при этом остаётся на экране.
  final AppFailure? loadMoreFailure;

  bool get isEmpty => status == CharactersStatus.success && characters.isEmpty;

  CharactersState copyWith({
    CharactersStatus? status,
    List<Character>? characters,
    String? query,
    int? page,
    bool? hasReachedMax,
    bool? isLoadingMore,
    AppFailure? Function()? failure,
    AppFailure? Function()? loadMoreFailure,
  }) => CharactersState(
    status: status ?? this.status,
    characters: characters ?? this.characters,
    query: query ?? this.query,
    page: page ?? this.page,
    hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    failure: failure != null ? failure() : this.failure,
    loadMoreFailure: loadMoreFailure != null
        ? loadMoreFailure()
        : this.loadMoreFailure,
  );

  @override
  List<Object?> get props => [
    status,
    characters,
    query,
    page,
    hasReachedMax,
    isLoadingMore,
    failure,
    loadMoreFailure,
  ];
}
