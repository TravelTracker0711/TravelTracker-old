import 'package:gpx/gpx.dart';
import '../travel_track/trkseg_ext.dart';

class TrksegExtExtractor {
  bool intersects(List<Wpt> list, Wpt w) {
    double x1 = w.lat!;
    double y1 = w.lon!;
    double x2 = list[list.length - 1].lat!;
    double y2 = list[list.length - 1].lon!;

    for (int i = 0; i < list.length - 1; i++) {
      double x3 = list[i].lat!;
      double y3 = list[i].lon!;
      double x4 = list[i + 1].lat!;
      double y4 = list[i + 1].lon!;
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

  List<Wpt> partialTrack(TrksegExt ext, double percentage) {
    List<Wpt> originalTracks = ext.trkseg.trkpts;
    int index = (percentage * originalTracks.length).round();

    List<Wpt> partialTrack = [];
    // 向左延伸
    for (int i = index; i >= 1; i--) {
      if (originalTracks[i].lat == null || originalTracks[i].lon == null) {
        continue;
      }
      if (intersects(partialTrack, originalTracks[i])) {
        break;
      }
      partialTrack.insert(0, originalTracks[i]);
    }

    // 向右延伸
    for (int i = index; i < originalTracks.length - 1; i++) {
      if (originalTracks[i].lat == null || originalTracks[i].lon == null) {
        continue;
      }
      if (intersects(partialTrack, originalTracks[i + 1])) {
        break;
      }
      partialTrack.add(ext.trkseg.trkpts[i]);
    }

    return partialTrack;
  }
}
