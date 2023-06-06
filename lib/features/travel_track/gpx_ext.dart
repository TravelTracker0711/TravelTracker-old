import 'dart:io';
import 'package:gpx/gpx.dart';
import 'package:travel_tracker/features/travel_track/trkseg_ext.dart';

class GpxExt {
  final Gpx gpx;
  late final List<TrksegExt> trksegExts;
  final String? filePath;

  GpxExt._({
    required this.gpx,
    this.filePath,
  }) {
    trksegExts = TrksegExt.fromGpxExt(
      gpxExt: this,
    );
  }

  static Future<GpxExt> fromFilePathAsync(String filePath) async {
    return File(filePath).readAsString().then((String content) {
      return GpxExt.fromString(content);
    });
  }

  factory GpxExt.fromString(String gpxString) {
    return GpxExt._(
      gpx: GpxReader().fromString(gpxString),
    );
  }

  factory GpxExt.fromGpx(Gpx gpx) {
    return GpxExt._(
      gpx: gpx,
    );
  }
}
