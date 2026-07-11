import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../providers/note_provider.dart';
import '../theme/app_theme.dart';
import '../utils/translation_helper.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final auraColor = AppTheme.getColorForCategory(note.category);
    final isPinned = note.isPinned;

    // Calculate completed todos ratio
    final int totalTodos = note.todos.length;
    final int completedTodos = note.todos.where((t) => t.isDone).length;
    final double todoProgress = totalTodos > 0 ? (completedTodos / totalTodos) : 0.0;

    // Formatted date (brief format)
    final String dateString = _formatDate(note.dateModified);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: InkWell(
            onTap: onTap,
            onLongPress: () => _showActionMenu(context, note),
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                Container(
                  decoration: AppTheme.glassDecoration(
                    auraColor: auraColor,
                    showGlow: isPinned,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (note.coverValue != null)
                        Container(
                          height: 70,
                          decoration: BoxDecoration(
                            gradient: AppTheme.getCoverGradient(note.coverValue),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Row: Title & Pin/Category Icon
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    note.isLocked ? TranslationHelper.translateReactive(context, 'card_locked') : (note.title.isEmpty ? TranslationHelper.translateReactive(context, 'Catatan Tanpa Judul') : note.title),
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: note.isLocked ? AppTheme.textSecondary.withOpacity(0.5) : AppTheme.textPrimary,
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Pin Toggle Button
                                Row(
                                  children: [
                                    if (note.sketchStrokes.isNotEmpty && !note.isLocked)
                                      Icon(
                                        Icons.brush,
                                        size: 16,
                                        color: auraColor.withOpacity(0.8),
                                      ),
                                    if (note.sketchStrokes.isNotEmpty && !note.isLocked)
                                      const SizedBox(width: 6),
                                    if (!note.isLocked)
                                      GestureDetector(
                                        onTap: () {
                                          context.read<NoteProvider>().togglePin(note.id);
                                        },
                                        child: Icon(
                                          isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                                          size: 18,
                                          color: isPinned ? auraColor : AppTheme.textSecondary.withOpacity(0.6),
                                        ),
                                      ),
                                    if (note.isLocked)
                                      Icon(
                                        Icons.lock_outline,
                                        size: 18,
                                        color: auraColor,
                                      ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // Content Snippet
                            if (note.isLocked)
                              Container(
                                height: 48,
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  children: [
                                    Icon(Icons.fingerprint, size: 24, color: auraColor.withOpacity(0.6)),
                                    const SizedBox(width: 10),
                                    Text(
                                      TranslationHelper.translateReactive(context, 'card_locked_hint'),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.textSecondary.withOpacity(0.4),
                                        fontStyle: FontStyle.italic,
                                        fontFamily: 'Outfit',
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else if (note.todos.isNotEmpty)
                              Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          TranslationHelper.translateReactive(context, 'todo_title'),
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.textSecondary.withOpacity(0.7),
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        Text(
                                          '${(todoProgress * 100).toInt()}%',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: auraColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: LinearProgressIndicator(
                                        value: todoProgress,
                                        minHeight: 4,
                                        backgroundColor: Colors.white.withOpacity(0.04),
                                        valueColor: AlwaysStoppedAnimation<Color>(auraColor),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else if (note.content.isNotEmpty)
                              Text(
                                note.content,
                                style: Theme.of(context).textTheme.bodyMedium,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              )
                            else
                              Text(
                                  TranslationHelper.translateReactive(context, 'Catatan kosong...'),
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: AppTheme.textSecondary.withOpacity(0.4),
                                        fontStyle: FontStyle.italic,
                                      ),
                              ),

                            // AI Summary Tag if present
                            if (note.aiSummary != null && note.aiSummary!.isNotEmpty && !note.isLocked) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.accent.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppTheme.accent.withOpacity(0.2),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.auto_awesome,
                                      size: 11,
                                      color: AppTheme.accent,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'AuraAI Rangkuman',
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: AppTheme.accent.withOpacity(0.9),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            // Reminder Chip
                            if (note.reminderDate != null && !note.isLocked) ...[
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Icon(
                                    Icons.notifications_active_outlined,
                                    size: 14,
                                    color: auraColor,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _formatReminder(note.reminderDate!),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: auraColor.withOpacity(0.9),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],

                            const SizedBox(height: 14),

                            // Footer: Date & Category Pill
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  dateString,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.textSecondary.withOpacity(0.7),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: auraColor.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: auraColor.withOpacity(0.3),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Text(
                                    note.category,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: auraColor,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Blur cover overlay if locked
                if (note.isLocked)
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Container(
                          color: Colors.black.withOpacity(0.15),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Format Date to indonesian readable format
  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Baru saja';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} menit lalu';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inDays == 1) {
      return 'Kemarin';
    } else {
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'
      ];
      return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}';
    }
  }

  // Format Reminder to readable text
  String _formatReminder(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final reminderDay = DateTime(dateTime.year, dateTime.month, dateTime.day);

    final String timeStr = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

    if (reminderDay == today) {
      return 'Hari ini, $timeStr';
    } else if (reminderDay == tomorrow) {
      return 'Besok, $timeStr';
    } else {
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'
      ];
      return '${dateTime.day} ${months[dateTime.month - 1]}, $timeStr';
    }
  }

  void _showActionMenu(BuildContext context, Note note) {
    final provider = Provider.of<NoteProvider>(context, listen: false);
    final isEn = provider.languageCode == 'en';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.surface.withOpacity(0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.textSecondary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              // Pin / Unpin
              _buildActionTile(
                icon: note.isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                label: note.isPinned
                    ? (isEn ? 'Unpin' : 'Lepas Sematan')
                    : (isEn ? 'Pin' : 'Sematkan'),
                color: const Color(0xFFFFD700),
                onTap: () {
                  Navigator.pop(ctx);
                  provider.togglePin(note.id);
                },
              ),
              // Archive / Unarchive
              _buildActionTile(
                icon: note.isArchived ? Icons.unarchive_rounded : Icons.archive_outlined,
                label: note.isArchived
                    ? (isEn ? 'Unarchive' : 'Buka Arsip')
                    : (isEn ? 'Archive' : 'Arsipkan'),
                color: const Color(0xFF00AAFF),
                onTap: () {
                  Navigator.pop(ctx);
                  provider.toggleArchive(note.id);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(note.isArchived
                        ? (isEn ? 'Note unarchived' : 'Catatan dibuka dari arsip')
                        : (isEn ? 'Note archived' : 'Catatan diarsipkan')),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: AppTheme.surface,
                  ));
                },
              ),
              // Lock / Unlock
              _buildActionTile(
                icon: note.isLocked ? Icons.lock_open_rounded : Icons.lock_outline_rounded,
                label: note.isLocked
                    ? (isEn ? 'Unlock' : 'Buka Kunci')
                    : (isEn ? 'Lock' : 'Kunci'),
                color: const Color(0xFFFF6B35),
                onTap: () {
                  Navigator.pop(ctx);
                  provider.toggleNoteLock(note.id);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(note.isLocked
                        ? (isEn ? 'Note unlocked' : 'Catatan dibuka kuncinya')
                        : (isEn ? 'Note locked' : 'Catatan dikunci')),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: AppTheme.surface,
                  ));
                },
              ),
              const Divider(color: Colors.white10, indent: 20, endIndent: 20),
              // Move to Trash
              _buildActionTile(
                icon: Icons.delete_outline_rounded,
                label: isEn ? 'Move to Trash' : 'Pindahkan ke Sampah',
                color: Colors.redAccent,
                onTap: () {
                  Navigator.pop(ctx);
                  provider.moveToTrash(note.id);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(isEn ? 'Note moved to trash' : 'Catatan dipindahkan ke sampah'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: AppTheme.surface,
                    action: SnackBarAction(
                      label: isEn ? 'Undo' : 'Batalkan',
                      textColor: AppTheme.accent,
                      onPressed: () => provider.restoreFromTrash(note.id),
                    ),
                  ));
                },
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        label,
        style: TextStyle(
          color: color == Colors.redAccent ? Colors.redAccent : AppTheme.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      onTap: onTap,
      dense: true,
    );
  }
}
