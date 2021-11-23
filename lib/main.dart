
import 'package:flutter/material.dart';
import 'package:greenlync/widget/circular_menu_widget.dart';

void main() {
  runApp(const CircularMenuApp());
}

class CircularMenuApp extends StatefulWidget {
  const CircularMenuApp({Key? key}) : super(key: key);

  @override
  State<CircularMenuApp> createState() => _CircularMenuState();
}

class _CircularMenuState extends State<CircularMenuApp> {
  /// GlobalKey for [CircularMenuWidgetState] is used for opening/closing circular menu when clicking on button click of bottomNavigationBar.
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
            Builder(
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
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
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
            _singleBottomNavigationItem(),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.green,
          onTap: _onItemTapped,
        ),
      ),
    );
  }

  /// Click on this item, the circular menu will open and [Icons.add] will change to [Icons.close] icon on bottomNavigationBar else otherwise.
  /// By default, [Icons.add] will be shown when not selected
  BottomNavigationBarItem _singleBottomNavigationItem(){
    return BottomNavigationBarItem(
      icon: Icon(_selectedIndex == 3
          ? fabKey.currentState?.isOpen == true
          ? Icons.close
          : Icons.add
          : Icons.add),
      label: 'More',
    );
  }

  /// This function will set the index to [_selectedIndex] for the item that we click on any item from the bottomNavigationBar items.
  /// If we click on item[index == 3] it will open the [CircularMenuWidgetState] class.
  /// If it is open then close the [CircularMenuWidgetState] class.
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
