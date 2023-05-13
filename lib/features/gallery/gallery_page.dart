import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:travel_tracker/features/external_asset/external_asset_manager.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  late Future<List<AssetEntity>?> assets;

  @override
  void initState() {
    super.initState();
    assets = GetIt.I
        .isReady<ExternalAssetManager>()
        .then((_) async => GetIt.I<ExternalAssetManager>().getAssets(
              // minDate: DateTime(2023, 5, 1),
              timeAsc: false,
            ));
  }

  Widget _buildGridView(List<AssetEntity> assets) {
    return Scrollbar(
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 3.0,
          crossAxisSpacing: 3.0,
        ),
        padding: const EdgeInsets.all(10.0),
        itemCount: assets.length,
        itemBuilder: (BuildContext context, int index) {
          AssetEntity asset = assets[index];
          return InkWell(
            child:
                (asset.type != AssetType.image && asset.type != AssetType.video)
                    ? Card(
                        child: Center(
                          child: Text(
                            '${asset.relativePath}${asset.title!}',
                            style: const TextStyle(
                              fontSize: 8.0,
                            ),
                          ),
                        ),
                      )
                    : Ink.image(
                        image: AssetEntityImageProvider(
                          asset,
                          isOriginal: false,
                        ),
                        fit: BoxFit.cover,
                      ),
            onTap: () async {
              debugPrint('${asset.relativePath}${asset.title}');
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // future: Future.wait([
      //   GetIt.I.isReady<ExternalAssetManager>().then(
      //         (_) async => GetIt.I<ExternalAssetManager>()
      //             .getAssets(
      //               minDate: DateTime(2023, 5, 31),
      //               timeAsc: false,
      //             )
      //             .then((value) => assets = value),
      //       ),
      // ]),
      future: assets,
      builder:
          (BuildContext context, AsyncSnapshot<List<AssetEntity>?> snapshot) {
        if (snapshot.hasData) {
          return _buildGridView(snapshot.data!);
        } else if (snapshot.connectionState == ConnectionState.done) {
          return const Center(child: Text('Nothing to show'));
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
    // return assets.isEmpty
    //     ? const Center(child: CircularProgressIndicator())
    //     : _buildGridView();
  }
}
