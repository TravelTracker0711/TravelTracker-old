import 'package:gpx/gpx.dart' as gpx_pkg;
import 'package:travel_tracker/models/travel_config/travel_config.dart';
import 'package:travel_tracker/models/wpt/wpt.dart';
import 'package:travel_tracker/utils/datetime.dart';

part 'factory.dart';
part 'conversion.dart';
part 'utils.dart';

class Trkseg {
  final TravelConfig config;
  final List<Wpt> _trkpts = <Wpt>[];

  /// Guarantee to be sorted by [Wpt.time] in ascending order.
  List<Wpt> get trkpts => List<Wpt>.unmodifiable(_trkpts);
  DateTime? get startTime => _trkpts.startTime;
  DateTime? get endTime => _trkpts.endTime;

  Trkseg({
    TravelConfig? config,
    List<Wpt>? trkpts,
  }) : config = config?.clone() ?? TravelConfig() {
    if (trkpts != null) {
      _trkpts
        ..addAll(trkpts.clone())
        ..sort((a, b) => a.compareTo(b));
    }
  }

  Trkseg clone() => Trkseg(
        config: config,
        trkpts: _trkpts,
      );

  int compareTo(Trkseg other) {
    return nullableDateTimeCompare(startTime, other.startTime);
  }

  void addTrkpt(Wpt trkpt) {
    _trkpts
      ..add(trkpt)
      ..sort((a, b) => a.compareTo(b));
  }
}
