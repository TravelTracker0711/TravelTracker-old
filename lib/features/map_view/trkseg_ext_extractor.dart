import 'package:flutter/material.dart';
import 'package:travel_tracker/features/travel_track/data_model/wpt_ext.dart';

class TrksegExtExtractor {
  bool _intersects(List<WptExt> wpts, WptExt w) {
    if (wpts.length < 2) {
      return false;
    }
    double x1 = w.lat;
    double y1 = w.lon;
    double x2 = wpts[wpts.length - 1].lat;
    double y2 = wpts[wpts.length - 1].lon;

    for (int i = 0; i < wpts.length - 1; i++) {
      double x3 = wpts[i].lat;
      double y3 = wpts[i].lon;
      double x4 = wpts[i + 1].lat;
      double y4 = wpts[i + 1].lon;
      if ((y2 - y1) * (x4 - x3) - (x2 - x1) * (y4 - y3) != 0) {
        double t1 = ((x3 - x1) * (y3 - y4) - (y3 - y1) * (x3 - x4)) /
            ((x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4));
        double t2 = ((x1 - x2) * (y3 - y1) - (y1 - y2) * (x3 - x1)) /
            ((x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4));
        if (0 <= t1 && t1 <= 1 && 0 <= t2 && t2 <= 1) {
          return true;
        }
      }
    }
    return false;
  }

  List<WptExt> getPartialTrkpts(List<WptExt> trkpts, double percentage) {
    int index = (percentage * trkpts.length).round();

    List<WptExt> partialTrack = [];
    // 向左延伸
    for (int i = index; i >= 1; i--) {
      if (_intersects(partialTrack, trkpts[i])) {
        break;
      }
      partialTrack.insert(0, trkpts[i]);
    }

    // 向右延伸
    for (int i = index; i < trkpts.length - 1; i++) {
      if (_intersects(partialTrack, trkpts[i + 1])) {
        break;
      }
      partialTrack.add(trkpts[i]);
    }

    debugPrint(partialTrack.length.toString());
    return partialTrack;
  }
}
