import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_tracker/features/map_view/map_view_controller.dart';
import 'package:travel_tracker/features/timeline_view/timeline_view_controller.dart';
import 'package:travel_tracker/features/timeline_view/travel_track_timeline.dart';
import 'package:travel_tracker/models/travel_track/travel_track.dart';
import 'package:travel_tracker/features/travel_track/travel_track_manager/travel_track_manager.dart';

class TimelineView extends StatefulWidget {
  const TimelineView({
    super.key,
    required this.mapViewController,
    required this.controller,
  });

  final MapViewController mapViewController;
  final TimelineViewController controller;

  @override
  State<TimelineView> createState() => _TimelineViewState();
}

class _TimelineViewState extends State<TimelineView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    widget.controller.scrollController = _scrollController;
  }

  @override
  Widget build(BuildContext context) {
    TravelTrack? activeTravelTrack =
        context.watch<TravelTrackManager>().activeTravelTrack;
    if (activeTravelTrack == null) {
      return const SizedBox.shrink();
    } else {
      return LayoutBuilder(
        builder: (context, constraints) {
          return _buildTimeline(
            activeTravelTrack,
            maxHeight: constraints.maxHeight,
          );
        },
      );
    }
  }

  Widget _buildTimeline(TravelTrack travelTrack, {required double maxHeight}) {
    return TravelTrackTimeline(
      scrollController: _scrollController,
      maxHeight: maxHeight,
      travelTrack: travelTrack,
    );
  }
}
