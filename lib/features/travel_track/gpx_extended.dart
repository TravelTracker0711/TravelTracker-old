import 'package:gpx/gpx.dart';
import 'package:travel_tracker/features/travel_track/trkseg_extended.dart';

// TODO: GpxExtended
class GpxExtended {
  final Gpx gpx;
  late final List<TrksegExtended> trksegs;
  final String? filePath;

  GpxExtended._({
    required this.gpx,
    this.filePath,
  }) {
    trksegs = TrksegExtended.fromGpxExtended(
      gpxExtended: this,
    );
  }

  // TODO: read from file
  // factory GpxExtended.fromFilePath(String filePath) {
  //   return GpxExtended._(
  //     filePath: filePath,
  //   );
  // }

  // TODO: read gpx from string
  // factory GpxExtended.fromString(String gpxString) {
  //   return GpxExtended._();
  // }

  factory GpxExtended.fromGpx(Gpx gpx) {
    return GpxExtended._(
      gpx: gpx,
    );
  }
}
