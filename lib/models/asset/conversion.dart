part of 'asset.dart';

extension AssetConversion on Asset {
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'config': config.toJson(),
      'type': _type.toString(),
    };
    if (assetEntityId != null) {
      json['assetEntityId'] = assetEntityId;
    }
    if (attachedTrksegId != null) {
      json['attachedTrksegId'] = attachedTrksegId;
    }
    if (coordinates != null) {
      json['coordinates'] = coordinates!.toJson();
    }
    if (_createdDateTime != null) {
      json['createdDateTime'] = _createdDateTime.toString();
    }
    return json;
  }
}

extension StringAssetTypeConversion on String {
  AssetType toAssetType() {
    return _AssetTypeFactory.fromString(this);
  }
}

extension PhotoManagerAssetTypeConversion on pm.AssetType {
  AssetType toAssetType() {
    return _AssetTypeFactory.fromPhotoManagerType(this);
  }
}
