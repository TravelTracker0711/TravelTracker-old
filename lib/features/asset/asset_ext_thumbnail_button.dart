import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:travel_tracker/features/asset/data_model/asset_ext.dart';

class AssetExtThumbnailButton extends StatelessWidget {
  const AssetExtThumbnailButton({
    super.key,
    this.displayedAssetExt,
    this.onTap,
    this.assetCount,
  });

  final AssetExt? displayedAssetExt;
  final int? assetCount;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 1 / 1,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.white,
              width: 2,
            ),
            image: displayedAssetExt == null
                ? null
                : DecorationImage(
                    image: AssetEntityImageProvider(
                      displayedAssetExt!.assetEntity,
                      isOriginal: false,
                    ),
                    fit: BoxFit.cover,
                  ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            child: assetCount != null && assetCount! > 1
                ? Stack(
                    children: <Widget>[
                      displayedAssetExt == null
                          ? const Icon(
                              Icons.photo,
                              color: Colors.white,
                            )
                          : Container(),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.black.withOpacity(
                              displayedAssetExt == null ? 0.5 : 0.3),
                        ),
                      ),
                      Center(
                        child: Text(
                          assetCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  )
                : displayedAssetExt == null
                    ? Stack(
                        children: <Widget>[
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.black.withOpacity(0.5),
                            ),
                          ),
                          const Center(
                            child: Icon(
                              Icons.photo,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )
                    : Container(),
          ),
        ),
      ),
    );
  }
}
