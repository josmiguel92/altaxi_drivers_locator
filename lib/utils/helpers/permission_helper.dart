import 'package:permission_handler/permission_handler.dart';
import 'package:universal_platform/universal_platform.dart';

Future<bool> checkPhotosPermission() async {
  if (UniversalPlatform.isAndroid || UniversalPlatform.isIOS) {
    await Permission.photos.request();

    if (await Permission.photos.isLimited ||
        await Permission.photos.isGranted) {
      return true;
    } else if (await Permission.photos.isPermanentlyDenied) {
      await openAppSettings();
    }

    return false;
  }

  return false;
}

Future<bool> checkLocationPermission() async {
  if (UniversalPlatform.isAndroid || UniversalPlatform.isIOS) {
    await Permission.locationAlways.request();

    if (await Permission.locationAlways.isLimited ||
        await Permission.locationAlways.isGranted) {
      return true;
    } else if (await Permission.locationAlways.isPermanentlyDenied) {
      await openAppSettings();
    }

    return false;
  }

  return false;
}
