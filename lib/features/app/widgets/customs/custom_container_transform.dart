import 'package:altaxi_drivers_locator/utils/constants.dart';
import 'package:altaxi_drivers_locator/utils/methods/shortcuts.dart';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

class CustomContainerTransform extends StatelessWidget {
  const CustomContainerTransform({
    super.key,
    required this.closedBuilder,
    this.openWidget,
    this.closedBorderRadius,
  });

  final Widget Function(BuildContext, void Function()) closedBuilder;
  final Widget? openWidget;
  final double? closedBorderRadius;

  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      transitionType: ContainerTransitionType.fadeThrough,
      closedElevation: $constants.theme.defaultElevation,
      openElevation: $constants.theme.defaultElevation,
      closedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(
            closedBorderRadius ?? $constants.theme.defaultBorderRadius,
          ),
        ),
      ),
      closedColor: getTheme(context).surface,
      openColor: getTheme(context).surface,
      middleColor: getTheme(context).surface,
      tappable: openWidget != null,
      openBuilder: (context, _) => openWidget ?? const SizedBox(),
      closedBuilder: closedBuilder,
    );
  }
}
