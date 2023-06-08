import 'package:flutter/material.dart';
import 'package:gpx/gpx.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:travel_tracker/features/external_asset/external_asset_manager.dart';
import 'package:travel_tracker/features/travel_track/trkseg_ext.dart';
import 'package:uuid/uuid.dart';

enum AssetExtType {
  image,
  video,
  audio,
  text,
  other,
}

//TODO: all AssetExt factory methods
class AssetExt {
  final String id = const Uuid().v4();
  late final AssetEntity asset;
  late final AssetExtType type;
  late final String? filePath;
  late final latlng.LatLng? latLng;
  final List<String> tags = [];
  final TrksegExt? attachedTrksegExt;

  String? get title => asset.title;

  AssetExt._({
    required this.asset,
    required this.type,
    this.filePath,
    this.latLng,
    this.attachedTrksegExt,
  });

  static Future<AssetExt?> fromFilePathAsync({
    required String filePath,
    TrksegExt? attachedTrksegExt,
  }) async {
    // TODO: get asset, type, latLng from path
    AssetEntity? asset = await AssetEntity.fromId("TODO");
    if (asset == null) {
      return null;
    }
    AssetExtType type = AssetExtType.image;
    latlng.LatLng? latLng = latlng.LatLng(0, 0);

    return AssetExt._(
      asset: asset,
      type: type,
      filePath: filePath,
      latLng: latLng,
      attachedTrksegExt: attachedTrksegExt,
    );
  }

  // TODO: refactor
  static Future<List<AssetExt>> fromTimeRangeAsync({
    required DateTime? startTime,
    required DateTime? endTime,
    TrksegExt? attachedTrksegExt,
  }) async {
    List<AssetExt> assetExts = [];
    ExternalAssetManager eam = await ExternalAssetManager.FI;
    List<AssetEntity>? assets = await eam.getAssetsFilteredByTimeAsync(
      minDate: startTime,
      maxDate: endTime,
      isTimeAsc: true,
    );
    if (assets == null) {
      return assetExts;
    }
    for (AssetEntity asset in assets) {
      AssetExtType type = _getAssetType(asset);
      assetExts.add(
        AssetExt._(
          asset: asset,
          type: type,
          filePath: asset.relativePath,
          latLng: null,
          attachedTrksegExt: attachedTrksegExt,
        ),
      );
    }
    if (attachedTrksegExt != null) {
      assetExts = _locateAssetExtsInTrkseg(assetExts, attachedTrksegExt);
    }
    return assetExts;
  }

  static _getAssetType(AssetEntity asset) {
    if (asset.type == AssetType.audio) {
      return AssetExtType.audio;
    } else if (asset.type == AssetType.video) {
      return AssetExtType.video;
    } else if (asset.type == AssetType.image) {
      return AssetExtType.image;
    } else {
      return AssetExtType.other;
    }
  }

  static List<AssetExt> _locateAssetExtsInTrkseg(
    List<AssetExt> assetExts,
    TrksegExt trksegExt,
  ) {
    List<AssetExt> locatedAssetExts = [];
    List<Wpt> trkpts = trksegExt.trkseg.trkpts;
    int trkptIndex = 0;
    for (AssetExt assetExt in assetExts) {
      while (trkptIndex < trkpts.length - 1 &&
          (trkpts[trkptIndex + 1]
              .time!
              .isBefore(assetExt.asset.createDateTime))) {
        trkptIndex++;
      }
      latlng.LatLng latLng = latlng.LatLng(
        trkpts[trkptIndex].lat!,
        trkpts[trkptIndex].lon!,
      );
      debugPrint('latLng: $latLng');
      locatedAssetExts.add(
        AssetExt._(
          asset: assetExt.asset,
          type: assetExt.type,
          filePath: assetExt.filePath,
          latLng: latLng,
          attachedTrksegExt: trksegExt,
        ),
      );
    }
    return locatedAssetExts;
  }
}
