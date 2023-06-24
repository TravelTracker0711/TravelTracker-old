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

extension AssetTypeConversion on AssetType {
  IconData get icon {
    switch (this) {
      case AssetType.audio:
        return Icons.audiotrack;
      case AssetType.video:
        return Icons.videocam;
      case AssetType.image:
        return Icons.image;
      case AssetType.text:
        return Icons.text_fields;
      case AssetType.unknown:
        return Icons.help;
      case AssetType.unset:
        return Icons.error;
      default:
        return Icons.error;
    }
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
