class TravelTrackDrawerOptions {
  final String title;
  late Map<String, bool> travelTrackTileExpandMap;
  late Map<String, bool> gpxExtTileExpandMap;

  TravelTrackDrawerOptions({
    required this.title,
    Map<String, bool>? travelTrackTileExpandMap,
    Map<String, bool>? gpxExtTileExpandMap,
  }) {
    this.travelTrackTileExpandMap =
        travelTrackTileExpandMap ?? <String, bool>{};
    this.gpxExtTileExpandMap = gpxExtTileExpandMap ?? <String, bool>{};
  }
}
