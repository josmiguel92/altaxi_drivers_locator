import 'package:dio/dio.dart';
import 'package:altaxi_drivers_locator/modules/dio/dio_exception_handler.dart';

class UnauthenticatedInterceptor extends Interceptor {
  @override
  Future<void> onError(DioError err, ErrorInterceptorHandler handler) async {
    if (err.response != null &&
        err.response!.statusCode != null &&
        err.response!.statusCode! == 401) {
      return handler.reject(
        UnauthenticatedException(requestOptions: err.requestOptions),
      );
    }

    return handler.next(err);
  }
}
