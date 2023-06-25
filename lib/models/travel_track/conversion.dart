part of 'travel_track.dart';

extension TravelTrackConversion on TravelTrack {
  gpx_pkg.Gpx toGpx() {
    gpx_pkg.Gpx gpx = gpx_pkg.Gpx();

    List<gpx_pkg.Wpt> gpxWpts = [];
    for (Wpt wpt in _wpts) {
      gpxWpts.add(wpt.toGpxWpt());
    }
    gpx.wpts = gpxWpts;

    List<gpx_pkg.Trkseg> gpxTrksegs = [];
    for (Trkseg trkseg in _trksegs) {
      gpxTrksegs.add(trkseg.toGpxTrkseg());
    }
    gpx.trks = [
      gpx_pkg.Trk(
        trksegs: gpxTrksegs,
      ),
    ];
    return gpx;
  }
}
