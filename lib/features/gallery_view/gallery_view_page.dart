import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:travel_tracker/features/external_asset/external_asset_manager.dart';

class GalleryViewPage extends StatefulWidget {
  const GalleryViewPage({super.key});

  @override
  State<GalleryViewPage> createState() => _GalleryViewPageState();
}

class _GalleryViewPageState extends State<GalleryViewPage> {
  late Future<List<AssetEntity>?> futureAssets;

  @override
  void initState() {
    super.initState();
    Future<ExternalAssetManager> feam = ExternalAssetManager.FI;
    futureAssets = feam.then((eam) => eam.getAssetsFilteredByTime(
          // minDate: DateTime(2023, 5, 1),
          isTimeAsc: false,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: futureAssets,
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
          return _buildAssetThumbnail(asset);
        },
      ),
    );
  }

  Widget _buildAssetThumbnail(AssetEntity asset) {
    return Card(
      margin: const EdgeInsets.all(0),
      child: InkWell(
        onTap: () => _onTapAsset(asset),
        child: (asset.type != AssetType.image && asset.type != AssetType.video)
            ? Text(
                '${asset.relativePath}${asset.title!}',
              )
            : Ink.image(
                image: AssetEntityImageProvider(
                  asset,
                  isOriginal: false,
                ),
                fit: BoxFit.cover,
              ),
      ),
    );
  }

  void _onTapAsset(AssetEntity asset) async {
    debugPrint('${asset.relativePath}${asset.title}');
  }
}
