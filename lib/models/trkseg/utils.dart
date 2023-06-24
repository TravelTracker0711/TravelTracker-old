part of 'trkseg.dart';

extension TrksegListUtil on List<Trkseg> {
  /// expects a list of trksegs sorted by time
  DateTime? get startTime {
    for (Trkseg trkseg in this) {
      if (trkseg.startTime != null) {
        return trkseg.startTime;
      }
    }
    return null;
  }

  /// expects a list of trksegs sorted by time
  DateTime? get endTime {
    for (int i = length - 1; i >= 0; i--) {
      Trkseg trkseg = this[i];
      if (trkseg.endTime != null) {
        return trkseg.endTime;
      }
    }
    return null;
  }

  List<Trkseg> clone() {
    return map((e) => e.clone()).toList();
  }
}
