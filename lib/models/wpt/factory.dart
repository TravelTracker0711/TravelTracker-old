part of 'wpt.dart';

class WptFactory {
  static Wpt fromJson(Map<String, dynamic> json) {
    return Wpt(
      config: TravelConfigFactory.fromJson(json['config']),
      latLng: latlng.LatLng(
        json['lat'],
        json['lon'],
      ),
      elevation: json['ele'],
      time: json['time'] == null ? null : DateTime.parse(json['time']),
    );
  }

  static Wpt fromPosition({
    required Position position,
  }) {
    return Wpt(
      latLng: latlng.LatLng(
        position.latitude,
        position.longitude,
      ),
      elevation: position.altitude,
      time: position.timestamp,
    );
  }

  static Wpt fromGpxWpt({
    required gpx_pkg.Wpt gpxWpt,
  }) {
    if (gpxWpt.lat == null || gpxWpt.lon == null) {
      throw Exception('gpxWpt must have lat and lon');
    }
    return Wpt(
      latLng: latlng.LatLng(
        gpxWpt.lat!,
        gpxWpt.lon!,
      ),
      elevation: gpxWpt.ele,
      time: gpxWpt.time,
    );
  }

  static List<Wpt> fromGpxWpts({
    required List<gpx_pkg.Wpt> gpxWpts,
  }) {
    List<Wpt> wpts = [];
    for (gpx_pkg.Wpt gpxWpt in gpxWpts) {
      if (gpxWpt.lat == null || gpxWpt.lon == null) {
        continue;
      }
      wpts.add(fromGpxWpt(gpxWpt: gpxWpt));
    }
    return wpts;
  }
}
