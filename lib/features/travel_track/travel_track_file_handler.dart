import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';
import 'package:travel_tracker/features/permission/permission_manager.dart';
import 'package:travel_tracker/models/travel_track/travel_track.dart';

class TravelTrackFileHandler {
  // TODO: handle ios, windows, linux
  Future<String> get _documentsPathAsync async {
    Directory? externalStorageDir = await getExternalStorageDirectory();
    // /storage/emulated/0/Android/data/com.example.travel_tracker/files
    if (externalStorageDir == null) {
      throw Exception('externalStorageDir is null');
    }
    Directory rootDir = externalStorageDir.parent.parent.parent.parent;
    Directory documentsDir =
        Directory(p.join(rootDir.path, 'Documents', 'TravelTracker'));
    documentsDir.createSync(recursive: true);
    return documentsDir.path;
  }

  Future<String> toDocumentsPathAsync(String fileName) async {
    String fileFullPath = p.join(await _documentsPathAsync, fileName);
    return fileFullPath;
  }

  Future<void> test() async {
    String documentsPath = await _documentsPathAsync;
    Directory d = Directory(p.join(documentsPath));
    d.list().forEach((element) {});
  }

  Future<void> writeAsync(TravelTrack travelTrack) async {
    await PermissionManager.requestAsync(Permission.manageExternalStorage);
    String travelTrackDirPath =
        await toDocumentsPathAsync(travelTrack.config.name);
    Directory(travelTrackDirPath).createSync(recursive: true);
    _writeTravelTrackFileAsync(
      travelTrack,
      p.join(travelTrackDirPath, 'travel_track.json'),
    );
  }

  // read all travel tracks from storage and return
  Future<Map<String, TravelTrack>> readAllAsync() async {
    String documentsPath = await _documentsPathAsync;
    Directory documentsDir = Directory(documentsPath);
    List<FileSystemEntity> travelTrackDirList = documentsDir.listSync();
    Map<String, TravelTrack> travelTrackMap = <String, TravelTrack>{};
    for (FileSystemEntity travelTrackDir in travelTrackDirList) {
      if (travelTrackDir is Directory) {
        String travelTrackJsonFilePath =
            p.join(travelTrackDir.path, 'travel_track.json');
        if (File(travelTrackJsonFilePath).existsSync()) {
          String travelTrackJson =
              File(travelTrackJsonFilePath).readAsStringSync();
          TravelTrack travelTrack =
              await TravelTrackFactory.fromJson(jsonDecode(travelTrackJson));
          travelTrackMap[travelTrack.config.id] = travelTrack;
        }
      }
    }
    return travelTrackMap;
  }

  Future<void> _writeTravelTrackFileAsync(
      TravelTrack travelTrack, String fullFilePath) async {
    String travelTrackJson = jsonEncode(travelTrack);
    File(fullFilePath).writeAsStringSync(travelTrackJson);
  }
}
