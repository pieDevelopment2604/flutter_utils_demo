import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:greenlync/models/data_response_model.dart';
import 'package:greenlync/utils/comman_shimmer_layouts.dart';
import 'package:greenlync/utils/utils.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  /// [DataResponseModel] is the model class for the data of the home page list item
  /// Used to show the list for the demo of the shimmer effect
  DataResponseModel dataResponseModel = DataResponseModel.initial();

  /// [bool] value which shows the status of the list loading
  /// Created to demo the shimmer effect, will toggle the flag after 10 seconds of the shimmer effect demo
  /// and fill up the list with the new data in order to show the loading of the data on the screen
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 20), () {
      setState(() {
        dataResponseModel = dataResponseModelFromJson(json.encode(Utils.HomePageData));
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return dashboardList();
  }

  /// Widget function which gives the ui for the list view of the dashboard
  /// This widget provides the list of the dashboard.
  /// Dashboard list contains the staggered grid view. Data for the dashboard comes up from
  /// the api calls and the loader will be maintained using the common list class created to show the
  /// shimmer effect.
  Widget dashboardList() {
    if (isLoading) {
      List<HomePageFeedsData> homePageDummyList = List<HomePageFeedsData>.generate(8,
          (index) => index == 2 || index == 6 ? HomePageFeedsData.initialWithComments() : HomePageFeedsData.initial());

      return CommonShimmerLayout.ShimmeredStaggeredGridView(homePageDummyList
          .map((e) => e.isAComment ? _singleItemWithComments(e) : _singleItemWithoutComments(e.postDetails!, true))
          .toList());
    }
    return StaggeredGridView.countBuilder(
      itemCount: dataResponseModel.data!.length,
      crossAxisCount: 4,
      mainAxisSpacing: 8.0,
      crossAxisSpacing: 8.0,
      staggeredTileBuilder: (index) => StaggeredTile.fit(2),
      itemBuilder: (context, index) {
        print(dataResponseModel.data![index].postDetails!.postAuthorName);
        if (dataResponseModel.data![index].isAComment) {
          return _singleItemWithComments(dataResponseModel.data![index]);
        }

        return _singleItemWithoutComments(dataResponseModel.data![index].postDetails!, true);
      },
    );
  }

  /// Widget function which gives the ui for the single item of the dashboard grid view with comments.
  /// The single item takes in the object of the [HomePageFeedsData] and sets the data in.
  /// The internal item is gives by [_singleItemWithoutComments] to maintain the code optimization
  /// where the former item will be used as a whole item without comments too.
  Widget _singleItemWithComments(HomePageFeedsData homePageData) {
    return _baseContainer([
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _singleUserProfilePic(
            height: 25,
            width: 25,
            userImage: homePageData.commenterPic,
            radius: BorderRadius.circular(15),
          ),
          const SizedBox(width: 8.0),
          Text(homePageData.postDetails!.postAuthorName),
        ],
      ),
      const SizedBox(height: 8.0),
      Text(homePageData.commentDescription, maxLines: 2, overflow: TextOverflow.ellipsis),
      const SizedBox(height: 8.0),
      Text(
        homePageData.commentedBefore,
        style: const TextStyle(color: Colors.grey, fontSize: 10),
      ),
      const SizedBox(height: 8.0),
      IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const VerticalDivider(
              color: Colors.grey,
              thickness: 3,
              width: 8.0,
              indent: 10,
              endIndent: 10,
            ),
            Expanded(child: _singleItemWithoutComments(homePageData.postDetails!, false)),
          ],
        ),
      ),
    ]);
  }

  /// Widget function which gives the ui for the single dashboard page item without comments, this will
  /// be the item which is in normal mode. [isCommentsInside] flag will provided from the root usage of widget
  /// if the flag is false, then the user actions will go out of the widget ui, otherwise it will be shown inside.
  Widget _singleItemWithoutComments(PostDetails postDetails, bool isCommentsInside) {
    return _baseContainer([
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _singleUserProfilePic(
            height: 25,
            width: 25,
            userImage: postDetails.postAuthorPic,
            radius: BorderRadius.circular(15),
          ),
          const SizedBox(width: 8.0),
          Text(postDetails.postAuthorName),
        ],
      ),
      const SizedBox(height: 8.0),
      Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0, 2),
                  blurRadius: 3,
                  color: Colors.black.withOpacity(0.23),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _singleUserProfilePic(
                  height: 120,
                  width: 200,
                  userImage: postDetails.postImage,
                  radius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(postDetails.postDescription, maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 8.0),
                      Text(postDetails.postedBefore, style: const TextStyle(color: Colors.grey, fontSize: 10)),
                      if (isCommentsInside) ...[userActionsLayout(postDetails)],
                    ],
                  ),
                )
              ],
            ),
          ),
          if (!isCommentsInside) ...[userActionsLayout(postDetails)],
        ],
      ),
    ]);
  }

  /// Widget function which gives the UI for the base container of the single items.
  Widget _baseContainer(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _singleUserProfilePic({
    required double height,
    required double width,
    required BorderRadius radius,
    required String userImage,
  }) {
    return ClipRRect(
      borderRadius: radius,
      child: Image.network(
        userImage,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return CommonShimmerLayout.ShimmeredImageView(
            imageWidget: ClipRRect(
              borderRadius: radius,
              child: Center(child: Container(width: width, height: height, color: Colors.red)),
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          return CommonShimmerLayout.ShimmeredImageView(
            imageWidget: ClipRRect(
              borderRadius: radius,
              child: Center(child: Container(width: width, height: height, color: Colors.red)),
            ),
          );
        },
      ),
    );
  }

  /// Widget function which gives the ui for the user actions layout.
  /// This widget is specially made for the code optimizations.
  Widget userActionsLayout(PostDetails postDetails) {
    return Column(
      children: [
        const SizedBox(height: 12.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Icon(Icons.share_rounded, color: Colors.grey, size: 16),
            Text('${postDetails.shareCount}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const Icon(Icons.messenger_outline_sharp, color: Colors.grey, size: 16),
            Text('${postDetails.commentsCount}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const Icon(Icons.favorite_border, color: Colors.grey, size: 16),
            Text('${postDetails.likesCount}', style: const TextStyle(fontSize: 12, color: Colors.grey))
          ],
        ),
      ],
    );
  }
}
