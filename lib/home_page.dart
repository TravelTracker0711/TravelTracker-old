import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_tracker/features/gallery/gallery_page.dart';
import 'package:travel_tracker/features/gpx/gpx_model.dart';
import 'package:travel_tracker/features/track/track_app_bar.dart';
import 'package:travel_tracker/features/track/track_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _bodyPages = <Widget>[
    const TrackPage(),
    const GalleryPage(),
    const Text(
      'Index 2: Settings',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => GpxModel(),
      child: Scaffold(
        appBar: TrackAppBar(title: widget.title),
        body: Center(child: _bodyPages.elementAt(_selectedIndex)),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.map),
              label: 'Track',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.photo_library),
              label: 'Data',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: (int index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      ),
    );
  }
}
