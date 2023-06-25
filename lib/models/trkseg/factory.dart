part of 'trkseg.dart';

class TrksegFactory {
  static Trkseg fromJson(Map<String, dynamic> json) {
    return Trkseg(
      config: TravelConfigFactory.fromJson(json['config']),
      trkpts: (json['trkpts'] as List<dynamic>)
          .map((e) => WptFactory.fromJson(e))
          .toList(),
    );
  }

  static Trkseg fromTrkseg({
    required gpx_pkg.Trkseg gpxTrkseg,
  }) {
    List<Wpt> trkpts = WptFactory.fromGpxWpts(gpxWpts: gpxTrkseg.trkpts);
    return Trkseg(
      trkpts: trkpts,
    );
  }

  static List<Trkseg> fromTrk({
    required gpx_pkg.Trk gpxTrk,
  }) {
    List<Trkseg> trksegs = [];
    for (gpx_pkg.Trkseg trkseg in gpxTrk.trksegs) {
      trksegs.add(
        fromTrkseg(
          gpxTrkseg: trkseg,
        ),
      );
    }
    return trksegs;
  }

  static List<Trkseg> fromGpx({
    required gpx_pkg.Gpx gpx,
  }) {
    debugPrint("TrksegFactory.fromGpx()");
    List<Trkseg> trksegs = [];
    for (gpx_pkg.Trk gpxTrk in gpx.trks) {
      trksegs.addAll(
        fromTrk(
          gpxTrk: gpxTrk,
        ),
      );
    }
    return trksegs;
  }
}
