import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/note_provider.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/dashboard_screen.dart';
import 'utils/translation_helper.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NoteProvider()),
      ],
      child: const AuraApp(),
    ),
  );
}

class AuraApp extends StatelessWidget {
  const AuraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AuraNote',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const CalendarScreen(),
    const DashboardScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Allows the screens to render behind the floating bottom bar
      body: _screens[_currentIndex],
      bottomNavigationBar: _buildFloatingBottomBar(),
    );
  }

  // A custom, premium floating glassmorphic bottom navigation bar
  Widget _buildFloatingBottomBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            height: 68,
            decoration: BoxDecoration(
              color: AppTheme.surface.withOpacity(0.75),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.08),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(0, Icons.description_rounded, Icons.description_outlined, TranslationHelper.translateReactive(context, 'tab_notes')),
                _buildNavItem(1, Icons.calendar_today_rounded, Icons.calendar_today_outlined, TranslationHelper.translateReactive(context, 'tab_schedule')),
                _buildNavItem(2, Icons.analytics_rounded, Icons.analytics_outlined, TranslationHelper.translateReactive(context, 'tab_dashboard')),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Builder for navigation items
  Widget _buildNavItem(int index, IconData activeIcon, IconData inactiveIcon, String label) {
    final isSelected = _currentIndex == index;
    final iconColor = isSelected ? AppTheme.accent : AppTheme.textSecondary;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentIndex = index;
          });
        },
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.accent.withOpacity(0.08) : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppTheme.accent.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: -2,
                        )
                      ]
                    : null,
              ),
              child: Icon(
                isSelected ? activeIcon : inactiveIcon,
                color: iconColor,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: iconColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontFamily: 'Outfit',
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
