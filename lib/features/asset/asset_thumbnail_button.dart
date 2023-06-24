import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:travel_tracker/features/asset/data_model/asset.dart';

class AssetThumbnailButton extends StatelessWidget {
  const AssetThumbnailButton({
    super.key,
    this.displayedAsset,
    this.onTap,
    this.assetCount,
  });

  final Asset? displayedAsset;
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
            image: displayedAsset == null
                ? null
                : DecorationImage(
                    image: AssetEntityImageProvider(
                      displayedAsset!.assetEntity,
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
                      displayedAsset == null
                          ? const Icon(
                              Icons.photo,
                              color: Colors.white,
                            )
                          : Container(),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.black
                              .withOpacity(displayedAsset == null ? 0.5 : 0.3),
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
                : displayedAsset == null
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
