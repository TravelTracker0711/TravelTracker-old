part of 'trkseg.dart';

extension TrksegConversion on Trkseg {
  gpx_pkg.Trkseg toGpxTrkseg() {
    List<gpx_pkg.Wpt> gpxTrkpts = [];
    for (Wpt wpt in trkpts) {
      gpx_pkg.Wpt gpxWpt = wpt.toGpxWpt();
      gpxTrkpts.add(gpxWpt);
    }
    gpx_pkg.Trkseg gpxTrkseg = gpx_pkg.Trkseg(trkpts: gpxTrkpts);
    return gpxTrkseg;
  }
}
