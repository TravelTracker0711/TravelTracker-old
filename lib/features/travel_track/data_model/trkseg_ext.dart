import 'package:gpx/gpx.dart' as gpx_pkg;
import 'package:travel_tracker/features/travel_track/data_model/travel_data.dart';
import 'package:travel_tracker/features/travel_track/data_model/travel_config.dart';
import 'package:travel_tracker/features/travel_track/data_model/wpt.dart';
import 'package:travel_tracker/utils/datetime.dart';

class TrksegExt extends TravelData {
  final List<Wpt> _trkpts = <Wpt>[];

  List<Wpt> get trkpts => List<Wpt>.unmodifiable(_trkpts);
  DateTime? get startTime {
    for (Wpt trkpt in trkpts) {
      if (trkpt.time != null) {
        return trkpt.time;
      }
    }
    return null;
  }

  DateTime? get endTime {
    for (int i = trkpts.length - 1; i >= 0; i--) {
      Wpt trkpt = trkpts[i];
      if (trkpt.time != null) {
        return trkpt.time;
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = super.toJson();
    json.addAll({
      'trkpts': trkpts.map((e) => e.toJson()).toList(),
    });
    return json;
  }

  TrksegExt.fromJson(Map<String, dynamic> json)
      : this._(
          id: json['id'],
          config: TravelConfig.fromJson(json['config']),
          trkpts: (json['trkpts'] as List<dynamic>)
              .map((e) => Wpt.fromJson(e))
              .toList(),
        );

  TrksegExt({
    TravelConfig? config,
    List<Wpt>? trkpts,
  }) : this._(
          config: config,
          trkpts: trkpts,
        );

  TrksegExt._({
    String? id,
    TravelConfig? config,
    List<Wpt>? trkpts,
  }) : super(
          id: id,
          config: config,
        ) {
    if (trkpts != null) {
      _trkpts.addAll(trkpts);
      _trkpts.sort((a, b) => a.compareTo(b));
    }
  }

  int compareTo(TrksegExt other) {
    return nullableDateTimeCompare(startTime, other.startTime);
  }

  factory TrksegExt.fromTrkseg({
    required gpx_pkg.Trkseg trkseg,
  }) {
    List<Wpt> trkpts = Wpt.fromTrkseg(
      trkseg: trkseg,
    );
    return TrksegExt._(
      trkpts: trkpts,
    );
  }

  static List<TrksegExt> fromGpx({
    required gpx_pkg.Gpx gpx,
  }) {
    List<TrksegExt> trksegs = [];
    for (gpx_pkg.Trk trk in gpx.trks) {
      for (gpx_pkg.Trkseg trkseg in trk.trksegs) {
        trksegs.add(
          TrksegExt.fromTrkseg(
            trkseg: trkseg,
          ),
        );
      }
    }
    return trksegs;
  }

  void addTrkpt(Wpt trkpt) {
    _trkpts.add(trkpt);
  }
}

DateTime? getTrksegExtsStartTime(List<TrksegExt> trksegExts) {
  for (TrksegExt trksegExt in trksegExts) {
    if (trksegExt.startTime != null) {
      return trksegExt.startTime;
    }
  }
  return null;
}

DateTime? getTrksegExtsEndTime(List<TrksegExt> trksegExts) {
  for (int i = trksegExts.length - 1; i >= 0; i--) {
    TrksegExt trksegExt = trksegExts[i];
    if (trksegExt.endTime != null) {
      return trksegExt.endTime;
    }
  }
  return null;
}
