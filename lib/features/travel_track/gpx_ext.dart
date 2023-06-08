import 'dart:io';
import 'package:gpx/gpx.dart';
import 'package:path/path.dart';
import 'package:travel_tracker/features/travel_track/trkseg_ext.dart';

class GpxExt {
  final Gpx gpx;
  late final List<TrksegExt> trksegExts;
  late String name;
  final String? fileFullPath;

  String? get dirName {
    if (fileFullPath == null) {
      return null;
    }
    return dirname(fileFullPath!);
  }

  String? get fileName {
    if (fileFullPath == null) {
      return null;
    }
    return basename(fileFullPath!);
  }

  String? get fileBaseName {
    if (fileFullPath == null) {
      return null;
    }
    return basenameWithoutExtension(fileFullPath!);
  }

  String? get fileExtension {
    if (fileFullPath == null) {
      return null;
    }
    return extension(fileFullPath!);
  }

  GpxExt._({
    required this.gpx,
    this.fileFullPath,
    String? name,
  }) {
    this.name = name ?? fileBaseName ?? 'Unnamed Gpx';
    trksegExts = TrksegExt.fromGpxExt(
      gpxExt: this,
    );
  }

  static Future<GpxExt> fromFilePathAsync({
    required String filePath,
    String? name,
  }) async {
    File gpxFile = File(filePath);
    if (!await gpxFile.exists()) {
      throw Exception('File not found: $filePath');
    }
    String gpxString = await gpxFile.readAsString();
    return GpxExt.fromString(
      gpxString: gpxString,
      filePath: filePath,
      name: name,
    );
  }

  factory GpxExt.fromString({
    required String gpxString,
    String? filePath,
    String? name,
  }) {
    return GpxExt.fromGpx(
      gpx: GpxReader().fromString(gpxString),
      filePath: filePath,
      name: name,
    );
  }

  factory GpxExt.fromGpx({
    required Gpx gpx,
    String? filePath,
    String? name,
  }) {
    return GpxExt._(
      gpx: gpx,
      fileFullPath: filePath,
      name: name,
    );
  }
}
