import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:altaxi_drivers_locator/features/app/models/env_model.dart';
import 'package:altaxi_drivers_locator/modules/dio/interceptors/api_error_interceptor.dart';
import 'package:altaxi_drivers_locator/modules/dio/interceptors/bad_network_error_interceptor.dart';
import 'package:altaxi_drivers_locator/modules/dio/interceptors/internal_server_error_interceptor.dart';
import 'package:altaxi_drivers_locator/modules/dio/interceptors/unathenticated_interceptor.dart';
import 'package:altaxi_drivers_locator/modules/token_refresh/dio_token_refresh.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:sentry_dio/sentry_dio.dart';
import 'package:universal_platform/universal_platform.dart';

Dio initDioClient(
  EnvModel env,
  DioTokenRefresh dioTokenRefresh,
) {
  final dio = Dio();

  if (UniversalPlatform.isAndroid || UniversalPlatform.isIOS) {
    /// Allows https requests for older devices.
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;

      return client;
    };
  }

  dio.options.baseUrl = env.restApiUrl;
  dio.options.headers['Accept-Language'] =
      UniversalPlatform.isWeb ? 'en-US' : Platform.localeName.substring(0, 2);
  dio.options.connectTimeout = const Duration(seconds: 10).inMilliseconds;
  dio.options.receiveTimeout = const Duration(seconds: 10).inMilliseconds;
  dio.interceptors.add(dioTokenRefresh.fresh);
  dio.interceptors.add(BadNetworkErrorInterceptor());
  dio.interceptors.add(InternalServerErrorInterceptor());
  dio.interceptors.add(ApiErrorInterceptor());
  dio.interceptors.add(UnauthenticatedInterceptor());

  // Sentrie's performance tracing, http breadcrumbs and
  // automatic recording of bad http requests for dio.
  dio.addSentry();

  if (env.debugApiClient) {
    dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
      ),
    );
  }

  return dio;
}
