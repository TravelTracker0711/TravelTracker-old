import 'package:flutter/material.dart';
import 'package:travel_tracker/features/gallery_view/gallery_view_page.dart';
import 'package:travel_tracker/features/map_view/map_view_app_bar.dart';
import 'package:travel_tracker/features/map_view/map_view_page.dart';
import 'package:travel_tracker/features/calendar_view/calendar_view_page.dart';
import 'package:travel_tracker/features/stats_view/stats_view_page.dart';
import 'package:travel_tracker/home_page_bottom_navigation_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedPageIndex = 0;

  late final List<PreferredSizeWidget> _appBars;

  final List<Widget> _bodyPages = <Widget>[
    const MapViewPage(),
    const GalleryViewPage(),
    const CalendarViewPage(),
    const StatsViewPage(),
  ];

  @override
  void initState() {
    super.initState();
    // TODO: construct appropriate app bars
    _appBars = <PreferredSizeWidget>[
      MapViewAppBar(title: widget.title),
      const MapViewAppBar(title: 'Gallery'),
      const MapViewAppBar(title: 'Calendar'),
      const MapViewAppBar(title: 'Stats'),
    ];
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: _appBars.elementAt(_selectedPageIndex),
      body: Center(child: _bodyPages.elementAt(_selectedPageIndex)),
      bottomNavigationBar: HomePageBottomNavigationBar(
        onTap: (int index) {
          setState(() {
            _selectedPageIndex = index;
          });
        },
      ),
    );
  }
}
