import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/app_failure.dart';
import '../../domain/entities/character.dart';
import '../../domain/repositories/characters_repository.dart';

part 'characters_event.dart';
part 'characters_state.dart';

class CharactersBloc extends Bloc<CharactersEvent, CharactersState> {
  CharactersBloc(this._repository) : super(const CharactersState()) {
    on<CharactersStarted>(
      (_, emit) => _loadFirstPage(emit, state.query),
      transformer: droppable(),
    );
    on<CharactersRetryRequested>(
      (_, emit) => _loadFirstPage(emit, state.query),
      transformer: droppable(),
    );
    // restartable: новый запрос отменяет обработку предыдущего,
    // поэтому устаревший ответ поиска не перезапишет свежий.
    on<CharactersQueryChanged>(_onQueryChanged, transformer: restartable());
    // droppable: повторные события прокрутки во время подгрузки игнорируются.
    on<CharactersNextPageRequested>(_onNextPage, transformer: droppable());
  }

  final CharactersRepository _repository;

  Future<void> _onQueryChanged(
    CharactersQueryChanged event,
    Emitter<CharactersState> emit,
  ) async {
    final query = event.query.trim();
    if (query == state.query && state.status == CharactersStatus.success) {
      return;
    }
    await _loadFirstPage(emit, query);
  }

  Future<void> _loadFirstPage(
    Emitter<CharactersState> emit,
    String query,
  ) async {
    emit(CharactersState(status: CharactersStatus.loading, query: query));
    try {
      final result = await _repository.getCharacters(page: 1, query: query);
      if (emit.isDone || query != state.query) return;
      emit(
        CharactersState(
          status: CharactersStatus.success,
          characters: result.characters,
          query: query,
          page: 1,
          hasReachedMax: !result.hasNextPage,
        ),
      );
    } on AppFailure catch (failure) {
      if (emit.isDone || query != state.query) return;
      emit(
        CharactersState(
          status: CharactersStatus.failure,
          query: query,
          failure: failure,
        ),
      );
    }
  }

  Future<void> _onNextPage(
    CharactersNextPageRequested event,
    Emitter<CharactersState> emit,
  ) async {
    if (state.status != CharactersStatus.success ||
        state.hasReachedMax ||
        state.isLoadingMore) {
      return;
    }
    final query = state.query;
    final nextPage = state.page + 1;
    emit(state.copyWith(isLoadingMore: true, loadMoreFailure: () => null));
    try {
      final result = await _repository.getCharacters(
        page: nextPage,
        query: query,
      );
      // Пока шла подгрузка, пользователь мог начать новый поиск.
      if (!_isSameList(query)) return;
      emit(
        state.copyWith(
          characters: [...state.characters, ...result.characters],
          page: nextPage,
          hasReachedMax: !result.hasNextPage,
          isLoadingMore: false,
        ),
      );
    } on AppFailure catch (failure) {
      if (!_isSameList(query)) return;
      emit(
        state.copyWith(isLoadingMore: false, loadMoreFailure: () => failure),
      );
    }
  }

  bool _isSameList(String query) =>
      state.status == CharactersStatus.success && state.query == query;
}
