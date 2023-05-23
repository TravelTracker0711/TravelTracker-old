import 'package:photo_manager/photo_manager.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:travel_tracker/features/travel_track/trkseg_extended.dart';

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
  late final String? path;
  late final latlng.LatLng? latLng;
  final TrksegExtended? attachedTrkseg;

  TrkAsset._({
    required this.asset,
    required this.type,
    this.path,
    this.latLng,
    this.attachedTrkseg,
  });

  static Future<TrkAsset?> fromPath({
    required String path,
    TrksegExtended? attachedTrkseg,
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
      path: path,
      latLng: latLng,
      attachedTrkseg: attachedTrkseg,
    );
  }

  // TODO: read from external_asset_manager
  static Future<List<TrkAsset>> fromTimeRange({
    required DateTime start,
    required DateTime end,
  }) async {
    List<TrkAsset> trkAssets = [];
    return trkAssets;
  }
}
