import 'dart:math' as math;
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
import 'package:travel_tracker/features/map_view/extra_marker.dart';
import 'package:travel_tracker/features/gpx/gpx_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gpx/gpx.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';

class MapViewPage extends StatefulWidget {
  const MapViewPage({super.key});

  @override
  State<MapViewPage> createState() => _MapViewPageState();
}

// TODO refactor
class _MapViewPageState extends State<MapViewPage> {
  FlutterMap? _map;
  MapController? _mapController;
  double _mapRotation = 0.0;

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

  List<Widget> genTrksegLayers(TrksegWithAssets trksegWithAssets) {
    List<latlng.LatLng> points = <latlng.LatLng>[];
    for (Wpt trkpt in trksegWithAssets.trkseg.trkpts) {
      if (trkpt.lat != null && trkpt.lon != null) {
        points.add(latlng.LatLng(trkpt.lat!, trkpt.lon!));
      }
    }

    List<ExtraMarker<ExtendedAsset>> markers = <ExtraMarker<ExtendedAsset>>[];
    for (ExtendedAsset asset in trksegWithAssets.extendedAssets) {
      markers.add(
        ExtraMarker<ExtendedAsset>(
          width: 70,
          height: 70,
          point: asset.latLng,
          rotate: false,
          extra: asset,
          builder: (BuildContext context) {
            return Transform.rotate(
              angle: -_mapRotation * math.pi / 180,
              child: IconButton(
                // icon: const Icon(Icons.location_on),
                icon: AspectRatio(
                  aspectRatio: 1 / 1,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                      image: DecorationImage(
                        image: AssetEntityImageProvider(
                          asset.asset,
                          isOriginal: false,
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.black.withOpacity(0),
                      ),
                      // TODO: decide if we want to show the asset title
                      // child: Padding(
                      //   padding: const EdgeInsets.all(4.0),
                      //   child: Center(
                      //     child: Text(
                      //       asset.asset.title ?? '',
                      //       style: const TextStyle(
                      //         color: Colors.white,
                      //         fontSize: 12,
                      //       ),
                      //     ),
                      //   ),
                      // ),
                    ),
                  ),
                ),
                padding: const EdgeInsets.all(0),
                color: Colors.red,
                onPressed: () {
                  debugPrint('onPressed ${asset.asset.title}');
                  // context.read<GpxModel>().setSelectedCustomAsset(asset);
                  // Navigator.pushNamed(context, '/asset');
                },
              ),
            );
          },
        ),
      );
    }

    PolylineLayer polylineLayer = PolylineLayer(
      polylines: <Polyline>[
        Polyline(
          points: points,
          strokeWidth: 4.0,
          color: Colors.deepOrange,
        ),
      ],
    );

    MarkerLayer markerLayer = MarkerLayer(
      markers: markers,
    );
    MarkerClusterLayerWidget markerClusterLayerWidget =
        MarkerClusterLayerWidget(
      options: MarkerClusterLayerOptions(
        maxClusterRadius: 45,
        size: const Size(50, 50),
        anchor: AnchorPos.align(AnchorAlign.center),
        fitBoundsOptions: const FitBoundsOptions(
          padding: EdgeInsets.all(50),
          maxZoom: 15,
        ),
        markers: markers,
        builder: (context, markers) {
          // cast markers to extraMarkers
          List<ExtraMarker<ExtendedAsset>> extraMarkers = markers
              .map((marker) => marker as ExtraMarker<ExtendedAsset>)
              .toList();
          ExtendedAsset? asset;
          for (ExtraMarker<ExtendedAsset> extraMarker in extraMarkers) {
            if (extraMarker.extra != null) {
              asset = extraMarker.extra;
              break;
            }
          }
          return Transform.rotate(
            angle: -_mapRotation * math.pi / 180,
            child: IconButton(
              icon: AspectRatio(
                aspectRatio: 1 / 1,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                    image: asset == null
                        ? null
                        : DecorationImage(
                            image: AssetEntityImageProvider(
                              asset.asset,
                              isOriginal: false,
                            ),
                            fit: BoxFit.cover,
                          ),
                  ),
                  child: Stack(
                    children: <Widget>[
                      asset == null
                          ? Icon(
                              Icons.photo,
                              color: Colors.white,
                            )
                          : Container(),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.black.withOpacity(0.3),
                        ),
                      ),
                      Center(
                          child: Text(
                        markers.length.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      )),
                    ],
                  ),
                ),
              ),
              padding: const EdgeInsets.all(0),
              onPressed: () {
                debugPrint('onPressed ${markers.length}');
                // context.read<GpxModel>().setSelectedCustomAsset(asset);
                // Navigator.pushNamed(context, '/asset');
              },
            ),
          );
          // Container(
          //   decoration: BoxDecoration(
          //       borderRadius: BorderRadius.circular(20), color: Colors.blue),
          //   child: Center(
          //     child: Text(
          //       markers.length.toString(),
          //       style: const TextStyle(color: Colors.white),
          //     ),
          //   ),
          // );
        },
      ),
    );

    return List<Widget>.from([polylineLayer, markerClusterLayerWidget]);
  }

  @override
  Widget build(BuildContext context) {
    _mapController = MapController();
    List<Widget> layers = <Widget>[
      TileLayer(
        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        // urlTemplate: 'https://chart.apis.google.com/chart?chst=d_text_outline&chs=256x256&chf=bg,s,00000044&chld=FFFFFF|32|h|000000|b|||x={x}|y={y}|z={z}||||______________',
        // urlTemplate: 'http://mt0.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
        // this server is down
        // urlTemplate: 'http://rudy.tile.basecamp.tw/{z}/{x}/{y}.png',
        userAgentPackageName: 'com.example.travel_tracker',
      ),
      CurrentLocationLayer(),
    ];

    List<TrksegWithAssets> trksegWithAssetsList =
    // context.watch<GpxModel>().trksegsWithAssets;
    for (TrksegWithAssets trksegWithAssets in trksegWithAssetsList) {
      layers.addAll(
        genTrksegLayers(trksegWithAssets),
      );
    }

    _map = FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        center: latlng.LatLng(24, 121),
        zoom: 8.2,
        rotation: _mapRotation,
        onPositionChanged: (position, hasGesture) {
          setState(() {
            _mapRotation = _mapController!.rotation;
          });
        },
        interactiveFlags: InteractiveFlag.all & ~InteractiveFlag.rotate,
      ),
      // children, nonRotatedChildren must be in order
      // or onTap will be triggered even if attribution isn't open
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

    return _map!;
  }
}
