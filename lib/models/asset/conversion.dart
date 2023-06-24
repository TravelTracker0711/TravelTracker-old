part of 'asset.dart';

extension AssetConversion on Asset {
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'config': config.toJson(),
      'type': type.toString(),
      'fileFullPath': fileFullPath,
    };
    if (coordinates != null) {
      json['coordinates'] = coordinates!.toJson();
    }
    if (attachedTrksegId != null) {
      json['attachedTrksegId'] = attachedTrksegId;
    }
    return json;
  }
}
