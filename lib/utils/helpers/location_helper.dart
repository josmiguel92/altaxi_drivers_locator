import 'package:geolocator/geolocator.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<bool> sendLocationToBase({String info = 'empty'}) async {
  print({'✅ SendLocationToBase called', info, DateTime.now().toString()});

  final position = await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );

  final pb = PocketBase('https://base.altaxi.app');
  
  try {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('auth_userId');
    final username = prefs.getString('auth_username') ?? '';
    final password = prefs.getString('auth_password') ?? '';

    // Authenticate as regular user.
    final userData =
        await pb.collection('drivers').authWithPassword(username, password);
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
