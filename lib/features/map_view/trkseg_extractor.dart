import 'package:flutter/material.dart';
import 'package:travel_tracker/models/wpt/wpt.dart';
import 'dart:math';

class TrksegExtractor {
  double _orientation(
      double x1, double y1, double x2, double y2, double x3, double y3) {
    return (x2 - x1) * (y3 - y1) - (x3 - x1) * (y2 - y1);
  }

  bool _onSegment(
      double x1, double y1, double x2, double y2, double x3, double y3) {
    if (min(x2, x3) < x1 &&
        max(x2, x3) > x1 &&
        min(y2, y3) < y1 &&
        max(y2, y3) > y1) {
      return true;
    }
    return false;
  }

  bool _intersects(List<Wpt> wpts, Wpt w1, Wpt w2) {
    if (wpts.length < 2) {
      return false;
    }
    double x1 = w1.lat;
    double y1 = w1.lon;
    double x2 = w2.lat;
    double y2 = w2.lon;

    for (int i = 0; i < wpts.length - 1; i++) {
      double x3 = wpts[i].lat;
      double y3 = wpts[i].lon;
      double x4 = wpts[i + 1].lat;
      double y4 = wpts[i + 1].lon;
      double d1 = _orientation(x3, y3, x4, y4, x1, y1); // p3 -> p4 X p3 -> p1
      double d2 = _orientation(x3, y3, x4, y4, x2, y2);
      double d3 = _orientation(x2, y2, x1, y1, x3, y3);
      double d4 = _orientation(x2, y2, x1, y1, x4, y4);

      if (((d1 > 0 && d2 < 0) || (d1 < 0 && d2 > 0)) &&
          ((d3 > 0 && d4 < 0) || (d3 < 0 && d4 > 0))) {
        return true;
      } else if (d1 == 0 && _onSegment(x1, y1, x3, y3, x4, y4)) {
        // p1 on p3p4
        return true;
      } else if (d2 == 0 && _onSegment(x2, y2, x3, y3, x4, y4)) {
        // p2 on p3p4
        return true;
      } else if (d3 == 0 && _onSegment(x3, y3, x1, y1, x2, y2)) {
        // p3 on p1p2
        return true;
      } else if (d4 == 0 && _onSegment(x4, y4, x1, y1, x2, y2)) {
        // p4 on p1p2
        return true;
      }
    }
    return false;
  }

  List<Wpt> getPartialTrkpts(List<Wpt> trkpts, double percentage) {
    int index = (percentage * trkpts.length).truncate();

    List<Wpt> partialTrack = [];
    partialTrack.add(trkpts[index]);

    // 向左延伸
    for (int i = index - 1; i >= 0; i--) {
      if (_intersects(partialTrack, trkpts[i], partialTrack[0])) {
        break;
      }
      partialTrack.insert(0, trkpts[i]);
    }

    // 向右延伸
    for (int i = index + 1; i < trkpts.length; i++) {
      if (_intersects(
          partialTrack, trkpts[i], partialTrack[partialTrack.length - 1])) {
        break;
      }
      partialTrack.add(trkpts[i]);
    }

    debugPrint(partialTrack.length.toString());
    return partialTrack;
  }
}
