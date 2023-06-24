import 'dart:async';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_view/photo_view.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:travel_tracker/features/asset/data_model/asset_ext.dart';

class GalleryViewPhoto extends StatefulWidget {
  const GalleryViewPhoto({
    super.key,
    required this.assetExts,
    this.thumbnailHeight = 48.0,
    this.thumbnailWidth = 48.0,
    this.initialIndex = 0,
  });

  final List<AssetExt> assetExts;
  final double thumbnailHeight;
  final double thumbnailWidth;
  final int initialIndex;

  @override
  State<GalleryViewPhoto> createState() => _GalleryViewPhotoState();
}

// TODO: refactor, too much code
class _GalleryViewPhotoState extends State<GalleryViewPhoto> {
  late final ItemScrollController _thumbnailItemScrollController;
  late double _thumbnailViewPortSize;
  late final PageController _imagePageController;
  bool _isPhotoScaled = false;
  late int _currentIndex;

  @override
  void initState() {
    _currentIndex = widget.initialIndex;
    _thumbnailItemScrollController = ItemScrollController();
    _imagePageController = PageController(
      initialPage: widget.initialIndex,
      viewportFraction: 1.05,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Column(
        children: [
          _buildImagePageView(),
          _buildThumbnialScrollBar(),
        ],
      ),
    );
  }

  Widget _buildImagePageView() {
    return Expanded(
      child: PageView.builder(
        controller: _imagePageController,
        physics: _isPhotoScaled ? NeverScrollableScrollPhysics() : null,
        onPageChanged: _onImagePageChanged,
        allowImplicitScrolling: true,
        itemCount: widget.assetExts.length,
        itemBuilder: (context, index) {
          // background color black
          return FractionallySizedBox(
            widthFactor: 1 / _imagePageController.viewportFraction,
            child: PhotoView(
              imageProvider:
                  AssetEntityImageProvider(widget.assetExts[index].assetEntity),
              minScale: PhotoViewComputedScale.contained,
              scaleStateChangedCallback: (state) {
                setState(() {
                  _isPhotoScaled = state != PhotoViewScaleState.initial;
                });
              },
            ),
          );
        },
      ),
    );
  }

  void _onImagePageChanged(int index) {
    setState(() {
      _currentIndex = index;
      _thumbnailItemScrollController.scrollTo(
        index: index,
        alignment: _getAlignment(
          itemSize: widget.thumbnailWidth,
          viewPortSize: _thumbnailViewPortSize,
        ),
        duration: const Duration(milliseconds: 200),
        curve: Curves.ease,
      );
    });
  }

  Widget _buildThumbnialScrollBar() {
    return Container(
      height: widget.thumbnailHeight,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: LayoutBuilder(builder: (context, constraints) {
        _thumbnailViewPortSize = constraints.maxWidth;
        return ScrollablePositionedList.builder(
          itemScrollController: _thumbnailItemScrollController,
          initialScrollIndex: widget.initialIndex,
          initialAlignment: _getAlignment(
            itemSize: widget.thumbnailWidth,
            viewPortSize: _thumbnailViewPortSize,
          ),
          scrollDirection: Axis.horizontal,
          minCacheExtent: _thumbnailViewPortSize * 2,
          itemCount: widget.assetExts.length,
          itemBuilder: (context, index) {
            double heigetFactor = 0.8;
            if (index == _currentIndex) {
              heigetFactor = 1.0;
            }
            return FractionallySizedBox(
              heightFactor: heigetFactor,
              child: GestureDetector(
                onTap: () {
                  _onThumbnialTapped(index);
                },
                child: Container(
                  width: widget.thumbnailWidth,
                  margin: const EdgeInsets.symmetric(horizontal: 2.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    image: DecorationImage(
                      image: AssetEntityImageProvider(
                        widget.assetExts[index].assetEntity,
                        isOriginal: false,
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  double _getAlignment({
    required double itemSize,
    required double viewPortSize,

    ///percentage of the item
    double alignmentOnItem = 0.5,
  }) {
    assert(alignmentOnItem >= 0 && alignmentOnItem <= 1,
        "Alignment on item is expected to be within 0 and 1");
    final relativePageSize = 1 / viewPortSize * itemSize;
    return 0.5 - relativePageSize * alignmentOnItem;
  }

  void _onThumbnialTapped(int index) {
    setState(() {
      _currentIndex = index;
      _imagePageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 200),
        curve: Curves.ease,
      );
      _isPhotoScaled = false;
    });
  }
}

typedef void OnPageChange(int index);

class ScrollGallery extends StatefulWidget {
  final double height;
  final double thumbnailSize;
  final List<ImageProvider> imageProviders;
  final BoxFit fit;
  final Duration? interval;
  final Color borderColor;
  final Color backgroundColor;
  final bool zoomable;
  final int initialIndex;
  final OnPageChange? onPageChange;

  ScrollGallery(
    this.imageProviders, {
    this.height = double.infinity,
    this.thumbnailSize = 48.0,
    this.borderColor = Colors.red,
    this.backgroundColor = Colors.black,
    this.zoomable = true,
    this.fit = BoxFit.contain,
    this.interval,
    this.initialIndex = 0,
    this.onPageChange,
  });

  @override
  _ScrollGalleryState createState() => _ScrollGalleryState();
}

class _ScrollGalleryState extends State<ScrollGallery>
    with SingleTickerProviderStateMixin {
  late final ScrollController _scrollController;
  late final PageController _pageController;
  late final Timer? _timer;
  int _currentIndex = 0;
  bool _reverse = false;
  bool _lock = false;

  @override
  void initState() {
    _scrollController = new ScrollController();
    _pageController = new PageController(initialPage: widget.initialIndex);
    _currentIndex = widget.initialIndex;
    final interval = widget.interval;
    if (interval != null && widget.imageProviders.length > 1) {
      _timer = new Timer.periodic(interval, (_) {
        if (_lock) {
          return;
        }

        if (_currentIndex == widget.imageProviders.length - 1) {
          _reverse = true;
        }
        if (_currentIndex == 0) {
          _reverse = false;
        }

        if (_reverse) {
          _pageController.previousPage(
            duration: const Duration(milliseconds: 500),
            curve: Curves.ease,
          );
        } else {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 500),
            curve: Curves.ease,
          );
        }
      });
    }

    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    widget.onPageChange?.call(index);
    setState(() {
      _currentIndex = index;
      double itemSize = widget.thumbnailSize + 8.0;
      _scrollController.animateTo(
        itemSize * index / 2,
        duration: const Duration(milliseconds: 200),
        curve: Curves.ease,
      );
    });
  }

  Widget _zoomableImage(image) {
    return new PhotoView(
      backgroundDecoration: BoxDecoration(color: widget.backgroundColor),
      imageProvider: image,
      minScale: PhotoViewComputedScale.contained,
      scaleStateChangedCallback: (PhotoViewScaleState state) {
        setState(() {
          _lock = state != PhotoViewScaleState.initial;
        });
      },
    );
  }

  Widget _notZoomableImage(image) {
    return new Image(image: image, fit: widget.fit);
  }

  Widget _buildImagePageView() {
    return Expanded(
      child: PageView(
        physics: _lock ? NeverScrollableScrollPhysics() : null,
        onPageChanged: _onPageChanged,
        controller: _pageController,
        children: widget.imageProviders.map((image) {
          return (widget.zoomable
              ? _zoomableImage(image)
              : _notZoomableImage(image));
        }).toList(),
      ),
    );
  }

  void _selectImage(int index) {
    setState(() {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 500),
        curve: Curves.ease,
      );
      _lock = false;
    });
  }

  Widget _buildImageThumbnail() {
    return Container(
      height: widget.thumbnailSize,
      child: ListView.builder(
        controller: _scrollController,
        itemCount: widget.imageProviders.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int index) {
          var decoration = new BoxDecoration(color: Colors.white);

          if (_currentIndex == index) {
            decoration = new BoxDecoration(
              border: new Border.all(
                color: widget.borderColor,
                width: 2.0,
              ),
              color: Colors.white,
            );
          }

          return new GestureDetector(
            onTap: () {
              _selectImage(index);
            },
            child: new Container(
              decoration: decoration,
              margin: const EdgeInsets.only(left: 8.0),
              child: new Image(
                image: widget.imageProviders[index],
                fit: widget.fit,
                width: widget.thumbnailSize,
                height: widget.thumbnailSize,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      color: widget.backgroundColor,
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          _buildImagePageView(),
          new SizedBox(height: 8.0),
          _buildImageThumbnail(),
          new SizedBox(height: 8.0)
        ],
      ),
    );
  }
}
