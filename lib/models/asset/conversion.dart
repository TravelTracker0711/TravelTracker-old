part of 'asset.dart';

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
