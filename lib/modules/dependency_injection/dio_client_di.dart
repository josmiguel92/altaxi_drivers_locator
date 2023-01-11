import 'package:dio/dio.dart';
import 'package:altaxi_drivers_locator/features/app/models/env_model.dart';
import 'package:altaxi_drivers_locator/modules/dio/dio_client.dart';
import 'package:altaxi_drivers_locator/modules/token_refresh/dio_token_refresh.dart';
import 'package:injectable/injectable.dart';

@module
abstract class DioInjection {
  Dio dio(EnvModel env, DioTokenRefresh dioTokenRefresh) =>
      initDioClient(env, dioTokenRefresh);
}
