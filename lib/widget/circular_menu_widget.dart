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
      SlideTransition(
        position: _slideUpAnimation,
        child: Container(
          color: _isOpen ? Colors.black54 : Colors.transparent,
        ),
      ),
      Container(
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
      ),
    ]);
  }

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

  void open() {
    _isOpen = true;
    _animationController.forward();
  }

  void close() {
    _animationController.reverse();
    _isOpen = false;
  }

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
