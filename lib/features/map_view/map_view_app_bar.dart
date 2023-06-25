import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:travel_tracker/features/map_view/map_view_controller.dart';
import 'package:travel_tracker/features/permission/permission_manager.dart';
import 'package:travel_tracker/models/travel_config/travel_config.dart';
import 'package:travel_tracker/models/travel_track/travel_track.dart';
import 'package:travel_tracker/features/travel_track/travel_track_file_handler.dart';
import 'package:travel_tracker/features/travel_track/travel_track_manager/travel_track_manager.dart';

enum PopupAction { test1, addGpxFile }

// TODO refactor
class MapViewAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MapViewAppBar({
    super.key,
    required this.title,
    required this.controller,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  final String title;
  final MapViewController controller;

  @override
  Widget build(BuildContext context) {
    const PreferredSizeWidget appBarBottom = PreferredSize(
      preferredSize: Size.fromHeight(50),
      child: LinearProgressIndicator(
        value: 0.5,
        backgroundColor: Colors.white,
        color: Colors.blue,
      ),
    );

    return AppBar(
      title: Text(title),
      // bottom: appBarBottom,
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            _addGpxFileAsync(context);
          },
        ),
        // PopupMenuButton<PopupAction>(
        //   onSelected: (PopupAction result) async {
        //     switch (result) {
        //       case PopupAction.test1:
        //         TravelTrackFileHandler travelTrackFileHandler =
        //             TravelTrackFileHandler();
        //         await travelTrackFileHandler.test();
        //         break;
        //       case PopupAction.addGpxFile:
        //         _addGpxFileAsync(context);
        //         break;
        //     }
        //   },
        //   itemBuilder: (BuildContext context) => <PopupMenuEntry<PopupAction>>[
        //     const PopupMenuItem<PopupAction>(
        //       value: PopupAction.test1,
        //       child: Text('test1'),
        //     ),
        //     const PopupMenuItem<PopupAction>(
        //       value: PopupAction.addGpxFile,
        //       child: Text('add GPX file'),
        //     ),
        //   ],
        // )
      ],
    );
  }

  // PhotoGallery won't actively ask for permission
  // but if permission is granted, it will provide correct result
  // keep it for future use
  // void _testGetAlbums() async {
  //   var status = await Permission.storage.status;
  //   if (status.isDenied) {
  //     status = await Permission.storage.request();
  //   }
  //   List<Album> imageAlbums = await PhotoGallery.listAlbums(
  //     mediumType: MediumType.image,
  //   );
  //   for (var album in imageAlbums) {
  //     debugPrint(album.name);
  //   }
  //   debugPrint(imageAlbums.toString());
  // }

  Future<void> _addGpxFileAsync(BuildContext context) async {
    PermissionManager.requestAsync(Permission.storage);
    FilePicker.platform.pickFiles(type: FileType.any).then(
      (result) {
        if (result != null) {
          List<String> filePaths = [];
          for (var path in result.paths) {
            if (path != null) {
              filePaths.add(path);
            }
          }
          TravelTrackFactory.fromGpxFileFullPathsAsync(
            config: TravelConfig(namePlaceholder: 'New Travel Track'),
            gpxFileFullPaths: filePaths,
            autoAttachAssets: true,
          ).then((travelTrack) {
            context.read<TravelTrackManager>()
              ..addTravelTrackAsync(travelTrack)
              ..setActiveTravelTrackId(travelTrack.config.id);
          });
        }
      },
    );
  }
}
