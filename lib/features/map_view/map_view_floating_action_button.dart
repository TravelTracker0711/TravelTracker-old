import 'package:flutter/material.dart';
import 'package:travel_tracker/features/map_view/map_view_controller.dart';

class MapViewFloatingActionButton extends StatelessWidget {
  const MapViewFloatingActionButton({
    Key? key,
    required this.controller,
  }) : super(key: key);

  final MapViewController controller;

  @override
  Widget build(BuildContext context) {
    // TODO: implement controller logic
    return FloatingActionButton(
      onPressed: () {
        // controller.followUser();
      },
      child: const Icon(Icons.gps_not_fixed),
      // child: controller.isFollowingUser
      //     ? const Icon(Icons.gps_fixed)
      //     : const Icon(Icons.gps_not_fixed),
    );
  }
}
