import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shimmer/shimmer.dart';

/// Class which provides the static shimmered layout along with the dummy lists.
class CommonShimmerLayout {
  /// static Widget function which gives the ui for the shimmered staggered grid view.
  /// Need to pass in the list of widgets which includes the list of single
  /// items used in the shimmered grid view.
  ///
  /// This Widget will give back a widget which contains the shimmered staggered grid view along with the
  /// dummy list.
  static Widget ShimmeredStaggeredGridView(List<Widget> singleChild) {
    return StaggeredGridView.countBuilder(
      itemCount: singleChild.length,
      crossAxisCount: 4,
      mainAxisSpacing: 8.0,
      crossAxisSpacing: 8.0,
      staggeredTileBuilder: (index) => StaggeredTile.fit(2),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade400,
          highlightColor: Colors.grey.shade200,
          child: singleChild[index],
        );
      },
    );
  }

  /// static Widget function which gives the ui for the shimmered image view.
  /// Need to pass in the image widget
  ///
  /// This Widget will give back a widget which contains the shimmered image view
  static Widget ShimmeredImageView({required Widget imageWidget}){
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade400,
      highlightColor: Colors.grey.shade200,
      child: imageWidget,
    );
  }
}
