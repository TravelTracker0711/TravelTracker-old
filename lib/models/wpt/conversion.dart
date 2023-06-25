part of 'wpt.dart';

extension WptConversion on Wpt {
  gpx_pkg.Wpt toGpxWpt() {
    gpx_pkg.Wpt gpxWpt = gpx_pkg.Wpt(
      lat: lat,
      lon: lon,
    );
    if (ele != null) {
      gpxWpt.ele = ele;
    }
    if (time != null) {
      gpxWpt.time = time;
    }
    return gpxWpt;
  }
}
