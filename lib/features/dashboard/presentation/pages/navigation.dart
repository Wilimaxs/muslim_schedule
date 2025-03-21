import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:muslim_schedule/features/alarm/presentation/pages/alarm_home.dart';
import 'package:muslim_schedule/features/calender/presentation/pages/calender_home.dart';
import 'package:muslim_schedule/features/dashboard/presentation/pages/home.dart';

class Navigation extends StatefulWidget {
  static const routename = 'home';
  const Navigation({super.key});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int selectedIndex = 0;

  final List<Widget> pages = [
    HomePage(),
    CalenderPage(),
    AlarmPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.1),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: pages[selectedIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
          child: GNav(
            rippleColor: Colors.green.withValues(alpha: 0.3),
            hoverColor: Colors.green.withValues(alpha: 0.2),
            tabBackgroundColor: Colors.green.shade100,
            backgroundColor: Colors.transparent,
            color: Colors.grey.shade600,
            activeColor: Colors.green.shade700,
            iconSize: 26,
            padding: const EdgeInsets.all(14),
            gap: 8,
            onTabChange: (index) {
              setState(() {
                selectedIndex = index;
              });
            },
            tabs: const [
              GButton(icon: Icons.home_rounded, text: 'Home'),
              GButton(icon: Icons.calendar_today_rounded, text: 'Calendar'),
              GButton(icon: Icons.alarm_rounded, text: 'Alarm'),
            ],
          ),
        ),
      ),
    );
  }
}
