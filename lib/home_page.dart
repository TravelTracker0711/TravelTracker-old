import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_tracker/features/views/gallery_view/gallery_view_page.dart';
import 'package:travel_tracker/features/gpx/gpx_model.dart';
import 'package:travel_tracker/features/views/map_view/map_view_app_bar.dart';
import 'package:travel_tracker/features/views/map_view/map_view_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedPageIndex = 0;

  final List<Widget> _bodyPages = <Widget>[
    const MapViewPage(),
    const GalleryViewPage(),
  ];

  @override
  Widget build(context) {
    return ChangeNotifierProvider(
      create: (context) => GpxModel(),
      child: Scaffold(
        appBar: MapViewAppBar(title: widget.title),
        body: Center(child: _bodyPages.elementAt(_selectedPageIndex)),
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.map),
              label: 'Track',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.photo_library),
              label: 'Data',
            ),
          ],
          currentIndex: _selectedPageIndex,
          onTap: (int index) {
            setState(() {
              _selectedPageIndex = index;
            });
          },
        ),
      ),
    );
  }
}
