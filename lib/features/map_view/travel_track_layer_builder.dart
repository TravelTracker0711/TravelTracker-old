import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:travel_tracker/features/asset/asset_thumbnail_button.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:travel_tracker/features/map_view/map_view_controller.dart';
import 'package:travel_tracker/features/map_view/marker_ext.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:travel_tracker/features/map_view/trkseg_extractor.dart';
import 'package:travel_tracker/features/travel_track/data_model/travel_track.dart';
import 'package:travel_tracker/features/asset/data_model/asset.dart';
import 'package:travel_tracker/features/travel_track/data_model/trkseg.dart';
import 'package:travel_tracker/features/travel_track/data_model/wpt.dart';

class TravelTrackLayerBuilder {
  final ValueNotifier<double> _mapRotationNotifier;
  final MapViewController _controller;

  TravelTrackLayerBuilder({
    required mapRotationNotifier,
    required MapViewController mapViewController,
  })  : _mapRotationNotifier = mapRotationNotifier,
        _controller = mapViewController;

  List<Widget> build(List<TravelTrack> travelTracks) {
    List<Widget> layers = <Widget>[];
    for (TravelTrack travelTrack in travelTracks) {
      layers.addAll(buildPolylineLayersByTravelTrack(travelTrack));
      // travelTrack.clearAssetIdGroupsAsync();
      // layers.add(buildMarkerClusterLayerByAssets(travelTrack.assets,
      //     travelTrack: travelTrack));
    }
    if (_controller.isShowingAsset) {
      layers.add(buildMarkerClusterLayerByTravelTracks(travelTracks));
    }
    return layers;
  }

  List<Widget> buildPolylineLayersByTravelTrack(TravelTrack travelTrack) {
    List<Widget> layers = <Widget>[];
    for (Trkseg trkseg in travelTrack.trksegs) {
      layers.add(buildPolylineLayerByTrkseg(trkseg));
      if (_controller.mode == MapViewMode.partialTrack &&
          _controller.partialTrackMiddlePercentage != null) {
        layers.add(buildMiddlePointLayerByTrkseg(trkseg));
      }
    }
    return layers;
  }

  PolylineLayer buildPolylineLayerByTrkseg(Trkseg trkseg) {
    List<Wpt> trkpts = trkseg.trkpts;
    if (_controller.mode == MapViewMode.partialTrack &&
        _controller.partialTrackMiddlePercentage != null) {
      TrksegExtractor trksegExtractor = TrksegExtractor();
      trkpts = trksegExtractor.getPartialTrkpts(
        trkpts,
        _controller.partialTrackMiddlePercentage!,
      );
    }

    List<latlng.LatLng> points = <latlng.LatLng>[];
    for (Wpt trkpt in trkpts) {
      points.add(latlng.LatLng(trkpt.lat, trkpt.lon));
    }
    debugPrint('points.length: ${points.length}');
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

  Widget buildMiddlePointLayerByTrkseg(Trkseg trkseg) {
    List<Wpt> trkpts = trkseg.trkpts;

    /// TODO: fix the bug of index out of range.(round() -> truncate() ?)
    Wpt middlePoint = trkpts[
        (trkpts.length * _controller.partialTrackMiddlePercentage!).round()];

    Marker middlePointMarker = Marker(
      width: 30,
      height: 30,
      point: latlng.LatLng(middlePoint.lat, middlePoint.lon),
      anchorPos: AnchorPos.align(AnchorAlign.top),
      builder: (BuildContext context) {
        return IconButton(
          icon: const Icon(
            Icons.location_on,
            color: Colors.red,
          ),
          padding: const EdgeInsets.all(0),
          color: Colors.red,
          onPressed: () {
            debugPrint('onPressed middlePointMarker');
          },
        );
      },
    );
    MarkerLayer markerLayer = MarkerLayer(
      markers: <Marker>[middlePointMarker],
    );
    return markerLayer;
  }

  MarkerClusterLayerWidget buildMarkerClusterLayerByTravelTracks(
      List<TravelTrack> travelTracks) {
    List<Asset> assets = <Asset>[];
    for (TravelTrack travelTrack in travelTracks) {
      assets.addAll(travelTrack.assets);
    }
    MarkerClusterLayerWidget layer = buildMarkerClusterLayerByAssets(assets);
    return layer;
  }

  MarkerClusterLayerWidget buildMarkerClusterLayerByAssets(
    List<Asset> assets, {
    TravelTrack? travelTrack,
  }) {
    List<MarkerExt<Asset>> markerExts = <MarkerExt<Asset>>[];
    for (Asset asset in assets) {
      MarkerExt<Asset>? markerExt = buildMarkerByAsset(asset);
      if (markerExt != null) {
        markerExts.add(markerExt);
      }
    }
    return buildMarkerClusterByMarkers(markerExts, travelTrack: travelTrack);
  }

  MarkerExt<Asset>? buildMarkerByAsset(Asset asset) {
    if (asset.coordinates == null) {
      return null;
    }
    double mapRotation = _mapRotationNotifier.value;
    return MarkerExt<Asset>(
      width: 70,
      height: 70,
      point: asset.coordinates!.latLng,
      rotate: false,
      extra: asset,
      builder: (BuildContext context) {
        return Transform.rotate(
          angle: -mapRotation * math.pi / 180,
          child: AssetThumbnailButton(
            displayedAsset: asset,
            onTap: () {
              debugPrint('onPressed ${asset.assetEntity.title}');
              // TODO: show asset
              // Navigator.pushNamed(context, '/asset');
            },
          ),
        );
      },
    );
  }

  MarkerClusterLayerWidget buildMarkerClusterByMarkers(
    List<MarkerExt<Asset>> markerExts, {
    TravelTrack? travelTrack,
  }) {
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
        spiderfyCircleRadius: 80,
        disableClusteringAtZoom: 17,
        zoomToBoundsOnClick: false,
        markers: markerExts,
        builder: (context, markers) {
          List<MarkerExt<Asset>> extraMarkers = _castMarkerToMarkerExt(markers);
          List<Asset> assets = [];
          for (MarkerExt<Asset> extraMarker in extraMarkers) {
            if (extraMarker.extra != null) {
              assets.add(extraMarker.extra!);
            }
          }
          // travelTrack
          //     ?.addAssetIdGroupAsync(assets.map((e) => e.id).toList());
          return Transform.rotate(
            angle: -mapRotation * math.pi / 180,
            child: AssetThumbnailButton(
              displayedAsset: assets.isEmpty ? null : assets.first,
              assetCount: extraMarkers.length,
            ),
          );
        },
      ),
    );
  }

  List<MarkerExt<Asset>> _castMarkerToMarkerExt(List<Marker> markers) {
    List<MarkerExt<Asset>> extraMarkers =
        markers.map((marker) => marker as MarkerExt<Asset>).toList();
    return extraMarkers;
  }
}
