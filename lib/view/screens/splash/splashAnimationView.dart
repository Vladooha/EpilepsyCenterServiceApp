import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SplashAnimationView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SplashAnimationViewState();
}

class SplashAnimationViewState extends State<SplashAnimationView> with SingleTickerProviderStateMixin {
  static const MIN_MULTIPLIER = 0.5;
  static const MAX_MULTIPLIER = 1.0;

  static const ANIMATION_TIME_MS = 2000;

  AnimationController _animationController;
  Animation _growAnimation;

  @override
  void initState() {
    super.initState();

    _prepareAnimation();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[50],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Image(
            width: 256 * _growAnimation.value,
            height: 107 * _growAnimation.value,
            filterQuality: FilterQuality.high,
            image: AssetImage('assets/image/logo.png')
          ),
        ]
      )
    );
  }

  _prepareAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(
          milliseconds: ANIMATION_TIME_MS
      ),
    );

    _growAnimation = Tween<double>(
        begin: MAX_MULTIPLIER,
        end: MIN_MULTIPLIER
    )
    .animate(_animationController)
    ..addStatusListener((status) {
       if (status == AnimationStatus.completed) {
         _animationController.reverse();
       } else if (status == AnimationStatus.dismissed) {
         _animationController.forward();
       }
     });

    _animationController.addListener(() {
      setState(() {});
    });

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();

    super.dispose();
  }
}