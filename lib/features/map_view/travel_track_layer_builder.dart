import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:photo_manager/photo_manager.dart';
import 'package:travel_tracker/features/map_view/marker_ext.dart';
import 'package:travel_tracker/features/gpx/gpx_model.dart';
import 'package:gpx/gpx.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:travel_tracker/features/travel_track/gpx_ext.dart';
import 'package:travel_tracker/features/travel_track/travel_track.dart';
import 'package:travel_tracker/features/travel_track/trk_asset.dart';
import 'package:travel_tracker/features/travel_track/trkseg_ext.dart';

class TravelTrackLayerBuilder {
  final ValueNotifier<double> _mapRotationNotifier;

  TravelTrackLayerBuilder(this._mapRotationNotifier);

  List<Widget> build(TravelTrack travelTrack) {
    List<Widget> layers = <Widget>[];
    for (GpxExt gpxExt in travelTrack.gpxExts) {
      layers.addAll(_genTrksegLayersByGpxExt(gpxExt));
    }
    layers.add(_genAssetLayerByTrkAssets(travelTrack.trkAssets));
    return layers;
  }

  // void t() {
  //   List<MarkerExt<ExtendedAsset>> markers = <MarkerExt<ExtendedAsset>>[];
  //   for (ExtendedAsset asset in trksegWithAssets.extendedAssets) {
  //     markers.add(
  //       MarkerExt<ExtendedAsset>(
  //         width: 70,
  //         height: 70,
  //         point: asset.latLng,
  //         rotate: false,
  //         extra: asset,
  //         builder: (BuildContext context) {
  //           return Transform.rotate(
  //             angle: -mapRotation * math.pi / 180,
  //             child: IconButton(
  //               // icon: const Icon(Icons.location_on),
  //               icon: AspectRatio(
  //                 aspectRatio: 1 / 1,
  //                 child: Container(
  //                   decoration: BoxDecoration(
  //                     borderRadius: BorderRadius.circular(10),
  //                     border: Border.all(
  //                       color: Colors.white,
  //                       width: 2,
  //                     ),
  //                     image: DecorationImage(
  //                       image: AssetEntityImageProvider(
  //                         asset.asset,
  //                         isOriginal: false,
  //                       ),
  //                       fit: BoxFit.cover,
  //                     ),
  //                   ),
  //                   child: Container(
  //                     decoration: BoxDecoration(
  //                       borderRadius: BorderRadius.circular(10),
  //                       color: Colors.black.withOpacity(0),
  //                     ),
  //                     // TODO: decide if we want to show the asset title
  //                     // child: Padding(
  //                     //   padding: const EdgeInsets.all(4.0),
  //                     //   child: Center(
  //                     //     child: Text(
  //                     //       asset.asset.title ?? '',
  //                     //       style: const TextStyle(
  //                     //         color: Colors.white,
  //                     //         fontSize: 12,
  //                     //       ),
  //                     //     ),
  //                     //   ),
  //                     // ),
  //                   ),
  //                 ),
  //               ),
  //               padding: const EdgeInsets.all(0),
  //               color: Colors.red,
  //               onPressed: () {
  //                 debugPrint('onPressed ${asset.asset.title}');
  //                 // context.read<GpxModel>().setSelectedCustomAsset(asset);
  //                 // Navigator.pushNamed(context, '/asset');
  //               },
  //             ),
  //           );
  //         },
  //       ),
  //     );
  //   }

  //   MarkerClusterLayerWidget markerClusterLayerWidget =
  //       MarkerClusterLayerWidget(
  //     options: MarkerClusterLayerOptions(
  //       maxClusterRadius: 45,
  //       size: const Size(50, 50),
  //       anchor: AnchorPos.align(AnchorAlign.center),
  //       fitBoundsOptions: const FitBoundsOptions(
  //         padding: EdgeInsets.all(50),
  //         maxZoom: 15,
  //       ),
  //       markers: markers,
  //       builder: (context, markers) {
  //         // cast markers to extraMarkers
  //         List<MarkerExt<ExtendedAsset>> extraMarkers = markers
  //             .map((marker) => marker as MarkerExt<ExtendedAsset>)
  //             .toList();
  //         ExtendedAsset? asset;
  //         for (MarkerExt<ExtendedAsset> extraMarker in extraMarkers) {
  //           if (extraMarker.extra != null) {
  //             asset = extraMarker.extra;
  //             break;
  //           }
  //         }
  //         return Transform.rotate(
  //           angle: -mapRotation * math.pi / 180,
  //           child: IconButton(
  //             icon: AspectRatio(
  //               aspectRatio: 1 / 1,
  //               child: Container(
  //                 decoration: BoxDecoration(
  //                   borderRadius: BorderRadius.circular(10),
  //                   border: Border.all(
  //                     color: Colors.white,
  //                     width: 2,
  //                   ),
  //                   image: asset == null
  //                       ? null
  //                       : DecorationImage(
  //                           image: AssetEntityImageProvider(
  //                             asset.asset,
  //                             isOriginal: false,
  //                           ),
  //                           fit: BoxFit.cover,
  //                         ),
  //                 ),
  //                 child: Stack(
  //                   children: <Widget>[
  //                     asset == null
  //                         ? Icon(
  //                             Icons.photo,
  //                             color: Colors.white,
  //                           )
  //                         : Container(),
  //                     Container(
  //                       decoration: BoxDecoration(
  //                         borderRadius: BorderRadius.circular(10),
  //                         color: Colors.black.withOpacity(0.3),
  //                       ),
  //                     ),
  //                     Center(
  //                         child: Text(
  //                       markers.length.toString(),
  //                       style: const TextStyle(
  //                         color: Colors.white,
  //                         fontSize: 18,
  //                       ),
  //                     )),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //             padding: const EdgeInsets.all(0),
  //             onPressed: () {
  //               debugPrint('onPressed ${markers.length}');
  //               // context.read<GpxModel>().setSelectedCustomAsset(asset);
  //               // Navigator.pushNamed(context, '/asset');
  //             },
  //           ),
  //         );
  //         // Container(
  //         //   decoration: BoxDecoration(
  //         //       borderRadius: BorderRadius.circular(20), color: Colors.blue),
  //         //   child: Center(
  //         //     child: Text(
  //         //       markers.length.toString(),
  //         //       style: const TextStyle(color: Colors.white),
  //         //     ),
  //         //   ),
  //         // );
  //       },
  //     ),
  //   );
  // }

  List<Widget> _genTrksegLayersByGpxExt(GpxExt gpxExt) {
    List<Widget> layers = <Widget>[];
    for (TrksegExt trksegExt in gpxExt.trksegExts) {
      layers.add(_genTrksegLayerByTrksegExt(trksegExt));
    }
    return layers;
  }

  PolylineLayer _genTrksegLayerByTrksegExt(TrksegExt trksegExt) {
    List<latlng.LatLng> points = <latlng.LatLng>[];
    for (Wpt trkpt in trksegExt.trkseg.trkpts) {
      if (trkpt.lat != null && trkpt.lon != null) {
        points.add(latlng.LatLng(trkpt.lat!, trkpt.lon!));
      }
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
    return polylineLayer;
  }

  MarkerClusterLayerWidget _genAssetLayerByTrkAssets(List<TrkAsset> trkAssets) {
    List<MarkerExt<TrkAsset>> markerExts = <MarkerExt<TrkAsset>>[];
    for (TrkAsset trkAsset in trkAssets) {
      MarkerExt<TrkAsset>? markerExt = _genAssetMarkerByTrkAsset(trkAsset);
      if (markerExt != null) {
        markerExts.add(markerExt);
      }
    }
    return _genMarkerClusterLayerWidgetByMarkers(markerExts);
  }

  MarkerExt<TrkAsset>? _genAssetMarkerByTrkAsset(TrkAsset trkAsset) {
    if (trkAsset.latLng == null) {
      return null;
    }

    double mapRotation = _mapRotationNotifier.value;
    return MarkerExt<TrkAsset>(
      width: 70,
      height: 70,
      point: trkAsset.latLng!,
      rotate: false,
      extra: trkAsset,
      builder: (BuildContext context) {
        return Transform.rotate(
          angle: -mapRotation * math.pi / 180,
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
                  image: DecorationImage(
                    image: AssetEntityImageProvider(
                      trkAsset.asset,
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
              debugPrint('onPressed ${trkAsset.asset.title}');
              // TODO: show asset
              // context.read<GpxModel>().setSelectedCustomAsset(asset);
              // Navigator.pushNamed(context, '/asset');
            },
          ),
        );
      },
    );
  }

  MarkerClusterLayerWidget _genMarkerClusterLayerWidgetByMarkers(
      List<MarkerExt> markerExts) {
    double mapRotation = _mapRotationNotifier.value;
    return MarkerClusterLayerWidget(
      options: MarkerClusterLayerOptions(
        maxClusterRadius: 45,
        size: const Size(50, 50),
        anchor: AnchorPos.align(AnchorAlign.center),
        fitBoundsOptions: const FitBoundsOptions(
          padding: EdgeInsets.all(50),
          maxZoom: 15,
        ),
        markers: markerExts,
        builder: (context, markers) {
          // cast markers to extraMarkers
          List<MarkerExt<TrkAsset>> extraMarkers =
              markers.map((marker) => marker as MarkerExt<TrkAsset>).toList();
          TrkAsset? asset;
          for (MarkerExt<TrkAsset> extraMarker in extraMarkers) {
            if (extraMarker.extra != null) {
              asset = extraMarker.extra;
              break;
            }
          }
          return Transform.rotate(
            angle: -mapRotation * math.pi / 180,
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
  }
}
