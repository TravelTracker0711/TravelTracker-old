part of 'wpt.dart';

extension WptConversion on Wpt {
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'config': config.toJson(),
      'lat': lat,
      'lon': lon,
    };
    if (ele != null) {
      json['ele'] = ele;
    }
    if (time != null) {
      json['time'] = time!.toIso8601String();
    }
    return json;
  }
}
