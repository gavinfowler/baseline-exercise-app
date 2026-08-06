import 'package:flutter/material.dart';

/// Whether ad placements are active.
///
/// There is deliberately **no ad SDK dependency** in this project. Adding one
/// would pull network and tracking code into an app whose whole premise is that
/// it works offline and keeps data on the device. What is reserved instead is
/// the layout space and a single integration point, so a banner can be dropped
/// in later without reworking any screen.
abstract final class AdsConfig {
  static const bool enabled = bool.fromEnvironment('ADS_ENABLED');

  /// Standard mobile banner height, reserved so enabling ads later does not
  /// shift or clip any existing layout.
  static const double bannerHeight = 50;
}

/// Renders nothing while ads are disabled, which is the shipped default.
///
/// Placed at the bottom of the main scaffolds. When the time comes, the banner
/// widget goes inside the `SizedBox` below and nothing else has to change.
class AdSlot extends StatelessWidget {
  const AdSlot({super.key});

  @override
  Widget build(BuildContext context) {
    if (!AdsConfig.enabled) return const SizedBox.shrink();

    return SizedBox(
      height: AdsConfig.bannerHeight,
      child: ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Center(
          child: Text('Ad slot', style: Theme.of(context).textTheme.labelSmall),
        ),
      ),
    );
  }
}
