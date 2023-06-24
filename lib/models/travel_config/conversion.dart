part of 'travel_config.dart';

extension TravelConfigConversion on TravelConfig {
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'id': id,
      'name': name,
    };
    if (description != null) {
      json['description'] = description;
    }
    if (tags.isNotEmpty) {
      json['tags'] = tags;
    }
    return json;
  }
}
