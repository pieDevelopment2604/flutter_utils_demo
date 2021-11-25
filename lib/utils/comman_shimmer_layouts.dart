import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shimmer/shimmer.dart';

class CommonShimmerLayout {
  static Widget ShimmeredListView(Widget singleChild, List<dynamic> shimmeredModelList) {
    return ListView.builder(
      itemCount: shimmeredModelList.length,
      itemBuilder: (context, index) {
        return singleChild;
      },
    );
  }

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

  static Widget ShimmeredImageView({required Widget imageWidget}){
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade400,
      highlightColor: Colors.grey.shade200,
      child: imageWidget,
    );
  }
}
