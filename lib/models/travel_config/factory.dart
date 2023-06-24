part of 'travel_config.dart';

class TravelConfigFactory {
  static TravelConfig fromJson(Map<String, dynamic> json) {
    return TravelConfig(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      tags: json['tags'],
    );
  }
}
