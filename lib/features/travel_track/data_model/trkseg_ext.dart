import 'package:gpx/gpx.dart';
import 'package:travel_tracker/features/travel_track/data_model/travel_data.dart';
import 'package:travel_tracker/features/travel_track/data_model/travel_config.dart';
import 'package:travel_tracker/features/travel_track/data_model/wpt_ext.dart';

class TrksegExt extends TravelData {
  final List<WptExt> _trkpts = <WptExt>[];

  List<WptExt> get trkpts => List<WptExt>.unmodifiable(_trkpts);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = super.toJson();
    json.addAll({
      'trkpts': trkpts.map((e) => e.toJson()).toList(),
    });
    return json;
  }

  TrksegExt._({
    String? id,
    TravelConfig? config,
    List<WptExt>? trkpts,
  }) : super(
          id: id,
          config: config,
        ) {
    if (trkpts != null) {
      _trkpts.addAll(trkpts);
    }
  }

  factory TrksegExt.fromTrkseg({
    required Trkseg trkseg,
  }) {
    List<WptExt> trkpts = WptExt.fromTrkseg(
      trkseg: trkseg,
    );
    return TrksegExt._(
      trkpts: trkpts,
    );
  }

  static List<TrksegExt> fromGpx({
    required Gpx gpx,
  }) {
    List<TrksegExt> trksegs = [];
    for (Trk trk in gpx.trks) {
      for (Trkseg trkseg in trk.trksegs) {
        trksegs.add(
          TrksegExt.fromTrkseg(
            trkseg: trkseg,
          ),
        );
      }
    }
    return trksegs;
  }
}
