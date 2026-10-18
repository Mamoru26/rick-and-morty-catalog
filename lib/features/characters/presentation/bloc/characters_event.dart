part of 'characters_bloc.dart';

sealed class CharactersEvent extends Equatable {
  const CharactersEvent();

  @override
  List<Object?> get props => [];
}

/// Первая загрузка экрана.
final class CharactersStarted extends CharactersEvent {
  const CharactersStarted();
}

/// Пользователь изменил строку поиска (дебаунс — на стороне UI).
final class CharactersQueryChanged extends CharactersEvent {
  const CharactersQueryChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

/// Список докручен до конца или нажат повтор подгрузки.
final class CharactersNextPageRequested extends CharactersEvent {
  const CharactersNextPageRequested();
}

/// Повтор загрузки первой страницы после ошибки.
final class CharactersRetryRequested extends CharactersEvent {
  const CharactersRetryRequested();
}
