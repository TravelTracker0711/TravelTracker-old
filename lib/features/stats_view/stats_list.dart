import 'package:flutter/material.dart';
import 'package:travel_tracker/features/travel_track/data_model/travel_track.dart';
import 'package:travel_tracker/features/stats_view/travel_track_stats_handler.dart';

class StatsList extends StatelessWidget {
  const StatsList({Key? key, required this.travelTrack}) : super(key: key);

  final TravelTrack travelTrack;

  @override
  Widget build(BuildContext context) {
    TravelTrackStatsHandler travelTrackStatsHandler = TravelTrackStatsHandler();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ListTile(
          title: const Text('Total Track Segments'),
          subtitle: Text('${travelTrack.trksegs.length}'),
        ),
        ListTile(
          title: const Text('Total Distance'),
          subtitle: Text(
              '${(travelTrackStatsHandler.getTotalTrksegDistance(travelTrack) / 1000).toStringAsFixed(2)} kilometers'),
        ),
        ListTile(
          title: const Text('Total Duration'),
          subtitle: Text(
              '${(travelTrackStatsHandler.getTotalTrksegDuration(travelTrack) / 60).toStringAsFixed(2)} minutes'),
        ),
        ListTile(
          title: const Text('Average Speed'),
          subtitle: Text(
              '${(travelTrackStatsHandler.getAverageSpeed(travelTrack) * 3.6).toStringAsFixed(2)} kilometers per hour'),
        ),
        ListTile(
          title: const Text('Start Time'),
          subtitle: Text(travelTrack.startTime.toString().substring(0, 19)),
        ),
        ListTile(
          title: const Text('End Time'),
          subtitle: Text(travelTrack.endTime.toString().substring(0, 19)),
        ),
      ],
    );
  }
}
