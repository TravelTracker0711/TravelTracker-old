class TravelTrackListViewOptions {
  final String title;
  late Map<String, bool> isTravelTrackExpandedMap;

  TravelTrackListViewOptions({
    required this.title,
    Map<String, bool>? isTravelTrackExpandedMap,
  }) {
    this.isTravelTrackExpandedMap =
        isTravelTrackExpandedMap ?? <String, bool>{};
  }
}
