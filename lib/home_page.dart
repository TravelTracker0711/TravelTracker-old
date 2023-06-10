import 'package:flutter/material.dart';
import 'package:travel_tracker/features/gallery_view/gallery_view_page.dart';
import 'package:travel_tracker/features/map_view/map_view_app_bar.dart';
import 'package:travel_tracker/features/map_view/map_view_controller.dart';
import 'package:travel_tracker/features/map_view/map_view_floating_action_button.dart';
import 'package:travel_tracker/features/map_view/map_view_page.dart';
import 'package:travel_tracker/features/calendar_view/calendar_view_page.dart';
import 'package:travel_tracker/features/stats_view/stats_view_page.dart';
import 'package:travel_tracker/features/travel_track/travel_track_list_view.dart';
import 'package:travel_tracker/home_page_bottom_navigation_bar.dart';

import 'features/travel_track/travel_track_list_view_options.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedPageIndex = 0;

  late final TravelTrackListViewOptions _travelTrackListViewOptions;
  late final List<Widget> _bodyPages;
  late final List<PreferredSizeWidget> _appBars;
  late final List<Widget> _floatingActionButtons;

  @override
  void initState() {
    super.initState();
    MapViewController mapViewController = MapViewController();
    _travelTrackListViewOptions = TravelTrackListViewOptions(
      title: widget.title,
    );

    // TODO: construct appropriate widgets
    _bodyPages = <Widget>[
      MapViewPage(
        controller: mapViewController,
      ),
      const GalleryViewPage(),
      const CalendarViewPage(),
      const StatsViewPage(),
    ];

    _appBars = <PreferredSizeWidget>[
      MapViewAppBar(
        title: widget.title,
        controller: mapViewController,
      ),
      AppBar(title: const Text('Gallery')),
      AppBar(title: const Text('Calendar')),
      AppBar(title: const Text('Stats')),
    ];

    _floatingActionButtons = <Widget>[
      MapViewFloatingActionButton(
        controller: mapViewController,
      ),
      const SizedBox.shrink(),
      const SizedBox.shrink(),
      const SizedBox.shrink(),
    ];
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: _appBars.elementAt(_selectedPageIndex),
      body: IndexedStack(
        index: _selectedPageIndex,
        children: _bodyPages,
      ),
      bottomNavigationBar: HomePageBottomNavigationBar(
        selectedPageIndex: _selectedPageIndex,
        onPageTap: (int index) {
          setState(() {
            _selectedPageIndex = index;
          });
        },
      ),
      drawer: Drawer(
        child: TravelTrackListView(
          options: _travelTrackListViewOptions,
        ),
      ),
      floatingActionButton:
          _floatingActionButtons.elementAt(_selectedPageIndex),
    );
  }
}
