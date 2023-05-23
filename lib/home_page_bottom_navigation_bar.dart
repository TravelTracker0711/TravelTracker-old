import 'package:flutter/material.dart';

class HomePageBottomNavigationBar extends StatefulWidget {
  const HomePageBottomNavigationBar({Key? key, required this.onTap})
      : super(key: key);

  final ValueChanged<int> onTap;

  @override
  State<HomePageBottomNavigationBar> createState() =>
      _HomePageBottomNavigationBarState();
}

class _HomePageBottomNavigationBarState
    extends State<HomePageBottomNavigationBar> {
  int _selectedPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _selectedPageIndex,
      type: BottomNavigationBarType.fixed,
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
      onTap: (int index) {
        setState(() {
          _selectedPageIndex = index;
        });
        widget.onTap(index);
      },
    );
  }
}
