import 'package:photo_manager/photo_manager.dart';

class PhotoManagerExtension {
  static Future<AssetPathEntity?> getAllAssetsPathEntityAsync() async {
    List<AssetPathEntity> pathEntities = await PhotoManager.getAssetPathList(
      type: RequestType.all,
      onlyAll: true,
    );
    if (pathEntities.isEmpty) {
      return null;
    }
    return pathEntities[0];
  }
}

extension AssetPathEntityExtension on AssetPathEntity {
  Future<List<AssetEntity>> getAllAssetEntitiesAsync() async {
    List<AssetEntity> assetEntities = await getAssetListRange(
      start: 0,
      end: await assetCountAsync,
    );
    return assetEntities;
  }
}

extension AssetEntitiesExtension on List<AssetEntity> {
  Map<String, AssetEntity> toMap() {
    return {
      for (AssetEntity assetEntity in this) assetEntity.id: assetEntity,
    };
  }
}
