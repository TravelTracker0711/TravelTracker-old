import 'package:flutter/material.dart';

class TimelineViewController {
  ScrollController? _scrollController;

  set scrollController(ScrollController scrollController) {
    _scrollController = scrollController;
    _scrollController!.addListener(() {
      debugPrint(_scrollController!.offset.toString());
    });
  }
}
