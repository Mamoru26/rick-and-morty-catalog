import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../features/characters/data/datasources/characters_remote_data_source.dart';
import '../../features/characters/data/repositories/characters_repository_impl.dart';
import '../../features/characters/domain/repositories/characters_repository.dart';
import '../../features/characters/presentation/bloc/characters_bloc.dart';
import '../network/api_client.dart';

final getIt = GetIt.instance;

void configureDependencies() {
  getIt
    ..registerLazySingleton<Dio>(createDio)
    ..registerLazySingleton(() => CharactersRemoteDataSource(getIt()))
    ..registerLazySingleton<CharactersRepository>(
      () => CharactersRepositoryImpl(getIt()),
    )
    ..registerFactory(() => CharactersBloc(getIt()));
}
