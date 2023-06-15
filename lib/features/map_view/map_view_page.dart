import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_tracker/features/map_view/map_view_controller.dart';
import 'package:travel_tracker/features/map_view/map_view_map.dart';

class MapViewPage extends StatefulWidget {
  const MapViewPage({
    super.key,
    required this.controller,
  });

  final MapViewController controller;

  @override
  State<MapViewPage> createState() => _MapViewPageState();
}

class _MapViewPageState extends State<MapViewPage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MapViewController>(
      create: (_) => widget.controller,
      child: MapViewMap(),
    );
  }
}
