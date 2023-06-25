import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_tracker/features/stats_view/stats_list.dart';
import 'package:travel_tracker/models/travel_track/travel_track.dart';
import 'package:travel_tracker/features/travel_track/travel_track_list_view_options.dart';
import 'package:travel_tracker/features/travel_track/travel_track_manager/travel_track_manager.dart';

class TravelTrackListView extends StatefulWidget {
  const TravelTrackListView({
    Key? key,
    required this.options,
    this.showDrawerHeader = true,
  }) : super(key: key);

  final TravelTrackListViewOptions options;
  final bool showDrawerHeader;

  @override
  State<TravelTrackListView> createState() => _TravelTrackListViewState();
}

class _TravelTrackListViewState extends State<TravelTrackListView> {
  late TravelTrackManager travelTrackManager;
  late List<TravelTrack> travelTracks;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(context) {
    travelTrackManager = context.watch<TravelTrackManager>();
    travelTracks = travelTrackManager.travelTracks;

    List<Widget> children = [];
    if (widget.showDrawerHeader) {
      children.add(_buildDrawerHeader(context, travelTracks));
    }
    // TODO: use isolate to build in background
    children.add(_buildExpansionPanelList(context, travelTracks));

    return ListView(
      children: children,
    );
  }

  DrawerHeader _buildDrawerHeader(
    BuildContext context,
    List<TravelTrack> travelTracks,
  ) {
    return DrawerHeader(
      decoration: const BoxDecoration(
        color: Colors.blue,
      ),
      child: Center(
        child: Column(
          children: [
            Text(
              widget.options.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
            Spacer(),
            Text(
              '${travelTracks.length} travel tracks',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  ExpansionPanelList _buildExpansionPanelList(
    BuildContext context,
    List<TravelTrack> travelTracks,
  ) {
    return ExpansionPanelList(
      children: _buildTravelTrackExpansionPanels(context, travelTracks),
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          widget.options.isTravelTrackExpandedMap[travelTracks[index].id] =
              !isExpanded;
        });
      },
    );
  }

  List<ExpansionPanel> _buildTravelTrackExpansionPanels(
      BuildContext context, List<TravelTrack> travelTracks) {
    List<ExpansionPanel> travelTrackExpansionPanels = [];
    travelTrackExpansionPanels.addAll(
      travelTracks.map((travelTrack) {
        if (!widget.options.isTravelTrackExpandedMap
            .containsKey(travelTrack.id)) {
          widget.options.isTravelTrackExpandedMap[travelTrack.id] = false;
        }
        return ExpansionPanel(
          headerBuilder: (BuildContext context, bool isExpanded) {
            return _buildTravelTrackExpansionPanelHeader(
              context,
              travelTrack,
            );
          },
          body: StatsList(travelTrack: travelTrack),
          // body: ListView(
          //   shrinkWrap: true,
          //   children: _buildTrksegListTiles(context, travelTrack),
          // ),
          canTapOnHeader: true,
          isExpanded:
              widget.options.isTravelTrackExpandedMap[travelTrack.id] ?? false,
        );
      }),
    );
    return travelTrackExpansionPanels;
  }

  Widget _buildTravelTrackExpansionPanelHeader(
    BuildContext context,
    TravelTrack travelTrack,
  ) {
    return GestureDetector(
      onLongPress: () {
        travelTrackManager.setTravelTrackSelected(
          travelTrackId: travelTrack.id,
          isSelected: !travelTrackManager.isTravelTrackSelected(travelTrack.id),
        );
      },
      child: ListTile(
        title: Text(
          travelTrack.config.name,
          style: TextStyle(
            color: travelTrackManager.isTravelTrackSelected(travelTrack.id)
                ? Theme.of(context).primaryColor
                : travelTrackManager.isTravelTrackVisible(travelTrack.id)
                    ? Colors.black
                    : Colors.grey,
          ),
        ),
        leading: travelTrackManager.isAnyTravelTrackSelected
            ? Checkbox(
                value: travelTrackManager.isTravelTrackSelected(travelTrack.id),
                onChanged: (bool? value) {
                  travelTrackManager.setTravelTrackSelected(
                    travelTrackId: travelTrack.id,
                    isSelected: value ?? false,
                  );
                },
              )
            : Wrap(
                children: [
                  // Flexible(
                  //   child: IconButton(
                  //     icon: TravelTrackManager.I
                  //             .isTravelTrackVisible(travelTrack.id)
                  //         ? const Icon(Icons.visibility)
                  //         : const Icon(Icons.visibility_off),
                  //     onPressed: () {
                  //       TravelTrackManager.I.setTravelTrackVisible(
                  //         travelTrackId: travelTrack.id,
                  //         isVisible: !TravelTrackManager.I
                  //             .isTravelTrackVisible(travelTrack.id),
                  //       );
                  //     },
                  //   ),
                  // ),
                  Flexible(
                    child: IconButton(
                      icon: TravelTrackManager.I.activeTravelTrackId ==
                              travelTrack.id
                          ? const Icon(Icons.radio_button_checked)
                          : const Icon(Icons.radio_button_unchecked),
                      onPressed: () {
                        TravelTrackManager.I
                            .setActiveTravelTrackId(travelTrack.id);
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  List<Widget> _buildTrksegListTiles(
    BuildContext context,
    TravelTrack travelTrack,
  ) {
    List<Widget> trksegListTile = [];
    trksegListTile.addAll(
      travelTrack.trksegs.map((trkseg) {
        return ListTile(
          leading: const Icon(Icons.timeline),
          title: Text(trkseg.config.name),
          onTap: () {
            // TODO: focus on trkseg
          },
        );
      }),
    );
    return trksegListTile;
  }
}
