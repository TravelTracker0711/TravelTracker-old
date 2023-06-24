import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart' as pm;
import 'package:travel_tracker/models/asset/asset.dart';

class AssetThumbnailButton extends StatelessWidget {
  const AssetThumbnailButton({
    super.key,
    this.displayedAsset,
    this.onTap,
    this.assetCount,
    this.circularRadius = 10,
    this.borderWidth = 2,
    this.borderColor = Colors.white,
  });

  final Asset? displayedAsset;
  final int? assetCount;
  final VoidCallback? onTap;
  final double circularRadius;
  final double borderWidth;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 1 / 1,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(circularRadius),
            border: Border.all(
              width: borderWidth,
            ),
          ),
          foregroundDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(circularRadius),
            border: Border.all(
              width: borderWidth,
              color: borderColor,
            ),
          ),
          child: _buildThumbnail(context),
        ),
      ),
    );
  }

  Widget _buildThumbnail(BuildContext context) {
    if (displayedAsset == null || !(displayedAsset!.type.hasThumbnail)) {
      return _buildIconWithCount(context);
    }
    return FutureBuilder(
      future: displayedAsset?.fetchEntityDataAsync(),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (displayedAsset?.entity != null) {
            return _buildAssetEntityWithCount(
              context,
              assetEntity: displayedAsset!.entity!,
            );
          }
          return _buildIconWithCount(context);
        }
        return _buildCircularProgressIndicator(context);
      },
    );
  }

  Widget _buildIconWithCount(BuildContext context) {
    return Stack(
      children: [
        if (!_isShowingCount()) _buildBlack(context, opacity: 0.5),
        _buildIcon(
          context,
          icon: displayedAsset?.type.icon ?? Icons.help,
        ),
        if (_isShowingCount()) ...[
          _buildBlack(context, opacity: 0.5),
          _buildText(context, text: assetCount.toString()),
        ],
      ],
    );
  }

  Widget _buildAssetEntityWithCount(
    BuildContext context, {
    required pm.AssetEntity assetEntity,
  }) {
    return Stack(
      children: [
        Image(
          image: pm.AssetEntityImageProvider(assetEntity, isOriginal: false),
          fit: BoxFit.cover,
        ),
        if (_isShowingCount()) ...[
          _buildBlack(context, opacity: 0.3),
          _buildText(context, text: assetCount.toString()),
        ],
      ],
    );
  }

  Widget _buildCircularProgressIndicator(BuildContext context) {
    return Stack(
      children: <Widget>[
        _buildBlack(context, opacity: 0.5),
        const Center(
          child: CircularProgressIndicator(),
        ),
      ],
    );
  }

  bool _isShowingCount() {
    return assetCount != null && assetCount! > 1;
  }

  Widget _buildBlack(
    BuildContext context, {
    required double opacity,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(opacity),
      ),
    );
  }

  Widget _buildIcon(
    BuildContext context, {
    required IconData icon,
  }) {
    return Icon(
      icon,
      color: Colors.white,
    );
  }

  Widget _buildText(
    BuildContext context, {
    required String text,
  }) {
    return Center(
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
        ),
      ),
    );
  }
}
