import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:greenlync/utils/utils.dart';
import 'package:greenlync/widget/circular_menu_widget.dart';
import 'package:shimmer/shimmer.dart';

import 'models/data_response_model.dart';

void main() {
  runApp(const CircularMenuApp());
}

class CircularMenuApp extends StatefulWidget {
  const CircularMenuApp({Key? key}) : super(key: key);

  @override
  State<CircularMenuApp> createState() => _CircularMenuState();
}

class _CircularMenuState extends State<CircularMenuApp> {
  /// GlobalKey for [CircularMenuWidgetState] is used for opening/closing circular menu when
  /// clicking on button click of bottomNavigationBar.
  final GlobalKey<CircularMenuWidgetState> fabKey = GlobalKey();

  /// Var [_selectedIndex] is for current active item from the list of bottomNavigationBar items.
  /// You can change the default value by changing [_selectedIndex].
  /// By default, 0 value is selected.
  int _selectedIndex = 0;

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
    print("The data is now changed ===> ${dataResponseModel.data!.length}");
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        dataResponseModel = dataResponseModelFromJson(json.encode(Utils.HomePageData));
        print("The data is now changed ===> ${dataResponseModel.data!.length}");
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Stack(
          children: [
            _selectedIndex == 0
                ? _homepageList()
                : Center(
                    child: Text('Index $_selectedIndex'),
                  ),
            _circularMenuWidget(),
          ],
        ),
        bottomNavigationBar: _bottomNavigationMenu(),
      ),
    );
  }

  Widget buildEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade400,
      highlightColor: Colors.grey.shade200,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: Container(
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _homepageList() {
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

        return _singleItemWithoutComments(dataResponseModel.data![index].postDetails!);
      },
    );
  }

  Widget _singleItemWithComments(HomePageFeedsData homePageData) {
    return _baseContainer([
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const CircleAvatar(radius: 12, backgroundImage: NetworkImage('https://images.freeimages.com/images/large-previews/25d/eagle-1523807.jpg')),
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
            const VerticalDivider(color: Colors.grey, thickness: 3, width: 8.0,indent: 10,endIndent: 10,),
            Expanded(child: _singleItemWithoutComments(homePageData.postDetails!)),
          ],
        ),
      ),
    ]);
  }

  Widget _singleItemWithoutComments(PostDetails postDetails) {
    return _baseContainer([
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const CircleAvatar(radius: 12, backgroundImage: NetworkImage('https://images.freeimages.com/images/large-previews/443/horse-1393073.jpg')),
          const SizedBox(width: 8.0),
          Text(postDetails.postAuthorName),
        ],
      ),
      const SizedBox(height: 8.0),
      Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [BoxShadow(offset: const Offset(0, 2), blurRadius: 3, color: Colors.black.withOpacity(0.23))]),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                child: Image.network(
                  'https://images.freeimages.com/images/large-previews/5c6/sunset-jungle-1383333.jpg',
                  width: 200,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(postDetails.postDescription, maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8.0),
                    Text(postDetails.postedBefore, style: const TextStyle(color: Colors.grey, fontSize: 10)),
                    const SizedBox(height: 16.0),
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
                ),
              )
            ],
          )),
    ]);
  }

  Widget _baseContainer(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  /// Widget function which gives the ui for circular menu
  /// This is the main widget which needs to be added in order to make the circular menu possible.
  /// [fabKey] variable is a compulsory field as it is responsible for open/close of the circular menu.
  /// [children] takes in the list of [widget] which suggests the items used in the menu.
  ///
  /// From the [children], on removing the items will reduce the item in the circular menu. Currently
  /// 5 items are placed.
  Widget _circularMenuWidget() {
    return Builder(
      builder: (context) => CircularMenuWidget(
        key: fabKey,
        children: <Widget>[
          ActionButton(
            onPressed: () => _showSnackBar(context, "Event"),
            icon: const Icon(Icons.event),
            label: 'Event',
          ),
          ActionButton(
            onPressed: () => _showSnackBar(context, "Home"),
            icon: const Icon(Icons.home),
            label: 'Home',
          ),
          ActionButton(
            onPressed: () => _showSnackBar(context, "Photo"),
            icon: const Icon(Icons.photo),
            label: 'Photo',
          ),
          ActionButton(
            onPressed: () => _showSnackBar(context, "Trending"),
            icon: const Icon(Icons.trending_up),
            label: 'Trending',
          ),
          ActionButton(
            onPressed: () => _showSnackBar(context, "Message"),
            icon: const Icon(Icons.message),
            label: 'Message',
          ),
        ],
      ),
    );
  }

  /// Widget function which gives the ui for the bottom navigation item.
  Widget _bottomNavigationMenu() {
    return BottomNavigationBar(
      unselectedItemColor: Colors.black,
      items: <BottomNavigationBarItem>[
        const BottomNavigationBarItem(
          icon: Icon(Icons.feed),
          label: 'Feed',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: 'Cart',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Search',
        ),
        BottomNavigationBarItem(
          icon: Icon(_selectedIndex == 3
              ? fabKey.currentState?.isOpen == true
                  ? Icons.close
                  : Icons.add
              : Icons.add),
          label: 'More',
        ),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.green,
      onTap: _onItemTapped,
    );
  }

  /// This function will set the index to [_selectedIndex] for the item that we click on any item from the
  /// bottomNavigationBar items.
  /// If clicked on item with index == 3 it will toggele the circular menu.
  void _onItemTapped(int index) {
    if (index == 3) {
      if (fabKey.currentState!.isOpen) {
        fabKey.currentState!.close();
      } else {
        fabKey.currentState!.open();
      }
    } else {
      fabKey.currentState!.close();
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  /// This function displays snackBar on click of circular menu item click.
  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(milliseconds: 1000),
    ));
  }
}

/// Created custom ActionButton class for display single circular menu item with the help of [icon] and [label].
@immutable
class ActionButton extends StatelessWidget {
  const ActionButton({
    Key? key,
    this.onPressed,
    required this.icon,
    required this.label,
  }) : super(key: key);

  final VoidCallback? onPressed;
  final Widget icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.all(4.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Colors.green,
          ),
          child: IconTheme.merge(
            data: theme.primaryIconTheme,
            child: IconButton(
              onPressed: onPressed,
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              icon: icon,
            ),
          ),
        ),
        const SizedBox(
          height: 5.0,
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white),
        )
      ],
    );
  }
}
