import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:travel_tracker/features/asset/asset_ext_thumbnail_button.dart';
import 'package:travel_tracker/features/map_view/map_view_controller.dart';
import 'package:travel_tracker/features/map_view/marker_ext.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:travel_tracker/features/map_view/trkseg_ext_extractor.dart';
import 'package:travel_tracker/features/travel_track/data_model/travel_track.dart';
import 'package:travel_tracker/features/asset/data_model/asset_ext.dart';
import 'package:travel_tracker/features/travel_track/data_model/trkseg_ext.dart';
import 'package:travel_tracker/features/travel_track/data_model/wpt_ext.dart';

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
      travelTrack.clearAssetExtIdGroupsAsync();
      layers.add(buildMarkerClusterLayerByAssetExts(travelTrack.assetExts,
          travelTrack: travelTrack));
    }
    // if (_controller.isShowingAsset) {
    //   layers.add(buildMarkerClusterLayerByTravelTracks(travelTracks));
    // }
    return layers;
  }

  List<Widget> buildPolylineLayersByTravelTrack(TravelTrack travelTrack) {
    List<Widget> layers = <Widget>[];
    for (TrksegExt trksegExt in travelTrack.trksegExts) {
      layers.add(buildPolylineLayerByTrksegExt(trksegExt));
      if (_controller.mode == MapViewMode.partialTrack &&
          _controller.partialTrackMiddlePercentage != null) {
        layers.add(buildMiddlePointLayerByTrksegExt(trksegExt));
      }
    }
    return layers;
  }

  PolylineLayer buildPolylineLayerByTrksegExt(TrksegExt trksegExt) {
    List<WptExt> trkpts = trksegExt.trkpts;
    if (_controller.mode == MapViewMode.partialTrack &&
        _controller.partialTrackMiddlePercentage != null) {
      TrksegExtExtractor trksegExtExtractor = TrksegExtExtractor();
      trkpts = trksegExtExtractor.getPartialTrkpts(
        trkpts,
        _controller.partialTrackMiddlePercentage!,
      );
    }

    List<latlng.LatLng> points = <latlng.LatLng>[];
    for (WptExt trkpt in trkpts) {
      points.add(latlng.LatLng(trkpt.lat, trkpt.lon));
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

  Widget buildMiddlePointLayerByTrksegExt(TrksegExt trksegExt) {
    List<WptExt> trkpts = trksegExt.trkpts;
    WptExt middlePoint = trkpts[
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
    List<AssetExt> assetExts = <AssetExt>[];
    for (TravelTrack travelTrack in travelTracks) {
      assetExts.addAll(travelTrack.assetExts);
    }
    MarkerClusterLayerWidget layer =
        buildMarkerClusterLayerByAssetExts(assetExts);
    return layer;
  }

  MarkerClusterLayerWidget buildMarkerClusterLayerByAssetExts(
    List<AssetExt> assetExts, {
    TravelTrack? travelTrack,
  }) {
    List<MarkerExt<AssetExt>> markerExts = <MarkerExt<AssetExt>>[];
    for (AssetExt assetExt in assetExts) {
      MarkerExt<AssetExt>? markerExt = buildMarkerByAssetExt(assetExt);
      if (markerExt != null) {
        markerExts.add(markerExt);
      }
    }
    return buildMarkerClusterByMarkers(markerExts, travelTrack: travelTrack);
  }

  MarkerExt<AssetExt>? buildMarkerByAssetExt(AssetExt assetExt) {
    if (assetExt.coordinates == null) {
      return null;
    }
    double mapRotation = _mapRotationNotifier.value;
    return MarkerExt<AssetExt>(
      width: 70,
      height: 70,
      point: assetExt.coordinates!.latLng,
      rotate: false,
      extra: assetExt,
      builder: (BuildContext context) {
        return Transform.rotate(
          angle: -mapRotation * math.pi / 180,
          child: AssetExtThumbnailButton(
            displayedAssetExt: assetExt,
            onTap: () {
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
    List<MarkerExt<AssetExt>> markerExts, {
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
          List<MarkerExt<AssetExt>> extraMarkers =
              _castMarkerToMarkerExt(markers);
          List<AssetExt> assetExts = [];
          for (MarkerExt<AssetExt> extraMarker in extraMarkers) {
            if (extraMarker.extra != null) {
              assetExts.add(extraMarker.extra!);
            }
          }
          travelTrack
              ?.addAssetExtIdGroupAsync(assetExts.map((e) => e.id).toList());
          return Transform.rotate(
            angle: -mapRotation * math.pi / 180,
            child: AssetExtThumbnailButton(
              displayedAssetExt: assetExts.isEmpty ? null : assetExts.first,
              assetCount: extraMarkers.length,
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
