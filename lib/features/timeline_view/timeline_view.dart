import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_tracker/features/timeline_view/travel_track_timeline_builder.dart';
import 'package:travel_tracker/features/travel_track/data_model/travel_track.dart';
import 'package:travel_tracker/features/travel_track/travel_track_manager.dart';

class TimelineView extends StatefulWidget {
  const TimelineView({
    super.key,
    // required this.controller,
  });

  // final TimelineViewController controller;

  @override
  State<TimelineView> createState() => _TimelineViewState();
}

class _TimelineViewState extends State<TimelineView> {
  @override
  Widget build(BuildContext context) {
    TravelTrack? activeTravelTrack =
        context.watch<TravelTrackManager>().activeTravelTrack;
    if (activeTravelTrack == null) {
      return const SizedBox.shrink();
    } else {
      return ChangeNotifierProvider(
        create: (context) => activeTravelTrack,
        child: Consumer<TravelTrack>(
          builder: (context, travelTrack, child) {
            return _buildTimeline(travelTrack);
          },
        ),
      );
    }
  }

  Widget _buildTimeline(TravelTrack travelTrack) {
    TravelTrackTimelineBuilder travelTrackTimelineTileBuilder =
        TravelTrackTimelineBuilder();
    return travelTrackTimelineTileBuilder.build(travelTrack);
  }
}
