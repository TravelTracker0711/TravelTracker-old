import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:gpx/gpx.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:travel_tracker/features/gpx/gpx_model.dart';

enum PopupAction { test1, addGpxFile }

// TODO refactor
class MapViewAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MapViewAppBar({super.key, required this.title});

  @override
  Size get preferredSize => const Size.fromHeight(56);

  final String title;

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
      bottom: appBarBottom,
      actions: <Widget>[
        PopupMenuButton<PopupAction>(
          onSelected: (PopupAction result) async {
            switch (result) {
              case PopupAction.test1:
                debugPrint('test1');
                break;
              case PopupAction.addGpxFile:
                _addGpxFile(context);
                break;
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<PopupAction>>[
            const PopupMenuItem<PopupAction>(
              value: PopupAction.test1,
              child: Text('test1'),
            ),
            const PopupMenuItem<PopupAction>(
              value: PopupAction.addGpxFile,
              child: Text('add GPX file'),
            ),
          ],
        )
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

  void _addGpxFile(BuildContext context) async {
    PermissionStatus status = await Permission.storage.request();
    if (!status.isGranted) {
      return;
    }
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );
    if (result != null) {
      File(result.files.single.path!).readAsString().then((String contents) {
        Gpx gpx = GpxReader().fromString(contents);
        context.read<GpxModel>().addGpx(gpx);
      });
    } else {
      // User canceled the picker
    }
  }
}
