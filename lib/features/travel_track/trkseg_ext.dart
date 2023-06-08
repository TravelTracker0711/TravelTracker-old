import 'package:gpx/gpx.dart';
import 'package:travel_tracker/features/travel_track/gpx_ext.dart';
import 'package:uuid/uuid.dart';

class TrksegExt {
  final String id = const Uuid().v4();
  final Trkseg trkseg;
  late String name;
  final GpxExt? attachedGpxExt;

  TrksegExt._({
    required this.trkseg,
    String? name,
    this.attachedGpxExt,
  }) {
    this.name = name ?? 'Unnamed Trkseg';
  }

  static List<TrksegExt> fromGpxExt({
    required GpxExt gpxExt,
  }) {
    List<TrksegExt> trksegs = [];
    for (Trk trk in gpxExt.gpx.trks) {
      for (Trkseg trkseg in trk.trksegs) {
        String trksegName = '${gpxExt.name} - Trkseg ${trksegs.length + 1}';
        trksegs.add(TrksegExt._(
          trkseg: trkseg,
          attachedGpxExt: gpxExt,
          name: trksegName,
        ));
      }
    }
    return trksegs;
  }

  factory TrksegExt.fromTrkseg({
    required Trkseg trkseg,
    String? name,
  }) {
    return TrksegExt._(
      trkseg: trkseg,
      name: name,
    );
  }
}
