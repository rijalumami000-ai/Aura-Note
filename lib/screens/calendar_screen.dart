import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../providers/note_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/aura_lock_dialog.dart';
import '../utils/translation_helper.dart';
import 'note_editor_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _focusedDate;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedDate = DateTime(now.year, now.month, 1);
    _selectedDate = DateTime(now.year, now.month, now.day);
  }

  // Calculate days in the focused month
  int _getDaysInMonth(DateTime date) {
    final nextMonth = DateTime(date.year, date.month + 1, 1);
    final lastDay = nextMonth.subtract(const Duration(days: 1));
    return lastDay.day;
  }

  // Calculate start weekday of the focused month (1 = Monday, 7 = Sunday)
  int _getStartWeekday(DateTime date) {
    return DateTime(date.year, date.month, 1).weekday;
  }

  void _nextMonth() {
    setState(() {
      _focusedDate = DateTime(_focusedDate.year, _focusedDate.month + 1, 1);
    });
  }

  void _prevMonth() {
    setState(() {
      _focusedDate = DateTime(_focusedDate.year, _focusedDate.month - 1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final noteProvider = context.watch<NoteProvider>();
    final notesWithReminders = noteProvider.notes.where((n) => n.reminderDate != null && !n.isTrashed).toList();

    // Map reminders by day to draw glowing indicators
    final Map<String, List<Note>> reminderMap = {};
    for (var note in notesWithReminders) {
      final dateKey = _getDateKey(note.reminderDate!);
      if (!reminderMap.containsKey(dateKey)) {
        reminderMap[dateKey] = [];
      }
      reminderMap[dateKey]!.add(note);
    }

    final selectedDateKey = _getDateKey(_selectedDate);
    final selectedDayNotes = reminderMap[selectedDateKey] ?? [];

    return Scaffold(
      body: Stack(
        children: [
          // Cosmic neon background glow
          Positioned(
            top: -80,
            left: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accent.withOpacity(0.12),
                    blurRadius: 100,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 120,
            right: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00F2FE).withOpacity(0.06),
                    blurRadius: 100,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // Screen Header
                  Text(
                    TranslationHelper.translateReactive(context, 'schedule_title'),
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'AuraCalendar',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                  ),
                  const SizedBox(height: 20),

                  // Calendar Card
                  _buildCalendarCard(reminderMap),
                  const SizedBox(height: 24),

                  // Timeline / Reminders Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        TranslationHelper.translateReactive(context, 'schedule_today'),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textSecondary.withOpacity(0.8),
                          letterSpacing: 1.0,
                        ),
                      ),
                      Text(
                        '${selectedDayNotes.length} ${Provider.of<NoteProvider>(context).languageCode == 'en' ? 'Tasks' : 'Tugas'}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // List of Reminders for Selected Day
                  Expanded(
                    child: selectedDayNotes.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount: selectedDayNotes.length,
                            itemBuilder: (context, index) {
                              final note = selectedDayNotes[index];
                              return _buildReminderTimelineTile(note);
                            },
                          ),
                  ),
                  // Bottom bar spacer
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Generate date key for hashing Map
  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // Calendar container builder
  Widget _buildCalendarCard(Map<String, List<Note>> reminderMap) {
    final year = _focusedDate.year;
    final month = _focusedDate.month;
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];

    final totalDays = _getDaysInMonth(_focusedDate);
    final startWeekday = _getStartWeekday(_focusedDate);
    final gridPaddingCount = startWeekday - 1; // days offset to start on Monday

    final totalCells = totalDays + gridPaddingCount;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppTheme.glassDecoration(
        auraColor: AppTheme.accent,
        showGlow: false,
      ),
      child: Column(
        children: [
          // Navigation Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${months[month - 1]} $year',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Outfit',
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: _prevMonth,
                    icon: const Icon(Icons.chevron_left, color: Colors.white, size: 20),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.03),
                      padding: const EdgeInsets.all(6),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _nextMonth,
                    icon: const Icon(Icons.chevron_right, color: Colors.white, size: 20),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.03),
                      padding: const EdgeInsets.all(6),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Weekdays header
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _WeekdayHeader('S'),
              _WeekdayHeader('S'),
              _WeekdayHeader('R'),
              _WeekdayHeader('K'),
              _WeekdayHeader('J'),
              _WeekdayHeader('S'),
              _WeekdayHeader('M'),
            ],
          ),
          const SizedBox(height: 10),

          // Grid Days
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: totalCells,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              childAspectRatio: 1.0,
            ),
            itemBuilder: (context, index) {
              if (index < gridPaddingCount) {
                return const SizedBox.shrink(); // Offset days from last month
              }

              final dayNum = index - gridPaddingCount + 1;
              final currentDayDate = DateTime(year, month, dayNum);
              final dateKey = _getDateKey(currentDayDate);
              final hasReminders = reminderMap.containsKey(dateKey);
              final isSelected = _selectedDate.year == currentDayDate.year &&
                  _selectedDate.month == currentDayDate.month &&
                  _selectedDate.day == currentDayDate.day;

              // Check if today
              final now = DateTime.now();
              final isToday = now.year == currentDayDate.year &&
                  now.month == currentDayDate.month &&
                  now.day == currentDayDate.day;

              // Determine color based on first reminder's category
              Color dayGlowColor = AppTheme.accent;
              if (hasReminders) {
                final category = reminderMap[dateKey]!.first.category;
                dayGlowColor = AppTheme.getColorForCategory(category);
              }

              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedDate = currentDayDate;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? dayGlowColor.withOpacity(0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? dayGlowColor
                          : isToday
                              ? Colors.white.withOpacity(0.3)
                              : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        '$dayNum',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? Colors.white
                              : isToday
                                  ? Colors.white
                                  : AppTheme.textSecondary,
                        ),
                      ),
                      // Glowing dot for reminder
                      if (hasReminders)
                        Positioned(
                          bottom: 4,
                          child: Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: dayGlowColor,
                              boxShadow: [
                                BoxShadow(
                                  color: dayGlowColor.withOpacity(0.8),
                                  blurRadius: 4,
                                  spreadRadius: 0.5,
                                )
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Reminder Timeline Card Tile Builder
  Widget _buildReminderTimelineTile(Note note) {
    final auraColor = AppTheme.getColorForCategory(note.category);
    final String timeStr = '${note.reminderDate!.hour.toString().padLeft(2, '0')}:${note.reminderDate!.minute.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: InkWell(
            onTap: () => _openNote(note),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: AppTheme.glassDecoration(
                auraColor: auraColor,
                showGlow: false,
              ),
              child: Row(
                children: [
                  // Time Column
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: auraColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: auraColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      timeStr,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: auraColor,
                        fontFamily: 'Outfit',
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Title & Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          note.isLocked ? 'Catatan Terkunci' : (note.title.isEmpty ? 'Catatan Tanpa Judul' : note.title),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: note.isLocked ? AppTheme.textSecondary.withOpacity(0.5) : Colors.white,
                            fontFamily: 'Outfit',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: auraColor,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              note.category,
                              style: TextStyle(
                                fontSize: 10,
                                color: AppTheme.textSecondary.withOpacity(0.8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (note.isLocked) ...[
                              const SizedBox(width: 8),
                              Icon(Icons.lock_outline, size: 12, color: auraColor),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: AppTheme.textSecondary.withOpacity(0.4), size: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Open note logic (handles locked vault biometrics authentication)
  void _openNote(Note note) {
    if (note.isLocked) {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return AuraLockDialog(
            category: note.category,
            onAuthenticated: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NoteEditorScreen(note: note),
                ),
              );
            },
          );
        },
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NoteEditorScreen(note: note),
        ),
      );
    }
  }

  // Empty state builder
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 40,
              color: AppTheme.textSecondary.withOpacity(0.2),
            ),
            const SizedBox(height: 12),
            Text(
              TranslationHelper.translateReactive(context, 'empty_schedule'),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.textSecondary.withOpacity(0.6),
                fontFamily: 'Outfit',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              TranslationHelper.translateReactive(context, 'empty_schedule_sub'),
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondary.withOpacity(0.4),
                fontFamily: 'Outfit',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeekdayHeader extends StatelessWidget {
  final String char;
  const _WeekdayHeader(this.char);

  @override
  Widget build(BuildContext context) {
    return Text(
      char,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: AppTheme.textSecondary.withOpacity(0.6),
      ),
    );
  }
}
