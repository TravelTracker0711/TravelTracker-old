import 'package:latlong2/latlong.dart' as latlng;
import 'package:travel_tracker/models/travel_track/travel_track.dart';
import 'package:travel_tracker/models/trkseg/trkseg.dart';
import 'package:travel_tracker/models/wpt/wpt.dart';

class TravelTrackStatsHandler {
  double getTotalTrksegDistance(TravelTrack travelTrack) {
    double totalDistance = 0.0;
    List<Wpt> trkpts = [];
    for (Trkseg trkseg in travelTrack.trksegs) {
      trkpts.addAll(trkseg.trkpts);
    }
    const latlng.Distance distance = latlng.Distance();

    for (int i = 0; i < trkpts.length - 1; ++i) {
      totalDistance += distance(trkpts[i].latLng, trkpts[i + 1].latLng);
    }
    return totalDistance;
  }

  double getTotalTrksegDuration(TravelTrack travelTrack) {
    double totalDuration = 0.0;
    for (Trkseg trkseg in travelTrack.trksegs) {
      totalDuration +=
          trkseg.endTime?.difference(trkseg.startTime!).inSeconds ?? 0.0;
    }
    return totalDuration;
  }

  double getAverageSpeed(TravelTrack travelTrack) {
    double averageSpeed = getTotalTrksegDistance(travelTrack) /
        getTotalTrksegDuration(travelTrack);
    if (averageSpeed.isNaN) {
      averageSpeed = 0.0;
    }
    return averageSpeed;
  }
}
