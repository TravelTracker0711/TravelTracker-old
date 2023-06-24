part of 'asset.dart';

extension AssetConversion on Asset {
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'config': config.toJson(),
      'fileFullPath': fileFullPath,
      'type': type.toString(),
      'createdDateTime': createdDateTime.toIso8601String(),
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
