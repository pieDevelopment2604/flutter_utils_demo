import 'package:flutter/material.dart';
import 'package:flutter_demo_utils/widget/circular_menu_widget.dart';

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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Stack(
          children: [
            Center(
              child: Text('Index $_selectedIndex'),
            ),
            _circularMenuWidget(),
          ],
        ),
        bottomNavigationBar: _bottomNavigationMenu(),
      ),
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
  Widget _bottomNavigationMenu(){
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
