import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/note_provider.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/trash_archive_screen.dart';
import 'screens/note_editor_screen.dart';
import 'utils/translation_helper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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

class _MainNavigationScreenState extends State<MainNavigationScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _fabAnimController;
  late Animation<double> _fabScaleAnim;

  final List<Widget> _screens = [
    const HomeScreen(),
    const CalendarScreen(),
    const TrashArchiveScreen(showBackButton: false),
    const DashboardScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _fabAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..forward();
    _fabScaleAnim = CurvedAnimation(
      parent: _fabAnimController,
      curve: Curves.easeOutBack,
    );
  }

  @override
  void dispose() {
    _fabAnimController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    setState(() {
      _currentIndex = index;
      _fabAnimController.reset();
      _fabAnimController.forward();
    });
  }

  void _openNoteEditor() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const NoteEditorScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.1),
              end: Offset.zero,
            ).animate(curved),
            child: FadeTransition(opacity: curved, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildFloatingBottomBar(),
    );
  }

  Widget _buildFloatingBottomBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              color: AppTheme.surface.withOpacity(0.80),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Colors.white.withOpacity(0.10),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: AppTheme.accent.withOpacity(0.08),
                  blurRadius: 30,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Tab Catatan (Kiri 1)
                _buildNavItem(
                  0,
                  Icons.description_rounded,
                  Icons.description_outlined,
                  TranslationHelper.translateReactive(context, 'tab_notes'),
                ),

                // Tab Kalender (Kiri 2)
                _buildNavItem(
                  1,
                  Icons.calendar_today_rounded,
                  Icons.calendar_today_outlined,
                  TranslationHelper.translateReactive(context, 'tab_schedule'),
                ),

                // Center FAB — Tombol Tambah
                Expanded(
                  child: Center(
                    child: ScaleTransition(
                      scale: _fabScaleAnim,
                      child: GestureDetector(
                        onTap: _openNoteEditor,
                        child: Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppTheme.accent, Color(0xFFC71585)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.accent.withOpacity(0.50),
                                blurRadius: 18,
                                offset: const Offset(0, 6),
                              ),
                              BoxShadow(
                                color: const Color(0xFFC71585).withOpacity(0.25),
                                blurRadius: 12,
                                spreadRadius: -2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.add_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Tab Sampah & Arsip (Kanan 1)
                _buildNavItem(
                  2,
                  Icons.delete_outline_rounded,
                  Icons.delete_outline_rounded,
                  TranslationHelper.translateReactive(context, 'tab_trash_archive'),
                ),

                // Tab Dashboard (Kanan 2)
                _buildNavItem(
                  3,
                  Icons.analytics_rounded,
                  Icons.analytics_outlined,
                  TranslationHelper.translateReactive(context, 'tab_dashboard'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData activeIcon,
    IconData inactiveIcon,
    String label,
  ) {
    final isSelected = _currentIndex == index;
    final iconColor =
        isSelected ? AppTheme.accent : AppTheme.textSecondary;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onNavTap(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.accent.withOpacity(0.10)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppTheme.accent.withOpacity(0.12),
                          blurRadius: 10,
                          spreadRadius: -2,
                        )
                      ]
                    : null,
              ),
              child: Icon(
                isSelected ? activeIcon : inactiveIcon,
                color: iconColor,
                size: 20,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 9,
                color: iconColor,
                fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.normal,
                fontFamily: 'Outfit',
                letterSpacing: 0.1,
              ),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
