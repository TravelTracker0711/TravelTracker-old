import 'package:latlong2/latlong.dart' as latlng;
import 'package:travel_tracker/features/travel_track/data_model/travel_track.dart';
import 'package:travel_tracker/features/travel_track/data_model/trkseg_ext.dart';
import 'package:travel_tracker/features/travel_track/data_model/wpt.dart';

class TravelTrackStatsHandler {
  double getTotalTrksegDistance(TravelTrack travelTrack) {
    double totalDistance = 0.0;
    List<Wpt> trkpts = [];
    for (TrksegExt trksegExt in travelTrack.trksegExts) {
      trkpts.addAll(trksegExt.trkpts);
    }
    const latlng.Distance distance = latlng.Distance();

    for (int i = 0; i < trkpts.length - 1; ++i) {
      totalDistance += distance(trkpts[i].latLng, trkpts[i + 1].latLng);
    }
    return totalDistance;
  }

  double getTotalTrksegExtDuration(TravelTrack travelTrack) {
    double totalDuration = 0.0;
    for (TrksegExt trksegExt in travelTrack.trksegExts) {
      totalDuration +=
          trksegExt.endTime?.difference(trksegExt.startTime!).inSeconds ?? 0.0;
    }
    return totalDuration;
  }

  double getAverageSpeed(TravelTrack travelTrack) {
    double averageSpeed = getTotalTrksegDistance(travelTrack) /
        getTotalTrksegExtDuration(travelTrack);
    if (averageSpeed.isNaN) {
      averageSpeed = 0.0;
    }
    return averageSpeed;
  }
}
