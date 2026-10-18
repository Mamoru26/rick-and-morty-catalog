import 'package:dio/dio.dart';

const rickAndMortyBaseUrl = 'https://rickandmortyapi.com/api';

Dio createDio() => Dio(
  BaseOptions(
    baseUrl: rickAndMortyBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
    responseType: ResponseType.json,
  ),
);
