import 'package:flutter/material.dart';
import 'package:gpx/gpx.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:travel_tracker/features/external_asset/external_asset_manager.dart';
import 'package:travel_tracker/features/travel_track/trkseg_ext.dart';

enum TrkAssetType {
  image,
  video,
  audio,
  text,
  other,
}

//TODO: all TrkAsset factory methods
class TrkAsset {
  late final AssetEntity asset;
  late final TrkAssetType type;
  late final String? filePath;
  late final latlng.LatLng? latLng;
  final TrksegExt? attachedTrksegExt;

  TrkAsset._({
    required this.asset,
    required this.type,
    this.filePath,
    this.latLng,
    this.attachedTrksegExt,
  });

  static Future<TrkAsset?> fromFilePathAsync({
    required String filePath,
    TrksegExt? attachedTrksegExt,
  }) async {
    // TODO: get asset, type, latLng from path
    AssetEntity? asset = await AssetEntity.fromId("TODO");
    if (asset == null) {
      return null;
    }
    TrkAssetType type = TrkAssetType.image;
    latlng.LatLng? latLng = latlng.LatLng(0, 0);

    return TrkAsset._(
      asset: asset,
      type: type,
      filePath: filePath,
      latLng: latLng,
      attachedTrksegExt: attachedTrksegExt,
    );
  }

  // TODO: refactor
  static Future<List<TrkAsset>> fromTimeRangeAsync({
    required DateTime? startTime,
    required DateTime? endTime,
    TrksegExt? attachedTrksegExt,
  }) async {
    List<TrkAsset> trkAssets = [];
    ExternalAssetManager eam = await ExternalAssetManager.FI;
    List<AssetEntity>? assets = await eam.getAssetsFilteredByTimeAsync(
      minDate: startTime,
      maxDate: endTime,
      isTimeAsc: true,
    );
    if (assets == null) {
      return trkAssets;
    }
    for (AssetEntity asset in assets) {
      TrkAssetType type = _getAssetType(asset);
      trkAssets.add(
        TrkAsset._(
          asset: asset,
          type: type,
          filePath: asset.relativePath,
          latLng: null,
          attachedTrksegExt: attachedTrksegExt,
        ),
      );
    }
    if (attachedTrksegExt != null) {
      trkAssets = _locateTrkAssetsInTrkseg(trkAssets, attachedTrksegExt);
    }
    return trkAssets;
  }

  static _getAssetType(AssetEntity asset) {
    if (asset.type == AssetType.audio) {
      return TrkAssetType.audio;
    } else if (asset.type == AssetType.video) {
      return TrkAssetType.video;
    } else if (asset.type == AssetType.image) {
      return TrkAssetType.image;
    } else {
      return TrkAssetType.other;
    }
  }

  static List<TrkAsset> _locateTrkAssetsInTrkseg(
    List<TrkAsset> trkAssets,
    TrksegExt trksegExt,
  ) {
    List<TrkAsset> locatedTrkAssets = [];
    List<Wpt> trkpts = trksegExt.trkseg.trkpts;
    int trkptIndex = 0;
    for (TrkAsset trkAsset in trkAssets) {
      while (trkptIndex < trkpts.length - 1 &&
          (trkpts[trkptIndex + 1]
              .time!
              .isBefore(trkAsset.asset.createDateTime))) {
        trkptIndex++;
      }
      latlng.LatLng latLng = latlng.LatLng(
        trkpts[trkptIndex].lat!,
        trkpts[trkptIndex].lon!,
      );
      debugPrint('latLng: $latLng');
      locatedTrkAssets.add(
        TrkAsset._(
          asset: trkAsset.asset,
          type: trkAsset.type,
          filePath: trkAsset.filePath,
          latLng: latLng,
          attachedTrksegExt: trksegExt,
        ),
      );
    }
    return locatedTrkAssets;
  }
}
