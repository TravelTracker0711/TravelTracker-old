import 'dart:io';
import 'package:gpx/gpx.dart';
import 'package:path/path.dart';
import 'package:travel_tracker/features/travel_track/trkseg_ext.dart';
import 'package:uuid/uuid.dart';

class GpxExt {
  late final String id;
  late final Gpx? gpx;
  late final List<TrksegExt> trksegExts;
  late String name;
  late final String? fullFilePath;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'fileFullPath': fullFilePath,
      'trksegExts': trksegExts.map((e) => e.toJson()).toList(),
    };
  }

  // GpxExt.fromJson(Map<String, dynamic> json) {
  //   id = json['id'];
  //   name = json['name'];
  //   fullFilePath = json['fileFullPath'];
  //   trksegExts = (json['trksegExts'] as List)
  //       .map((e) => TrksegExt.fromJson(e))
  //       .toList()
  //       .cast<TrksegExt>();
  //   gpx = null;
  // }

  String? get dirName {
    if (fullFilePath == null) {
      return null;
    }
    return dirname(fullFilePath!);
  }

  String? get fileName {
    if (fullFilePath == null) {
      return null;
    }
    return basename(fullFilePath!);
  }

  String? get fileBaseName {
    if (fullFilePath == null) {
      return null;
    }
    return basenameWithoutExtension(fullFilePath!);
  }

  String? get fileExtension {
    if (fullFilePath == null) {
      return null;
    }
    return extension(fullFilePath!);
  }

  GpxExt._({
    required this.gpx,
    this.fullFilePath,
    String? name,
  }) {
    id = const Uuid().v4();
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
      fullFilePath: filePath,
      name: name,
    );
  }
}
