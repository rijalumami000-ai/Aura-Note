import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/note_provider.dart';
import '../theme/app_theme.dart';
import '../utils/translation_helper.dart';
import 'trash_archive_screen.dart';
import 'mind_map_screen.dart';
import 'drawing_canvas_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NoteProvider>(
      builder: (context, provider, child) {
        final stats = provider.getStatistics();
        final activeCount = stats['activeCount'] as int;
        final archivedCount = stats['archivedCount'] as int;
        final trashedCount = stats['trashedCount'] as int;
        final totalTodos = stats['totalTodos'] as int;
        final completedTodos = stats['completedTodos'] as int;
        final todoProgress = stats['todoProgress'] as double;
        final categoriesCount = stats['categoriesCount'] as Map<String, int>;

        return Scaffold(
          body: Stack(
            children: [
              // Neon lights backdrop
              Positioned(
                top: -100,
                left: -100,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accent.withOpacity(0.12),
                        blurRadius: 100,
                        spreadRadius: 30,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 100,
                right: -100,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00FF87).withOpacity(0.06),
                        blurRadius: 100,
                        spreadRadius: 30,
                      ),
                    ],
                  ),
                ),
              ),

              SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Text(
                        TranslationHelper.translateReactive(context, 'dashboard_sub'),
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        TranslationHelper.translateReactive(context, 'dashboard_title'),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                      ),
                      const SizedBox(height: 24),

                      // Section 1: Progress Ring & stats card
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: AppTheme.glassDecoration(
                              auraColor: AppTheme.accent,
                              showGlow: true,
                            ),
                            child: Row(
                              children: [
                                // Glowing Circular Progress Indicator
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Outer neon shadow circular glow
                                    Container(
                                      width: 90,
                                      height: 90,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppTheme.accent.withOpacity(0.2),
                                            blurRadius: 12,
                                            spreadRadius: 1,
                                          )
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: 84,
                                      height: 84,
                                      child: CircularProgressIndicator(
                                        value: todoProgress,
                                        strokeWidth: 8,
                                        backgroundColor: Colors.white.withOpacity(0.04),
                                        valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accent),
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        Text(
                                          '${(todoProgress * 100).toInt()}%',
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          provider.languageCode == 'en' ? 'Done' : 'Selesai',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 24),

                                // Text details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        TranslationHelper.translateReactive(context, 'todo_title'),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        provider.languageCode == 'en' 
                                          ? 'Completed $completedTodos of $totalTodos tasks listed in active notes.'
                                          : 'Telah menyelesaikan $completedTodos dari $totalTodos tugas yang terdaftar di catatan aktif.',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.textSecondary,
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Section 2: Metrics Counters
                      Row(
                        children: [
                           Expanded(
                            child: _buildMetricTile(
                              context,
                              TranslationHelper.translateReactive(context, 'Aktif'),
                              activeCount.toString(),
                              Icons.description_outlined,
                              const Color(0xFF00F2FE),
                              onTap: null,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _buildMetricTile(
                              context,
                              TranslationHelper.translateReactive(context, 'Arsip'),
                              archivedCount.toString(),
                              Icons.archive_outlined,
                              const Color(0xFF00FF87),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const TrashArchiveScreen(initialTab: 1),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _buildMetricTile(
                              context,
                              TranslationHelper.translateReactive(context, 'Sampah'),
                              trashedCount.toString(),
                              Icons.delete_outline_rounded,
                              Colors.redAccent,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const TrashArchiveScreen(initialTab: 0),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // Section 2.5: Aura Suite (Creative Tools)
                      Text(
                        provider.languageCode == 'en' ? 'Aura Creative Suite' : 'Aura Suite Kreatif',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          // AuraMind Card
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: AppTheme.glassDecoration(auraColor: AppTheme.accent),
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const MindMapScreen(),
                                        ),
                                      );
                                    },
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Icon(Icons.hub_outlined, color: AppTheme.accent, size: 28),
                                        const SizedBox(height: 12),
                                        const Text(
                                          'AuraMind',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontFamily: 'Outfit',
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          provider.languageCode == 'en'
                                              ? 'Interactive Mind Map'
                                              : 'Peta Pikiran Interaktif',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: AppTheme.textSecondary,
                                            fontFamily: 'Outfit',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          // AuraDraw Card
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: AppTheme.glassDecoration(auraColor: const Color(0xFF00FF87)),
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const DrawingCanvasScreen(
                                            isStandalone: true,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Icon(Icons.brush, color: Color(0xFF00FF87), size: 28),
                                        const SizedBox(height: 12),
                                        const Text(
                                          'AuraDraw',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontFamily: 'Outfit',
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          provider.languageCode == 'en'
                                              ? 'Freehand Canvas'
                                              : 'Kanvas Gambar Bebas',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: AppTheme.textSecondary,
                                            fontFamily: 'Outfit',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // Section 3: Categories Proportion horizontal bar chart
                      Text(
                        TranslationHelper.translateReactive(context, 'Kategori Catatan'),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 14),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: AppTheme.glassDecoration(
                              auraColor: Colors.white,
                            ),
                            child: Column(
                              children: categoriesCount.entries.map((entry) {
                                final category = entry.key;
                                final count = entry.value;
                                final color = AppTheme.getColorForCategory(category);
                                final maxVal = activeCount > 0 ? activeCount : 1;
                                final double ratio = count / maxVal;

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            category,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: AppTheme.textPrimary,
                                            ),
                                          ),
                                          Text(
                                            '$count ${provider.languageCode == 'en' ? 'Notes' : 'Catatan'}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: color,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      // Custom bar
                                      Stack(
                                        children: [
                                          Container(
                                            height: 8,
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.04),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                          ),
                                          FractionallySizedBox(
                                            widthFactor: ratio,
                                            child: Container(
                                              height: 8,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: AppTheme.getGradientForCategory(category),
                                                ),
                                                borderRadius: BorderRadius.circular(4),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: color.withOpacity(0.3),
                                                    blurRadius: 4,
                                                    spreadRadius: -1,
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Section 4: Quick Actions (Trash operations)
                      if (trashedCount > 0) ...[
                        Text(
                          TranslationHelper.translateReactive(context, 'Tindakan Cepat'),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: AppTheme.glassDecoration(auraColor: Colors.redAccent),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      TranslationHelper.translateReactive(context, 'Bakar Tempat Sampah'),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      provider.languageCode == 'en'
                                          ? 'Permanently delete $trashedCount notes in Trash.'
                                          : 'Hapus permanen $trashedCount catatan di Tempat Sampah.',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    _showConfirmClearTrash(context, provider);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent.withOpacity(0.15),
                                    elevation: 0,
                                    side: const BorderSide(color: Colors.redAccent, width: 0.8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Text(
                                    provider.languageCode == 'en' ? 'Empty' : 'Kosongkan',
                                    style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),

                      // Section 5: Settings (AuraLanguage Selector)
                      Text(
                        TranslationHelper.translateReactive(context, 'dashboard_lang'),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: AppTheme.glassDecoration(auraColor: AppTheme.accent),
                          child: InkWell(
                            onTap: () => _showLanguageSelectorSheet(context, provider),
                            child: Row(
                              children: [
                                const Icon(Icons.language_rounded, color: AppTheme.accent),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        TranslationHelper.translateReactive(context, 'dashboard_lang'),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        TranslationHelper.translateReactive(context, 'dashboard_lang_sub'),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.accent.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    TranslationHelper.languages[provider.languageCode] ?? 'Indonesia',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.accent,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      // AuraSync Google Cloud Sync tile
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: AppTheme.glassDecoration(auraColor: provider.isSyncEnabled ? const Color(0xFF00FF87) : const Color(0xFF4FACFE)),
                          child: InkWell(
                            onTap: () => _showGoogleSyncSheet(context, provider),
                            child: Row(
                              children: [
                                Icon(
                                  provider.isSyncEnabled ? Icons.cloud_done : Icons.cloud_off, 
                                  color: provider.isSyncEnabled ? const Color(0xFF00FF87) : const Color(0xFF4FACFE)
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        TranslationHelper.translateReactive(context, 'sync_title'),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        provider.isSyncEnabled 
                                          ? '${provider.googleEmail} (${TranslationHelper.translateReactive(context, 'sync_active')})'
                                          : TranslationHelper.translateReactive(context, 'sync_desc'),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right, 
                                  color: provider.isSyncEnabled ? const Color(0xFF00FF87) : const Color(0xFF4FACFE)
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      // AuraCrypt E2EE tile
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: AppTheme.glassDecoration(auraColor: provider.isE2eeEnabled ? const Color(0xFFFF007F) : const Color(0xFFA88BEB)),
                          child: InkWell(
                            onTap: () => _showE2eeSheet(context, provider),
                            child: Row(
                              children: [
                                Icon(
                                  provider.isE2eeEnabled ? Icons.security : Icons.security_outlined, 
                                  color: provider.isE2eeEnabled ? const Color(0xFFFF007F) : const Color(0xFFA88BEB)
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        TranslationHelper.translateReactive(context, 'e2ee_title'),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        provider.isE2eeEnabled 
                                          ? TranslationHelper.translateReactive(context, 'e2ee_active')
                                          : TranslationHelper.translateReactive(context, 'e2ee_desc'),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right, 
                                  color: provider.isE2eeEnabled ? const Color(0xFFFF007F) : const Color(0xFFA88BEB)
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Mini metric tile builder
  Widget _buildMetricTile(
    BuildContext context,
    String label,
    String count,
    IconData icon,
    Color glowColor, {
    VoidCallback? onTap,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
            decoration: AppTheme.glassDecoration(
              auraColor: glowColor,
              showGlow: false,
            ),
            child: Column(
              children: [
                Icon(icon, color: glowColor, size: 20),
                const SizedBox(height: 8),
                Text(
                  count,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Show confirm dialog to empty trash
  void _showConfirmClearTrash(BuildContext context, NoteProvider provider) {
    showDialog(
      context: context,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: AlertDialog(
            backgroundColor: AppTheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: Colors.redAccent.withOpacity(0.3), width: 1),
            ),
            title: Text(
              provider.languageCode == 'en' ? 'Empty Trash Bin?' : 'Kosongkan Sampah?',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
            ),
            content: Text(
              provider.languageCode == 'en' 
                ? 'All notes inside the trash bin will be permanently deleted. This action cannot be undone.'
                : 'Semua catatan di dalam tempat sampah akan dihapus secara permanen. Tindakan ini tidak dapat dibatalkan.',
              style: const TextStyle(color: AppTheme.textSecondary, fontFamily: 'Outfit'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(provider.languageCode == 'en' ? 'Cancel' : 'Batal', style: const TextStyle(color: AppTheme.textSecondary, fontFamily: 'Outfit')),
              ),
              ElevatedButton(
                onPressed: () {
                  provider.clearTrash();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        provider.languageCode == 'en' ? 'Trash bin cleared successfully' : 'Tempat Sampah berhasil dibersihkan', 
                        style: const TextStyle(fontFamily: 'Outfit')
                      ),
                      backgroundColor: AppTheme.surface,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  provider.languageCode == 'en' ? 'Delete Permanently' : 'Hapus Permanen', 
                  style: const TextStyle(color: Colors.white, fontFamily: 'Outfit', fontWeight: FontWeight.bold)
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // AuraLanguage dialog sheet for choosing language
  void _showLanguageSelectorSheet(BuildContext context, NoteProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
            decoration: BoxDecoration(
              color: AppTheme.surface.withOpacity(0.92),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  TranslationHelper.translate(context, 'dashboard_lang'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Outfit',
                  ),
                ),
                const SizedBox(height: 18),
                
                Flexible(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: TranslationHelper.languages.entries.map((entry) {
                        final code = entry.key;
                        final name = entry.value;
                        final isSelected = provider.languageCode == code;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.accent.withOpacity(0.08) : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            onTap: () {
                              provider.setLanguageCode(code);
                              Navigator.pop(context);
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            leading: Icon(
                              Icons.language_rounded,
                              color: isSelected ? AppTheme.accent : AppTheme.textSecondary,
                              size: 20,
                            ),
                            title: Text(
                              name,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? Colors.white : AppTheme.textPrimary,
                              ),
                            ),
                            trailing: isSelected
                                ? const Icon(Icons.check_circle_rounded, color: AppTheme.accent, size: 20)
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  String _formatSyncDate(String? syncTimeStr, String langCode) {
    if (syncTimeStr == null) return '-';
    try {
      final dateTime = DateTime.parse(syncTimeStr);
      final now = DateTime.now();
      final diff = now.difference(dateTime);
      if (diff.inSeconds < 10) {
        return langCode == 'en' ? 'Just now' : 'Baru saja';
      } else if (diff.inMinutes < 1) {
        return langCode == 'en' ? '${diff.inSeconds}s ago' : '${diff.inSeconds} detik lalu';
      } else if (diff.inHours < 1) {
        return langCode == 'en' ? '${diff.inMinutes}m ago' : '${diff.inMinutes} menit lalu';
      } else {
        return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
      }
    } catch (_) {
      return '-';
    }
  }

  // AuraSync sheet
  void _showGoogleSyncSheet(BuildContext context, NoteProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        bool isConnecting = false;
        bool isSyncing = false;
        double progressVal = 0.0;
        String statusText = '';

        return StatefulBuilder(
          builder: (context, setModalState) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
                decoration: BoxDecoration(
                  color: AppTheme.surface.withOpacity(0.92),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 48,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      TranslationHelper.translate(context, 'sync_title'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Outfit',
                      ),
                    ),
                    const SizedBox(height: 18),

                    if (isConnecting) ...[
                      // Connecting loader
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 30),
                          child: Column(
                            children: [
                              const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4FACFE))),
                              const SizedBox(height: 16),
                              Text(
                                TranslationHelper.translate(context, 'sync_connecting'),
                                style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ] else if (isSyncing) ...[
                      // Syncing progress bar
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 30),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                statusText,
                                style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: progressVal,
                                  minHeight: 6,
                                  backgroundColor: Colors.white.withOpacity(0.04),
                                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00FF87)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ] else if (!provider.isSyncEnabled) ...[
                      // Google sign-in menu
                      Text(
                        provider.languageCode == 'en'
                            ? 'Connect your Google account to back up and sync your notes across devices automatically.'
                            : 'Hubungkan akun Google Anda untuk mencadangkan dan menyinkronkan catatan secara otomatis di berbagai perangkat.',
                        style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.5),
                      ),
                      const SizedBox(height: 24),
                      InkWell(
                        onTap: () async {
                          setModalState(() {
                            isConnecting = true;
                          });
                          final success = await provider.signInGoogle();
                          if (context.mounted) {
                            setModalState(() {
                              isConnecting = false;
                            });
                            if (success) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                content: Text('Berhasil terhubung ke akun Google!'),
                                behavior: SnackBarBehavior.floating,
                              ));
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                content: Text('Gagal menghubungkan Google Sign-In. Pastikan konfigurasi Google Cloud Console / google-services.json sudah disetup.'),
                                behavior: SnackBarBehavior.floating,
                              ));
                            }
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFF4FACFE).withOpacity(0.4), width: 1.2),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.g_mobiledata_rounded, color: Color(0xFF4FACFE), size: 32),
                              const SizedBox(width: 8),
                              Text(
                                TranslationHelper.translate(context, 'sync_google'),
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ] else ...[
                      // Connected menu
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF00F2FE), Color(0xFF4FACFE)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF4FACFE).withOpacity(0.3),
                                  blurRadius: 8,
                                )
                              ],
                            ),
                            child: const Icon(Icons.person, color: Colors.white),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  provider.googleEmail ?? '',
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  TranslationHelper.translateReactive(context, 'sync_active'),
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF00FF87), fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '${TranslationHelper.translateReactive(context, 'sync_last')}${_formatSyncDate(provider.lastSyncTime, provider.languageCode)}',
                        style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                setModalState(() {
                                  isSyncing = true;
                                  progressVal = 0.1;
                                  statusText = TranslationHelper.translate(context, 'sync_uploading');
                                });

                                // Start a gentle progress simulation while actual upload is running
                                final progressTimer = Timer.periodic(const Duration(milliseconds: 200), (t) {
                                  setModalState(() {
                                    if (progressVal < 0.9) {
                                      progressVal += 0.05;
                                    }
                                  });
                                });

                                final success = await provider.performSync();

                                progressTimer.cancel();
                                setModalState(() {
                                  progressVal = 1.0;
                                });

                                if (context.mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text(success 
                                        ? 'Sinkronisasi cloud berhasil!' 
                                        : 'Sinkronisasi gagal. Hubungkan kembali akun Google Anda atau periksa koneksi internet.'),
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: success ? Colors.green : Colors.redAccent,
                                  ));
                                }
                              },
                              icon: const Icon(Icons.sync, size: 16),
                              label: Text(TranslationHelper.translate(context, 'sync_now')),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00FF87).withOpacity(0.12),
                                foregroundColor: const Color(0xFF00FF87),
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: const BorderSide(color: Color(0xFF00FF87), width: 0.8),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                provider.signOutGoogle();
                                Navigator.pop(context);
                              },
                              icon: const Icon(Icons.power_settings_new_rounded, size: 16),
                              label: Text(TranslationHelper.translate(context, 'sync_disconnect')),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent.withOpacity(0.12),
                                foregroundColor: Colors.redAccent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: const BorderSide(color: Colors.redAccent, width: 0.8),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showE2eeSheet(BuildContext context, NoteProvider provider) {
    final TextEditingController passwordController = TextEditingController(text: provider.e2eePassphrase ?? '');
    bool isObscured = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Padding(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
                  decoration: BoxDecoration(
                    color: AppTheme.surface.withOpacity(0.92),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 48,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        TranslationHelper.translate(context, 'e2ee_title'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Outfit',
                        ),
                      ),
                      const SizedBox(height: 18),

                      Text(
                        provider.isE2eeEnabled 
                          ? (provider.languageCode == 'en' 
                              ? 'Your notes are securely encrypted using your private passphrase. Nobody (including Google) can view their content.'
                              : 'Catatan Anda dienkripsi dengan aman menggunakan kunci sandi pribadi. Tidak ada (termasuk Google) yang dapat melihat kontennya.')
                          : (provider.languageCode == 'en'
                              ? 'Protect all notes in memory and cloud backups with advanced client-side End-to-End Encryption.'
                              : 'Lindungi semua catatan di memori dan cadangan cloud dengan Enkripsi End-to-End sisi klien yang canggih.'),
                        style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.5),
                      ),
                      const SizedBox(height: 20),

                      // Password Field
                      Text(
                        provider.languageCode == 'en' ? 'Encryption Key (Passphrase)' : 'Kunci Enkripsi (Kata Sandi)',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFFF007F).withOpacity(0.3)),
                        ),
                        child: TextField(
                          controller: passwordController,
                          obscureText: isObscured,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: TranslationHelper.translate(context, 'e2ee_pass_hint'),
                            hintStyle: TextStyle(color: AppTheme.textSecondary.withOpacity(0.5), fontSize: 13),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            suffixIcon: IconButton(
                              icon: Icon(
                                isObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: AppTheme.textSecondary,
                                size: 20,
                              ),
                              onPressed: () {
                                setModalState(() {
                                  isObscured = !isObscured;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Action Buttons
                      Row(
                        children: [
                          if (provider.isE2eeEnabled) ...[
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  provider.disableE2ee();
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        provider.languageCode == 'en' 
                                          ? 'End-to-End Encryption disabled successfully' 
                                          : 'Enkripsi End-to-End berhasil dinonaktifkan',
                                        style: const TextStyle(fontFamily: 'Outfit'),
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor: AppTheme.surface,
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.lock_open_rounded, size: 16),
                                label: Text(TranslationHelper.translate(context, 'e2ee_disable')),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent.withOpacity(0.12),
                                  foregroundColor: Colors.redAccent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: const BorderSide(color: Colors.redAccent, width: 0.8),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                final pass = passwordController.text.trim();
                                if (pass.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        provider.languageCode == 'en' 
                                          ? 'Passphrase cannot be empty' 
                                          : 'Kunci sandi tidak boleh kosong',
                                        style: const TextStyle(fontFamily: 'Outfit'),
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor: AppTheme.surface,
                                    ),
                                  );
                                  return;
                                }
                                provider.enableE2ee(pass);
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      provider.languageCode == 'en' 
                                        ? 'Notes encrypted successfully!' 
                                        : 'Catatan berhasil dienkripsi secara aman!',
                                      style: const TextStyle(fontFamily: 'Outfit'),
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: AppTheme.surface,
                                  ),
                                );
                              },
                              icon: const Icon(Icons.enhanced_encryption_rounded, size: 16),
                              label: Text(
                                provider.isE2eeEnabled
                                  ? (provider.languageCode == 'en' ? 'Update Key' : 'Perbarui Kunci')
                                  : TranslationHelper.translate(context, 'e2ee_enable')
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF007F).withOpacity(0.12),
                                foregroundColor: const Color(0xFFFF007F),
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: const BorderSide(color: Color(0xFFFF007F), width: 0.8),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
