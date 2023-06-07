import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:photo_manager/photo_manager.dart';
import 'package:travel_tracker/features/map_view/marker_ext.dart';
import 'package:gpx/gpx.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:travel_tracker/features/travel_track/gpx_ext.dart';
import 'package:travel_tracker/features/travel_track/travel_track.dart';
import 'package:travel_tracker/features/travel_track/asset_ext.dart';
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

  List<PolylineLayer> buildPolylineLayersByTravelTrack(
      TravelTrack travelTrack) {
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
    List<AssetExt> assetExts = <AssetExt>[];
    for (TravelTrack travelTrack in travelTracks) {
      assetExts.addAll(travelTrack.assetExts);
    }
    MarkerClusterLayerWidget layer =
        buildMarkerClusterLayerByAssetExts(assetExts);
    return layer;
  }

  MarkerClusterLayerWidget buildMarkerClusterLayerByAssetExts(
      List<AssetExt> assetExts) {
    List<MarkerExt<AssetExt>> markerExts = <MarkerExt<AssetExt>>[];
    for (AssetExt assetExt in assetExts) {
      MarkerExt<AssetExt>? markerExt = buildMarkerByAssetExt(assetExt);
      if (markerExt != null) {
        markerExts.add(markerExt);
      }
    }
    return buildMarkerClusterByMarkers(markerExts);
  }

  MarkerExt<AssetExt>? buildMarkerByAssetExt(AssetExt assetExt) {
    if (assetExt.latLng == null) {
      return null;
    }
    double mapRotation = _mapRotationNotifier.value;
    return MarkerExt<AssetExt>(
      width: 70,
      height: 70,
      point: assetExt.latLng!,
      rotate: false,
      extra: assetExt,
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
                      assetExt.asset,
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
              debugPrint('onPressed ${assetExt.asset.title}');
              // TODO: show asset
              // Navigator.pushNamed(context, '/asset');
            },
          ),
        );
      },
    );
  }

  MarkerClusterLayerWidget buildMarkerClusterByMarkers(
      List<MarkerExt<AssetExt>> markerExts) {
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
        spiderfySpiralDistanceMultiplier: 2,
        disableClusteringAtZoom: 17,
        zoomToBoundsOnClick: false,
        markers: markerExts,
        builder: (context, markers) {
          List<MarkerExt<AssetExt>> extraMarkers =
              _castMarkerToMarkerExt(markers);
          AssetExt? displayedAsset;
          for (MarkerExt<AssetExt> extraMarker in extraMarkers) {
            if (extraMarker.extra != null) {
              displayedAsset = extraMarker.extra;
              break;
            }
          }
          return Transform.rotate(
            angle: -mapRotation * math.pi / 180,
            child: AspectRatio(
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
          );
        },
      ),
    );
  }

  List<MarkerExt<AssetExt>> _castMarkerToMarkerExt(List<Marker> markers) {
    List<MarkerExt<AssetExt>> extraMarkers =
        markers.map((marker) => marker as MarkerExt<AssetExt>).toList();
    return extraMarkers;
  }
}
