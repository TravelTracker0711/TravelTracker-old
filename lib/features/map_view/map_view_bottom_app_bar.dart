import 'package:flutter/material.dart';
import 'package:travel_tracker/features/map_view/map_view_controller.dart';
import 'package:travel_tracker/home_page_bottom_navigation_bar.dart';

class MapViewBottomAppBar extends StatefulWidget {
  const MapViewBottomAppBar({
    Key? key,
    required this.selectedPageIndex,
    required this.onPageTap,
    required this.controller,
  }) : super(key: key);

  final int selectedPageIndex;
  final ValueChanged<int> onPageTap;
  final MapViewController controller;

  @override
  State<MapViewBottomAppBar> createState() => _MapViewBottomAppBarState();
}

class _MapViewBottomAppBarState extends State<MapViewBottomAppBar> {
  double _markerPositionFraction = 0.0;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: SizedBox(
        height: 56 * 2 + 48,
        child: Column(
          children: [
            _buildBottomAppBarTop(),
            _buildSlider(),
            HomePageBottomNavigationBar(
              onPageTap: widget.onPageTap,
              selectedPageIndex: widget.selectedPageIndex,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomAppBarTop() {
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {},
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSlider() {
    return SizedBox(
      height: 48,
      child: Slider(
        value: _markerPositionFraction,
        // value: widget.controller.markerPositionFraction,
        min: 0.0,
        max: 1.0,
        label: _markerPositionFraction.toStringAsFixed(2),
        onChanged: (double value) {
          setState(() {
            _markerPositionFraction = value;
            // widget.controller.setMarkerPositionFraction(value);
          });
        },
      ),
    );
  }
}
