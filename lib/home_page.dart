import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_tracker/features/gallery_view/gallery_view_page.dart';
import 'package:travel_tracker/features/gpx/gpx_model.dart';
import 'package:travel_tracker/features/map_view/map_view_app_bar.dart';
import 'package:travel_tracker/features/map_view/map_view_page.dart';
import 'package:travel_tracker/features/calendar_view/calendar_view_page.dart';
import 'package:travel_tracker/features/stats_view/stats_view_page.dart';

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

  BottomNavigationBar _bottomNavigationBar() {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.map),
          label: 'Map',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.photo_library),
          label: 'Gallery',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month),
          label: 'Calendar',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart),
          label: 'Stats',
        ),
      ],
      currentIndex: _selectedPageIndex,
      onTap: (int index) {
        setState(() {
          _selectedPageIndex = index;
        });
      },
    );
  }

  @override
  Widget build(context) {
    return ChangeNotifierProvider(
      create: (context) => GpxModel(),
      child: Scaffold(
        appBar: _appBars.elementAt(_selectedPageIndex),
        body: Center(child: _bodyPages.elementAt(_selectedPageIndex)),
        bottomNavigationBar: _bottomNavigationBar(),
      ),
    );
  }
}
