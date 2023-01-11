import 'package:altaxi_drivers_locator/utils/router.gr.dart';
import 'package:injectable/injectable.dart';

@module
abstract class RouterInjection {
  AppRouter router() => AppRouter();
}
