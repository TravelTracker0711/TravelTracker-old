import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:provider/provider.dart';
import 'package:travel_tracker/features/map_view/map_view_controller.dart';
import 'package:travel_tracker/features/map_view/travel_track_layer_builder.dart';
import 'package:travel_tracker/models/travel_track/travel_track.dart';
import 'package:travel_tracker/features/travel_track/travel_track_manager.dart';
import 'package:url_launcher/url_launcher.dart';

class MapViewMap extends StatefulWidget {
  const MapViewMap({
    super.key,
  });

  @override
  State<MapViewMap> createState() => _MapViewMapState();
}

class _MapViewMapState extends State<MapViewMap> with TickerProviderStateMixin {
  late final AnimatedMapController animatedMapController;
  final ValueNotifier<double> mapRotationNotifier = ValueNotifier<double>(0.0);
  late final VoidCallback _followOnLocationUpdateListener;
  late MapViewController mapViewController;

  MapOptions _getMapOptions() {
    return MapOptions(
      center: latlng.LatLng(24, 121),
      zoom: 15,
      rotation: mapRotationNotifier.value,
      minZoom: 3,
      maxZoom: 18,
      onPositionChanged: (position, hasGesture) {
        setState(() {
          mapRotationNotifier.value = animatedMapController.rotation;
        });
      },
      interactiveFlags: InteractiveFlag.all & ~InteractiveFlag.rotate,
    );
  }

  List<Widget> _getBasicMapLayer(
      FollowOnLocationUpdate followOnLocationUpdate) {
    return <Widget>[
      TileLayer(
        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        // urlTemplate: 'https://chart.apis.google.com/chart?chst=d_text_outline&chs=256x256&chf=bg,s,00000044&chld=FFFFFF|32|h|000000|b|||x={x}|y={y}|z={z}||||______________',
        // urlTemplate: 'http://mt0.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
        userAgentPackageName: 'com.example.travel_tracker',
      ),
      CurrentLocationLayer(
        followOnLocationUpdate: followOnLocationUpdate,
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    mapViewController = context.read<MapViewController>();
    animatedMapController = AnimatedMapController(
      vsync: this,
      curve: Curves.linear,
      duration: const Duration(milliseconds: 500),
    );
    mapViewController.animateMapController = animatedMapController;
    animatedMapController.mapEventStream.listen((MapEvent mapEvent) {
      if (mapEvent is MapEventMoveStart &&
          mapViewController.followOnLocationUpdateNotifier.value ==
              FollowOnLocationUpdate.always) {
        setState(() {
          mapViewController.stopFollowingUser();
        });
      }
    });
    _followOnLocationUpdateListener = () => setState(() {});
    mapViewController.followOnLocationUpdateNotifier
        .addListener(_followOnLocationUpdateListener);
  }

  @override
  Widget build(BuildContext context) {
    mapViewController = context.watch<MapViewController>();

    List<Widget> layers = [];
    TravelTrack? activeTravelTrack =
        context.watch<TravelTrackManager>().activeTravelTrack;
    TravelTrackLayerBuilder travelTrackLayerBuilder = TravelTrackLayerBuilder(
      mapRotationNotifier: mapRotationNotifier,
      mapViewController: mapViewController,
    );
    layers.addAll(_getBasicMapLayer(
        mapViewController.followOnLocationUpdateNotifier.value));
    if (activeTravelTrack != null) {
      layers.addAll(travelTrackLayerBuilder.build([activeTravelTrack]));
    }

    return FlutterMap(
      mapController: animatedMapController,
      options: _getMapOptions(),
      // ignore: sort_child_properties_last
      children: layers,
      // nonRotatedChildren: <Widget>[
      //   RichAttributionWidget(
      //     attributions: [
      //       TextSourceAttribution(
      //         'OpenStreetMap contributors',
      //         onTap: () => launchUrl(
      //           Uri.parse('https://openstreetmap.org/copyright'),
      //           mode: LaunchMode.externalApplication,
      //         ),
      //       ),
      //     ],
      //   ),
      // ],
    );
  }

  @override
  void dispose() {
    mapViewController.followOnLocationUpdateNotifier
        .removeListener(_followOnLocationUpdateListener);
    animatedMapController.dispose();
    super.dispose();
  }
}
