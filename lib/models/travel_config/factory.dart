part of 'travel_config.dart';

class TravelConfigFactory {
  static TravelConfig fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return TravelConfig();
    }
    return TravelConfig(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      tags: json['tags'],
    );
  }

  static TravelConfig fromAssetEntity(AssetEntity assetEntity) {
    return TravelConfig(
      name: assetEntity.title,
    );
  }
}
