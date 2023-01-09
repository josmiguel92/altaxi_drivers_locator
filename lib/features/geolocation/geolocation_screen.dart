import 'package:flutter/material.dart';
import 'package:flutter_advanced_boilerplate/utils/methods/shortcuts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_advanced_boilerplate/features/app/models/alert_model.dart';
import 'package:flutter_advanced_boilerplate/features/geolocation/widgets/grid_item.dart';
// import 'package:flutter_advanced_boilerplate/features/geolocation/widgets/link_card.dart';
import 'package:flutter_advanced_boilerplate/features/geolocation/widgets/text_divider.dart';
import 'package:flutter_advanced_boilerplate/i18n/strings.g.dart';
import 'package:flutter_advanced_boilerplate/utils/helpers/bar_helper.dart';
import 'package:flutter_advanced_boilerplate/utils/helpers/permission_helper.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flutter_advanced_boilerplate/features/app/widgets/customs/custom_button.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:workmanager/workmanager.dart';

const fetchBackground = "fetchBackground";
const simpleTaskKey = "altaxi.workmanagerExample.simpleTask";

class GeolocationScreen extends StatefulWidget {
  const GeolocationScreen({super.key});

  @override
  State<GeolocationScreen> createState() => _GeolocationScreenState();
}

class _GeolocationScreenState extends State<GeolocationScreen> {
  late RoundedLoadingButtonController _btnController;
  late Workmanager _workmanager;

  @override
  void initState() {
    _btnController = RoundedLoadingButtonController();
    super.initState();
  }

  Future<void> getLocation() async {
    Workmanager().registerPeriodicTask(
      simpleTaskKey,
      simpleTaskKey,
      initialDelay: Duration(seconds: 10),
    );

    print('GetLocation methiod');
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    print({'locationServiceEnabled': serviceEnabled});
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      BarHelper.showAlert(
        context,
        alert: AlertModel(
          message: context.t.geolocation.service_disabled,
          type: AlertType.destructive,
        ),
      );
    } else {
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Permissions are denied, next time you could try
          // requesting permissions again (this is also where
          // Android's shouldShowRequestPermissionRationale
          // returned true. According to Android guidelines
          // your App should show an explanatory UI now.
          BarHelper.showAlert(
            context,
            alert: AlertModel(
              message: context.t.geolocation.service_denied,
              type: AlertType.destructive,
            ),
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Permissions are denied forever, handle appropriately.
        BarHelper.showAlert(
          context,
          alert: AlertModel(
            message: context.t.geolocation.service_denied_forever,
            type: AlertType.destructive,
          ),
        );
      }

      // When we reach here, permissions are granted and we can
      // continue accessing the position of the device.
      // return await Geolocator.getCurrentPosition();

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      print(Geolocator.getLocationAccuracy());
      print(position);
      final pb = PocketBase('https://base.altaxi.app');
      // authenticate as regular user
      final userData = await pb
          .collection('drivers')
          .authWithPassword('test@altaxi.app', '12345678');
      print(userData);
      final newRecord = await pb.collection('drivers_location').create(
        body: {
          'driver': userData.record?.id,
          'geolocation': position.toJson(),
        },
      );
      print(newRecord);
    }
  }

  Future<void> checkPermission() async {
    final hasPermission = true; // await checkLocationPermission();

    if (hasPermission) {
      getLocation();
    } else {
      BarHelper.showAlert(
        context,
        alert: AlertModel(
          message: context.t.core.location.no_permission,
          type: AlertType.destructive,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.background,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const BouncingScrollPhysics(),
        children: [
          // LinkCard(
          //   title: context.t.informations.github_repository_title,
          //   icon: MdiIcons.github,
          //   url: Uri.parse(
          //     'https://github.com/fikretsengul/flutter_advanced_boilerplate',
          //   ),
          // ),
          TextDivider(text: context.t.geolocation.status_divider_title),
          GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 2 / 1.15,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            children: [
              CustomButton(
                controller: _btnController,
                text: context.t.geolocation.enable_geolocation,
                width: getSize(context).width / 2,
                onPressed: getLocation,
              ),

              GridItem(
                title: context.t.informations.donate_card_title,
                icon: MdiIcons.coffee,
                url: Uri.parse(
                  'https://www.buymeacoffee.com/iamfikretB',
                ),
              ),
              // GridItem(
              //   title: context.t.informations.donate_card_title,
              //   icon: MdiIcons.coffee,
              //   url: Uri.parse(
              //     'https://www.buymeacoffee.com/iamfikretB',
              //   ),
              // ),
              // GridItem(
              //   title: context.t.informations.website_card_title,
              //   icon: MdiIcons.web,
              //   url: Uri.parse('https://fikretsengul.com'),
              // ),
            ],
          ),
          const SizedBox(height: 36),
        ],
      ),
    );
  }
}
