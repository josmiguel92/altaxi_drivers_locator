import 'package:flutter/material.dart';
import 'package:altaxi_drivers_locator/features/features/widgets/components/info_card.dart';
import 'package:altaxi_drivers_locator/features/informations/widgets/grid_item.dart';
import 'package:altaxi_drivers_locator/features/informations/widgets/text_divider.dart';
import 'package:altaxi_drivers_locator/utils/helpers/location_helper.dart';
import 'package:altaxi_drivers_locator/utils/methods/shortcuts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:altaxi_drivers_locator/features/app/models/alert_model.dart';
import 'package:altaxi_drivers_locator/i18n/strings.g.dart';
import 'package:altaxi_drivers_locator/utils/helpers/bar_helper.dart';
import 'package:altaxi_drivers_locator/utils/helpers/permission_helper.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:altaxi_drivers_locator/features/app/widgets/customs/custom_button.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class GeolocationScreen extends StatefulWidget {
  const GeolocationScreen({super.key});

  @override
  State<GeolocationScreen> createState() => _GeolocationScreenState();
}

class _GeolocationScreenState extends State<GeolocationScreen> {
  late RoundedLoadingButtonController _btnController;

  @override
  void initState() {
    _btnController = RoundedLoadingButtonController();
    super.initState();
  }

  Future<void> getLocation() async {
    print('GetLocation method');
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

      sendLocationToBase(info: 'manual');
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
          InfoCard(
            title: context.t.features.testing.title,
            content: context.t.features.testing.explanation,
            icon: MdiIcons.clockAlert,
          ),
          CustomButton(
            controller: _btnController,
            text: context.t.geolocation.enable_geolocation,
            width: getSize(context).width / 1.5,
            onPressed: getLocation,
          ),

          const SizedBox(height: 36),
        ],
      ),
    );
  }
}
