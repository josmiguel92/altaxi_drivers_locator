import 'package:altaxi_drivers_locator/features/app/models/env_model.dart';
import 'package:altaxi_drivers_locator/modules/dependency_injection/di.dart';
import 'package:altaxi_drivers_locator/utils/helpers/logging_helper.dart';
import 'package:altaxi_drivers_locator/utils/router.gr.dart';

final LoggingHelper logIt = getIt<LoggingHelper>();
final EnvModel env = getIt<EnvModel>();
final AppRouter appRouter = getIt<AppRouter>();
