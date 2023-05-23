import 'package:gpx/gpx.dart';
import 'package:travel_tracker/features/travel_track/gpx_ext.dart';

class TrksegExt {
  final Trkseg trkseg;
  final GpxExt? attachedGpxExt;

  TrksegExt._({
    required this.trkseg,
    this.attachedGpxExt,
  });

  static List<TrksegExt> fromGpxExt({
    required GpxExt gpxExt,
  }) {
    List<TrksegExt> trksegs = [];
    for (Trk trk in gpxExt.gpx.trks) {
      for (Trkseg trkseg in trk.trksegs) {
        trksegs.add(TrksegExt._(
          trkseg: trkseg,
          attachedGpxExt: gpxExt,
        ));
      }
    }
    return trksegs;
  }

  factory TrksegExt.fromTrkseg({
    required Trkseg trkseg,
  }) {
    return TrksegExt._(
      trkseg: trkseg,
    );
  }
}
