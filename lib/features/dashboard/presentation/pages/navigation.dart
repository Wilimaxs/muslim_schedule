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
        duration: Duration(milliseconds: 300), // Animation speed
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: pages[selectedIndex], // AnimatedSwitcher watches this widget
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.green,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
          child: GNav(
            backgroundColor: Colors.green,
            tabBackgroundColor: Colors.grey.shade400,
            gap: 8,
            padding: EdgeInsets.all(16),
            onTabChange: (index) {
              setState(() {
                selectedIndex = index;
              });
            },
            tabs: const [
              GButton(icon: Icons.home, text: 'Home'),
              GButton(icon: Icons.calendar_month, text: 'Calender'),
              GButton(icon: Icons.alarm_rounded, text: 'Alarm'),
            ],
          ),
        ),
      ),
    );
  }
}
