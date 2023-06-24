import 'package:gpx/gpx.dart' as gpx_pkg;
import 'package:travel_tracker/features/travel_track/data_model/travel_data.dart';
import 'package:travel_tracker/features/travel_track/data_model/travel_config.dart';
import 'package:travel_tracker/features/travel_track/data_model/wpt.dart';
import 'package:travel_tracker/utils/datetime.dart';

class Trkseg extends TravelData {
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

  Trkseg.fromJson(Map<String, dynamic> json)
      : this._(
          id: json['id'],
          config: TravelConfig.fromJson(json['config']),
          trkpts: (json['trkpts'] as List<dynamic>)
              .map((e) => Wpt.fromJson(e))
              .toList(),
        );

  Trkseg({
    TravelConfig? config,
    List<Wpt>? trkpts,
  }) : this._(
          config: config,
          trkpts: trkpts,
        );

  Trkseg._({
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

  int compareTo(Trkseg other) {
    return nullableDateTimeCompare(startTime, other.startTime);
  }

  factory Trkseg.fromTrkseg({
    required gpx_pkg.Trkseg trkseg,
  }) {
    List<Wpt> trkpts = Wpt.fromTrkseg(
      trkseg: trkseg,
    );
    return Trkseg._(
      trkpts: trkpts,
    );
  }

  static List<Trkseg> fromGpx({
    required gpx_pkg.Gpx gpx,
  }) {
    List<Trkseg> trksegs = [];
    for (gpx_pkg.Trk trk in gpx.trks) {
      for (gpx_pkg.Trkseg trkseg in trk.trksegs) {
        trksegs.add(
          Trkseg.fromTrkseg(
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

DateTime? getTrksegsStartTime(List<Trkseg> trksegs) {
  for (Trkseg trkseg in trksegs) {
    if (trkseg.startTime != null) {
      return trkseg.startTime;
    }
  }
  return null;
}

DateTime? getTrksegsEndTime(List<Trkseg> trksegs) {
  for (int i = trksegs.length - 1; i >= 0; i--) {
    Trkseg trkseg = trksegs[i];
    if (trkseg.endTime != null) {
      return trkseg.endTime;
    }
  }
  return null;
}
