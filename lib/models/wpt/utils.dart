part of 'wpt.dart';

extension WptListUtils on List<Wpt> {
  /// expects a list of wpts sorted by time
  DateTime? get startTime {
    for (Wpt wpt in this) {
      if (wpt.time != null) {
        return wpt.time;
      }
    }
    return null;
  }

  /// expects a list of wpts sorted by time
  DateTime? get endTime {
    for (int i = length - 1; i >= 0; i--) {
      Wpt wpt = this[i];
      if (wpt.time != null) {
        return wpt.time;
      }
    }
    return null;
  }

  List<Wpt> clone() {
    return map((e) => e.clone()).toList();
  }
}
