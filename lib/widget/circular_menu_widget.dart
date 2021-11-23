import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as vector;

class CircularMenuWidget extends StatefulWidget {
  final List<Widget> children;
  final Alignment alignment;
  final double fabSize;
  final EdgeInsets fabMargin;
  final Duration animationDuration;
  final Curve animationCurve;

  const CircularMenuWidget(
      {Key? key,
      this.alignment = Alignment.bottomRight,
      this.fabSize = 64.0,
      this.fabMargin = const EdgeInsets.all(16.0),
      this.animationDuration = const Duration(seconds: 1),
      this.animationCurve = Curves.easeInOutCirc,
      required this.children})
      : assert(children.length >= 3),
        super(key: key);

  @override
  CircularMenuWidgetState createState() => CircularMenuWidgetState();
}

class CircularMenuWidgetState extends State<CircularMenuWidget> with SingleTickerProviderStateMixin {
  late double _screenWidth;
  late double _screenHeight;
  late double _directionX;
  late double _directionY;
  late double _translationX;
  late double _translationY;

  double? _ringDiameter;
  double? _ringWidth;

  late AnimationController _animationController;
  late Animation<Offset> _slideUpAnimation;
  late Animation _slideUpCurve;
  late Animation<double> _scaleAnimation;
  late Animation _scaleCurve;
  late Animation<double> _rotateAnimation;
  late Animation _rotateCurve;

  bool _isOpen = false;

  /// [Color] variable used for the color of the background layer of circular menu
  /// To change the color of the background, changed the default value of the [backgroundLayerColor]
  /// By default, [Colors.black87] is taken.
  Color backgroundLayerColor = Colors.black87;

  @override
  void initState() {
    super.initState();
    initCircularMenuAnimations();
  }

  @override
  Widget build(BuildContext context) {
    // This makes the widget able to correctly redraw on
    // hot reload while keeping performance in production
    if (!kReleaseMode) {
      _calculateProps();
    }

    return Stack(children: <Widget>[
      _backgroundLayerWidget(),
      _circularMenuWidget()
    ]);
  }

  /// Widget function which gives the ui for the background layer of the circular menu.
  /// The background color of the widget is maintained within this widget
  /// if [_isOpen] is true, then color is shown else transparent color is taken.
  /// Color of the layer can be changed by changing the default color of [backgroundLayerColor]
  Widget _backgroundLayerWidget(){
    return SlideTransition(
      position: _slideUpAnimation,
      child: Container(
        color: _isOpen ? backgroundLayerColor : Colors.transparent,
      ),
    );
  }

  /// Widget function that enable [children] widget scale and rotate sequentially with respective animation value of [_scaleAnimation] and [_rotateAnimation].
  /// Apply transformation on each [children] widget from the list of [children] widget we have used MapEntry.
  Widget _circularMenuWidget(){
    return Container(
      transform: Matrix4.translationValues(-16.0, -56.0, 0.0),
      child: OverflowBox(
        maxWidth: _ringDiameter,
        maxHeight: _ringDiameter,
        child: Transform(
          transform: Matrix4.translationValues(
            _translationX,
            _translationY,
            0.0,
          )..scale(_scaleAnimation.value),
          alignment: FractionalOffset.center,
          child: SizedBox(
            width: _ringDiameter,
            height: _ringDiameter,
            child: _scaleAnimation.value == 1.0
                ? Transform.rotate(
                  angle: (-2 * pi) * _rotateAnimation.value * _directionX * _directionY,
                    child: Stack(
                alignment: Alignment.center,
                children: widget.children
                    .asMap()
                    .map((index, child) => MapEntry(index, _applyTransformations(child, index)))
                    .values
                    .toList(),
              ),
            )
                : Container(),
          ),
        ),
      ),
    );
  }

  /// Widget function apply transformation on list of [children] and differentiate each item and their position.
  Widget _applyTransformations(Widget child, int index) {
    double angleFix = 0.0;
    if (widget.alignment.x == 0) {
      angleFix = 45.0 * _directionY.abs();
    } else if (widget.alignment.y == 0) {
      angleFix = -45.0 * _directionX.abs();
    }

    final angle = vector.radians(90.0 / (widget.children.length - 1) * index + angleFix);

    return Transform(
      transform: Matrix4.translationValues(
          (-(_ringDiameter! / 2) * cos(angle) + (_ringWidth! / 2 * cos(angle))) * _directionX,
          (-(_ringDiameter! / 2) * sin(angle) + (_ringWidth! / 2 * sin(angle))) * _directionY,
          0.0),
      // alignment: FractionalOffset.center,
      child: Material(
        color: Colors.transparent,
        child: child,
      ),
    );
  }

  /// This function will execute three animation [_scaleAnimation], [_rotateAnimation] and [_slideUpAnimation] simultaneously with duration of widget.animationDuration.
  /// [_scaleAnimation] and [_rotateAnimation] animation apply for the circular menu and [_slideUpAnimation] animation apply for the background layer of container.
  void initCircularMenuAnimations() {
    _animationController = AnimationController(duration: widget.animationDuration, vsync: this);
    _scaleCurve =
        CurvedAnimation(parent: _animationController, curve: Interval(0.0, 0.4, curve: widget.animationCurve));
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_scaleCurve as Animation<double>)
      ..addListener(() {
        setState(() {});
      });
    _rotateCurve =
        CurvedAnimation(parent: _animationController, curve: Interval(0.4, 1.0, curve: widget.animationCurve));
    _rotateAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(_rotateCurve as Animation<double>)
      ..addListener(() {
        setState(() {});
      });

    _slideUpCurve = CurvedAnimation(parent: _animationController, curve: const Interval(0.0, 0.4));

    _slideUpAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(_slideUpCurve as Animation<double>)
      ..addListener(() {
        setState(() {});
      });
  }

  /// This function will calculate the props when there is an any change of variables
  void _calculateProps() {
    _screenWidth = MediaQuery.of(context).size.width;
    _screenHeight = MediaQuery.of(context).size.height;
    _ringDiameter = min(_screenWidth, _screenHeight) * 1.6;
    _ringWidth = _ringDiameter! * 0.25;
    _directionX = widget.alignment.x == 0 ? 1 : 1 * widget.alignment.x.sign;
    _directionY = widget.alignment.y == 0 ? 1 : 1 * widget.alignment.y.sign;
    _translationX = ((_screenWidth - widget.fabSize) / 2) * widget.alignment.x;
    _translationY = ((_screenHeight - widget.fabSize) / 2) * widget.alignment.y;
  }

  /// This function will perform all the animation with the reference of [_animationController].
  /// When execute this function [_isOpen] will be true.
  void open() {
    _isOpen = true;
    _animationController.forward();
  }

  /// This function will reverse all the animation with the reference of [_animationController].
  /// When execute this function [_isOpen] will be false.
  void close() {
    _animationController.reverse();
    _isOpen = false;
  }

  /// [isOpen] boolean var is used for identifying the animation status open/close.
  bool get isOpen => _isOpen;

  /// Group of functions which holds the maintenance of the circular menu
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _calculateProps();
  }
}
