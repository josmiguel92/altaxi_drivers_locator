import 'package:geolocator/geolocator.dart';
import 'package:pocketbase/pocketbase.dart';

Future<bool> sendLocationToBase({String info = 'empty'}) async {
  print({'✅ SendLocationToBase called', info, DateTime.now().toString()});

  Position position = await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );

  final pb = PocketBase('https://base.altaxi.app');
  // authenticate as regular user
  final userData = await pb
      .collection('drivers')
      .authWithPassword('test@altaxi.app', '12345678');

  print({'👤 User', userData.record?.id});

  try {
    final newRecord = await pb.collection('drivers_location').create(
      body: {
        'driver': userData.record?.id,
        'geolocation': position.toJson(),
        'info': info,
      },
    );
    print({'📌 Record added to DB', newRecord.updated, info});

    return true;
  } catch (error) {
    print('Error: $error');

    return false;
  }
}
