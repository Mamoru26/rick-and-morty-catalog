import 'package:equatable/equatable.dart';

enum FailureType { network, server, unknown }

/// Ошибка, которую слой данных отдаёт наверх вместо исключений Dio.
class AppFailure extends Equatable implements Exception {
  const AppFailure(this.type);

  final FailureType type;

  String get message => switch (type) {
    FailureType.network =>
      'Нет соединения с сервером. Проверьте интернет и попробуйте снова.',
    FailureType.server => 'Сервер временно недоступен. Попробуйте позже.',
    FailureType.unknown => 'Что-то пошло не так. Попробуйте ещё раз.',
  };

  @override
  List<Object?> get props => [type];
}
