part of 'asset.dart';

AssetType _getAssetType(pm.AssetEntity assetEntity) {
  if (assetEntity.type == pm.AssetType.audio) {
    return AssetType.audio;
  } else if (assetEntity.type == pm.AssetType.video) {
    return AssetType.video;
  } else if (assetEntity.type == pm.AssetType.image) {
    return AssetType.image;
  } else {
    return AssetType.unknown;
  }
}
