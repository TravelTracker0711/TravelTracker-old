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
    required geolocator.Position position,
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

  static Wpt fromLocationData({
    required loc.LocationData locationData,
  }) {
    DateTime time = locationData.time == null
        ? DateTime.now()
        : DateTime.fromMillisecondsSinceEpoch(locationData.time!.toInt());
    return Wpt(
      latLng: latlng.LatLng(
        locationData.latitude!,
        locationData.longitude!,
      ),
      elevation: locationData.altitude,
      time: time,
    );
  }

  static Wpt fromBgLocation({
    required bg.Location location,
  }) {
    return Wpt(
      latLng: latlng.LatLng(
        location.coords.latitude,
        location.coords.longitude,
      ),
      elevation: location.coords.altitude,
      time: DateTime.parse(location.timestamp),
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
