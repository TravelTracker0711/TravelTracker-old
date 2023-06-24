import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart' hide AssetType;
import 'package:travel_tracker/features/gallery_view/gallery_view_photo.dart';
import 'package:travel_tracker/features/gallery_view/gallery_view_controller.dart';
import 'package:travel_tracker/features/asset/data_model/asset.dart';

class GalleryViewGrid extends StatefulWidget {
  const GalleryViewGrid({
    super.key,
    required this.controller,
    required this.assets,
  });

  final GalleryViewController controller;
  final List<Asset>? assets;

  @override
  State<GalleryViewGrid> createState() => _GalleryViewGridState();
}

class _GalleryViewGridState extends State<GalleryViewGrid> {
  @override
  Widget build(BuildContext context) {
    if (widget.assets == null) {
      return const Center(child: Text('Nothing to show'));
    }
    return _buildGridView(widget.assets!);
  }

  Widget _buildGridView(List<Asset> assets) {
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
          Asset asset = assets[index];
          return _buildAssetThumbnail(asset, index);
        },
      ),
    );
  }

  Widget _buildAssetThumbnail(Asset asset, int index) {
    return Card(
      margin: const EdgeInsets.all(0),
      child: InkWell(
        onTap: () => _onTapAsset(asset, index),
        child: (asset.type != AssetType.image && asset.type != AssetType.video)
            ? Text(
                '${asset.fileFullPath}',
              )
            : Ink.image(
                image: AssetEntityImageProvider(
                  asset.assetEntity,
                  isOriginal: false,
                ),
                fit: BoxFit.cover,
              ),
      ),
    );
  }

  void _onTapAsset(Asset asset, int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(),
          body: widget.assets == null
              ? const Center(child: Text('Nothing to show'))
              : GalleryViewPhoto(
                  assets: widget.assets!,
                  initialIndex: index,
                  thumbnailHeight: 64.0,
                  thumbnailWidth: 48.0,
                ),
        ),
      ),
    );
  }
}
