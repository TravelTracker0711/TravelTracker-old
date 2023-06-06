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

  List<Widget> build(List<TravelTrack> travelTracks) {
    List<Widget> layers = <Widget>[];
    for (TravelTrack travelTrack in travelTracks) {
      layers.addAll(buildPolylineLayersByTravelTrack(travelTrack));
    }
    layers.add(buildMarkerClusterLayerByTravelTracks(travelTracks));
    return layers;
  }

  List<Widget> buildPolylineLayersByTravelTrack(TravelTrack travelTrack) {
    List<PolylineLayer> layers = <PolylineLayer>[];
    for (GpxExt gpxExt in travelTrack.gpxExts) {
      layers.addAll(buildPolylineLayersByGpxExt(gpxExt));
    }
    return layers;
  }

  List<PolylineLayer> buildPolylineLayersByGpxExt(GpxExt gpxExt) {
    List<PolylineLayer> layers = <PolylineLayer>[];
    for (TrksegExt trksegExt in gpxExt.trksegExts) {
      layers.add(buildPolylineLayerByTrksegExt(trksegExt));
    }
    return layers;
  }

  PolylineLayer buildPolylineLayerByTrksegExt(TrksegExt trksegExt) {
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

  MarkerClusterLayerWidget buildMarkerClusterLayerByTravelTracks(
      List<TravelTrack> travelTracks) {
    List<TrkAsset> trkAssets = <TrkAsset>[];
    for (TravelTrack travelTrack in travelTracks) {
      trkAssets.addAll(travelTrack.trkAssets);
    }
    MarkerClusterLayerWidget layer =
        buildMarkerClusterLayerByTrkAssets(trkAssets);
    return layer;
  }

  MarkerClusterLayerWidget buildMarkerClusterLayerByTrkAssets(
      List<TrkAsset> trkAssets) {
    List<MarkerExt<TrkAsset>> markerExts = <MarkerExt<TrkAsset>>[];
    for (TrkAsset trkAsset in trkAssets) {
      MarkerExt<TrkAsset>? markerExt = buildMarkerByTrkAsset(trkAsset);
      if (markerExt != null) {
        markerExts.add(markerExt);
      }
    }
    return buildMarkerClusterByMarkers(markerExts);
  }

  MarkerExt<TrkAsset>? buildMarkerByTrkAsset(TrkAsset trkAsset) {
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

  MarkerClusterLayerWidget buildMarkerClusterByMarkers(
      List<MarkerExt<TrkAsset>> markerExts) {
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
          TrkAsset? displayedAsset;
          for (MarkerExt<TrkAsset> extraMarker in extraMarkers) {
            if (extraMarker.extra != null) {
              displayedAsset = extraMarker.extra;
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
                    image: displayedAsset == null
                        ? null
                        : DecorationImage(
                            image: AssetEntityImageProvider(
                              displayedAsset.asset,
                              isOriginal: false,
                            ),
                            fit: BoxFit.cover,
                          ),
                  ),
                  child: Stack(
                    children: <Widget>[
                      displayedAsset == null
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
                // TODO: show asset cluster
                // context.read<GpxModel>().setSelectedCustomAsset(asset);
                // Navigator.pushNamed(context, '/asset');
              },
            ),
          );
        },
      ),
    );
  }
}
