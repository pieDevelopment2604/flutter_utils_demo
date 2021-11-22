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
  final GlobalKey<CircularMenuWidgetState> fabKey = GlobalKey();
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

  BottomNavigationBarItem _singleBottomNavigationItem(){
    print("The fab value ---> ${fabKey.currentState?.isOpen}");
    return BottomNavigationBarItem(
      icon: Icon(_selectedIndex == 3
          ? fabKey.currentState?.isOpen == true
          ? Icons.close
          : Icons.add
          : Icons.add),
      label: 'More',
    );
  }

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

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(milliseconds: 1000),
    ));
  }
}

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
