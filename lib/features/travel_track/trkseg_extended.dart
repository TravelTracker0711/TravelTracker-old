import 'package:gpx/gpx.dart';
import 'package:travel_tracker/features/travel_track/gpx_extended.dart';

class TrksegExtended {
  final Trkseg trkseg;
  final GpxExtended? attachedGpx;

  TrksegExtended._({
    required this.trkseg,
    this.attachedGpx,
  });

  static List<TrksegExtended> fromGpxExtended({
    required GpxExtended gpxExtended,
  }) {
    List<TrksegExtended> trksegs = [];
    for (Trk trk in gpxExtended.gpx.trks) {
      for (Trkseg trkseg in trk.trksegs) {
        trksegs.add(TrksegExtended._(
          trkseg: trkseg,
          attachedGpx: gpxExtended,
        ));
      }
    }
    return trksegs;
  }

  factory TrksegExtended.fromTrkseg({
    required Trkseg trkseg,
  }) {
    return TrksegExtended._(
      trkseg: trkseg,
    );
  }
}
