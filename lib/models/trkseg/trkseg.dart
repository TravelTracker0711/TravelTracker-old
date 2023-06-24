import 'package:gpx/gpx.dart' as gpx_pkg;
import 'package:travel_tracker/models/travel_config/travel_config.dart';
import 'package:travel_tracker/models/wpt/wpt.dart';
import 'package:travel_tracker/utils/datetime.dart';

class Trkseg {
  final TravelConfig config;
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
    Map<String, dynamic> json = {
      'config': config.toJson(),
      'trkpts': trkpts.map((e) => e.toJson()).toList(),
    };
    return json;
  }

  Trkseg.fromJson(Map<String, dynamic> json)
      : this._(
          config: TravelConfig.fromJson(json['config']),
          trkpts: (json['trkpts'] as List<dynamic>)
              .map((e) => WptFactory.fromJson(e))
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
    TravelConfig? config,
    List<Wpt>? trkpts,
  }) : config = config ?? TravelConfig() {
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
    List<Wpt> trkpts = WptFactory.fromTrkseg(
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
