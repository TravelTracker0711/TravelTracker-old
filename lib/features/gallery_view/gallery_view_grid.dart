import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:travel_tracker/features/gallery_view/gallery_view_photo.dart';
import 'package:travel_tracker/features/gallery_view/gallery_view_controller.dart';
import 'package:travel_tracker/features/travel_track/asset_ext.dart';

class GalleryViewGrid extends StatefulWidget {
  const GalleryViewGrid({
    super.key,
    required this.controller,
    required this.assetExts,
  });

  final GalleryViewController controller;
  final List<AssetExt>? assetExts;

  @override
  State<GalleryViewGrid> createState() => _GalleryViewGridState();
}

class _GalleryViewGridState extends State<GalleryViewGrid> {
  @override
  Widget build(BuildContext context) {
    if (widget.assetExts == null) {
      return const Center(child: Text('Nothing to show'));
    }
    return _buildGridView(widget.assetExts!);
  }

  Widget _buildGridView(List<AssetExt> assetExts) {
    return Scrollbar(
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 3.0,
          crossAxisSpacing: 3.0,
        ),
        padding: const EdgeInsets.all(10.0),
        itemCount: assetExts.length,
        itemBuilder: (BuildContext context, int index) {
          AssetExt assetExt = assetExts[index];
          return _buildAssetThumbnail(assetExt, index);
        },
      ),
    );
  }

  Widget _buildAssetThumbnail(AssetExt assetExt, int index) {
    return Card(
      margin: const EdgeInsets.all(0),
      child: InkWell(
        onTap: () => _onTapAsset(assetExt, index),
        child: (assetExt.type != AssetExtType.image &&
                assetExt.type != AssetExtType.video)
            ? Text(
                '${assetExt.filePath}',
              )
            : Ink.image(
                image: AssetEntityImageProvider(
                  assetExt.asset,
                  isOriginal: false,
                ),
                fit: BoxFit.cover,
              ),
      ),
    );
  }

  void _onTapAsset(AssetExt assetExt, int index) {
    // navigate to gallery photo view page
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(),
          body: widget.assetExts == null
              ? const Center(child: Text('Nothing to show'))
              : GalleryViewPhoto(
                  assetExts: widget.assetExts!,
                  initialIndex: index,
                  thumbnailHeight: 64.0,
                  thumbnailWidth: 48.0,
                ),
        ),
      ),
    );
  }
}
