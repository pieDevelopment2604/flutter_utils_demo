import 'dart:math';

import 'package:circle_list/circle_list.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as vector;

typedef DisplayChange = void Function(bool isOpen);

class CircularMenuWidget extends StatefulWidget {
  final List<Widget> children;
  final Alignment alignment;
  final double? ringDiameter;
  final double? ringWidth;
  final double fabSize;
  final Color? fabColor;
  final Color? fabOpenColor;
  final Color? fabCloseColor;
  final EdgeInsets fabMargin;
  final Duration animationDuration;
  final Curve animationCurve;
  final DisplayChange? onDisplayChange;

  const CircularMenuWidget(
      {Key? key,
      this.alignment = Alignment.bottomRight,
      this.ringDiameter,
      this.ringWidth,
      this.fabSize = 64.0,
      this.fabColor,
      this.fabOpenColor,
      this.fabCloseColor,
      this.fabMargin = const EdgeInsets.all(16.0),
      this.animationDuration = const Duration(milliseconds: 800),
      this.animationCurve = Curves.easeInOutCirc,
      this.onDisplayChange,
      required this.children})
      : assert(children.length >= 3),
        super(key: key);

  @override
  CircularMenuWidgetState createState() => CircularMenuWidgetState();
}

class CircularMenuWidgetState extends State<CircularMenuWidget> with SingleTickerProviderStateMixin {
  late double _screenWidth;
  late double _screenHeight;
  late double _marginH;
  late double _marginV;
  late double _directionX;
  late double _directionY;
  late double _translationX;
  late double _translationY;

  double? _ringDiameter;
  double? _ringWidth;
  Color? _fabColor;
  Color? _fabOpenColor;
  Color? _fabCloseColor;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation _scaleCurve;
  late Animation<double> _rotateAnimation;
  late Animation _rotateCurve;
  Animation<Color?>? _colorAnimation;
  late Animation _colorCurve;

  bool _isOpen = false;
  bool _isAnimating = false;

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

    return Container(
      color: _isOpen ? Colors.black38 : Colors.transparent,
      transform: Matrix4.translationValues(0.0, 16.0, 0.0),
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
          child: Container(
            width: _ringDiameter,
            height: _ringDiameter,
            margin: const EdgeInsets.only(bottom: 72.0, right: 18),
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
  }

  void _calculateProps() {
    _fabColor = widget.fabColor ?? Theme.of(context).primaryColor;
    _fabOpenColor = widget.fabOpenColor ?? _fabColor;
    _fabCloseColor = widget.fabCloseColor ?? _fabColor;
    _screenWidth = MediaQuery.of(context).size.width;
    _screenHeight = MediaQuery.of(context).size.height;
    _ringDiameter = widget.ringDiameter ?? min(_screenWidth, _screenHeight) * 1.25;
    _ringWidth = widget.ringWidth ?? _ringDiameter! * 0.3;
    _marginH = (widget.fabMargin.right + widget.fabMargin.left) / 2;
    _marginV = (widget.fabMargin.top + widget.fabMargin.bottom) / 2;
    _directionX = widget.alignment.x == 0 ? 1 : 1 * widget.alignment.x.sign;
    _directionY = widget.alignment.y == 0 ? 1 : 1 * widget.alignment.y.sign;
    _translationX = ((_screenWidth - widget.fabSize) / 2 - _marginH) * widget.alignment.x;
    _translationY = ((_screenHeight - widget.fabSize) / 2 - _marginV) * widget.alignment.y;

    if (_colorAnimation == null || !kReleaseMode) {
      _colorCurve = CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            0.0,
            0.4,
            curve: widget.animationCurve,
          ));
      _colorAnimation = ColorTween(begin: _fabCloseColor, end: _fabOpenColor).animate(_colorCurve as Animation<double>)
        ..addListener(() {
          setState(() {});
        });
    }
  }

  void open() {
    _isAnimating = true;
    _animationController.forward().then((_) {
      _isAnimating = false;
      _isOpen = true;
      if (widget.onDisplayChange != null) {
        widget.onDisplayChange!(true);
      }
    });
  }

  void close() {
    _isAnimating = true;
    _animationController.reverse().then((_) {
      _isAnimating = false;
      _isOpen = false;
      if (widget.onDisplayChange != null) {
        widget.onDisplayChange!(false);
      }
    });
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
