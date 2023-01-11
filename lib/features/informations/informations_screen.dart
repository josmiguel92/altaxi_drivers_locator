import 'package:altaxi_drivers_locator/features/features/widgets/components/info_card.dart';
import 'package:altaxi_drivers_locator/features/informations/widgets/grid_item.dart';
import 'package:altaxi_drivers_locator/features/informations/widgets/text_divider.dart';
import 'package:altaxi_drivers_locator/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class InformationsScreen extends StatelessWidget {
  const InformationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.background,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const BouncingScrollPhysics(),
        children: [
          InfoCard(
            title: context.t.features.routing.title,
            content: context.t.features.routing.explanation,
            icon: MdiIcons.mapMarker,
          ),
          InfoCard(
            title: context.t.features.testing.title,
            content: context.t.features.testing.explanation,
            icon: MdiIcons.clockAlert,
          ),
          TextDivider(text: context.t.informations.author_divider_title),
          GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 2 / 1.15,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            children: [
              GridItem(
                title: context.t.informations.website_card_title,
                icon: MdiIcons.taxi,
                url: Uri.parse(
                  'https://taxidriverscuba.com?referer=altaxi_drivers_recorder',
                ),
              ),
              GridItem(
                title: context.t.informations.dashboard_card_title,
                icon: MdiIcons.web,
                url: Uri.parse('https://dash.taxidrivercuba.com'),
              ),
            ],
          ),
          const SizedBox(height: 36),
        ],
      ),
    );
  }
}
