import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_tracker/features/travel_track/data_model/travel_track.dart';
import 'package:travel_tracker/features/travel_track/travel_track_drawer_options.dart';
import 'package:travel_tracker/features/travel_track/travel_track_manager.dart';

class TravelTrackDrawer extends StatefulWidget {
  const TravelTrackDrawer({
    Key? key,
    required this.options,
  }) : super(key: key);

  final TravelTrackDrawerOptions options;
  @override
  State<TravelTrackDrawer> createState() => _TravelTrackDrawerState();
}

class _TravelTrackDrawerState extends State<TravelTrackDrawer> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(context) {
    List<TravelTrack> travelTracks =
        context.watch<TravelTrackManager>().travelTrackMap.values.toList();
    return Drawer(
      child: ListView(
        children: _buildTravelTrackList(context, travelTracks),
      ),
    );
  }

  List<Widget> _buildTravelTrackList(
      BuildContext context, List<TravelTrack> travelTracks) {
    List<Widget> travelTrackList = [];
    travelTrackList.add(
      DrawerHeader(
        decoration: const BoxDecoration(
          color: Colors.blue,
        ),
        child: Text(
          widget.options.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
          ),
        ),
      ),
    );
    travelTrackList.addAll(
      travelTracks.map((travelTrack) {
        if (!widget.options.travelTrackTileExpandMap
            .containsKey(travelTrack.id)) {
          widget.options.travelTrackTileExpandMap[travelTrack.id] = false;
        }
        return ExpansionTile(
          title: Text(travelTrack.config.name),
          initiallyExpanded:
              widget.options.travelTrackTileExpandMap[travelTrack.id]!,
          controlAffinity: ListTileControlAffinity.leading,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.visibility),
                onPressed: () {
                  // context
                  //     .read<TravelTrackManager>()
                  //     .addTravelTrackAsync(travelTrack);
                },
              ),
            ],
          ),
          onExpansionChanged: (bool isExpanded) {
            setState(() {
              widget.options.travelTrackTileExpandMap[travelTrack.id] =
                  isExpanded;
            });
          },
          children: _buildTrksegExtList(context, travelTrack),
        );
      }),
    );
    return travelTrackList;
  }

  List<Widget> _buildTrksegExtList(
    BuildContext context,
    TravelTrack travelTrack,
  ) {
    List<Widget> trksegExtList = [];
    trksegExtList.addAll(
      travelTrack.trksegExts.map((trksegExt) {
        return ListTile(
          leading: const Icon(Icons.timeline),
          title: Text(trksegExt.config.name),
          onTap: () {
            // context
            //     .read<TravelTrackManager>()
            //     .addTravelTrackAsync(travelTrack);
          },
        );
      }),
    );
    return trksegExtList;
  }
}
