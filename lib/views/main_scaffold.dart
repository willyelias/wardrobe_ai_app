import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'calendar/calendar_screen.dart';
import 'closet/closet_screen.dart';
import 'stylist/stylist_screen.dart';

/// Estrutura principal com Bottom Navigation Bar nas 3 abas essenciais
class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    ClosetScreen(),
    StylistScreen(),
    CalendarScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(color: AppColors.border, width: 0.6),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.square_grid_2x2),
              activeIcon: Icon(CupertinoIcons.square_grid_2x2_fill),
              label: 'Closet',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.sparkles),
              activeIcon: Icon(CupertinoIcons.sparkles),
              label: 'IA Stylist',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.calendar),
              activeIcon: Icon(CupertinoIcons.calendar_today),
              label: 'Calendário',
            ),
          ],
        ),
      ),
    );
  }
}
