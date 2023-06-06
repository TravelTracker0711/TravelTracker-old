import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:provider/provider.dart';
import 'package:travel_tracker/features/map_view/travel_track_layer_builder.dart';
import 'package:travel_tracker/features/travel_track/travel_track.dart';
import 'package:travel_tracker/features/travel_track/travel_track_manager.dart';
import 'package:url_launcher/url_launcher.dart';

class MapViewPage extends StatefulWidget {
  const MapViewPage({super.key});
  @override
  State<MapViewPage> createState() => _MapViewPageState();
}

// TODO refactor
class _MapViewPageState extends State<MapViewPage> {
  final MapController mapController = MapController();
  final ValueNotifier<double> mapRotationNotifier = ValueNotifier<double>(0.0);

  // void addGpxLayer(Gpx gpx) {
  //   List<latlng.LatLng> points = <latlng.LatLng>[];
  //   for (Trk trk in gpx.trks) {
  //     for (var trksegEntry in trk.trksegs.asMap().entries) {
  //       Trkseg trkseg = trksegEntry.value;
  //       int trksegIndex = trksegEntry.key;
  //       for (var trkptEntry in trkseg.trkpts.asMap().entries) {
  //         Wpt trkpt = trkptEntry.value;
  //         int trkptIndex = trkptEntry.key;
  //         if (trkpt.lat != null && trkpt.lon != null) {
  //           points.add(latlng.LatLng(trkpt.lat!, trkpt.lon!));
  //         }
  //       }
  //     }
  //   }

  //   PolylineLayer polylineLayer = PolylineLayer(
  //     polylines: <Polyline>[
  //       Polyline(
  //         points: points,
  //         strokeWidth: 4.0,
  //         color: Colors.deepOrange,
  //       ),
  //     ],
  //   );

  //   setState(() {
  //     _layers.add(polylineLayer);
  //   });
  // }

  MapOptions _getMapOptions() {
    return MapOptions(
      center: latlng.LatLng(24, 121),
      zoom: 8.2,
      rotation: mapRotationNotifier.value,
      minZoom: 3,
      maxZoom: 18,
      onPositionChanged: (position, hasGesture) {
        setState(() {
          mapRotationNotifier.value = mapController.rotation;
        });
      },
      interactiveFlags: InteractiveFlag.all & ~InteractiveFlag.rotate,
    );
  }

  List<Widget> _getBasicMapLayer() {
    return <Widget>[
      TileLayer(
        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        // urlTemplate: 'https://chart.apis.google.com/chart?chst=d_text_outline&chs=256x256&chf=bg,s,00000044&chld=FFFFFF|32|h|000000|b|||x={x}|y={y}|z={z}||||______________',
        // urlTemplate: 'http://mt0.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
        userAgentPackageName: 'com.example.travel_tracker',
      ),
      CurrentLocationLayer(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> layers = _getBasicMapLayer();
    Map<String, TravelTrack> travelTracks =
        context.watch<TravelTrackManager>().travelTracks;
    TravelTrackLayerBuilder travelTrackLayerBuilder =
        TravelTrackLayerBuilder(mapRotationNotifier);
    layers.addAll(travelTrackLayerBuilder.build(travelTracks.values.toList()));

    return FlutterMap(
      mapController: mapController,
      options: _getMapOptions(),
      // ignore: sort_child_properties_last
      children: layers,
      nonRotatedChildren: <Widget>[
        RichAttributionWidget(
          attributions: [
            TextSourceAttribution(
              'OpenStreetMap contributors',
              onTap: () => launchUrl(
                Uri.parse('https://openstreetmap.org/copyright'),
                mode: LaunchMode.externalApplication,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
