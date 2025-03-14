import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:muslim_schedule/features/dashboard/presentation/pages/navigation.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    startTime();
  }

  startTime() {
    final duration = const Duration(seconds: 3);
    return Timer(duration, route);
  }

  void route() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: Duration(seconds: 1), // Smooth transition duration
        pageBuilder: (context, animation, secondaryAnimation) => Navigation(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white, body: content());
  }

  Widget content() {
    return Center(
      child: Transform.scale(
        scale: 4.0,
        child: Container(
          child: Lottie.asset(
            'assets/lottie/animation_splash.json',
            width: 50,
            height: 50,
          ),
        ),
      ),
    );
  }
}
