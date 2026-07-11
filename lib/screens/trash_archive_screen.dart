import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../providers/note_provider.dart';
import '../theme/app_theme.dart';
import '../utils/translation_helper.dart';

class TrashArchiveScreen extends StatefulWidget {
  final int initialTab; // 0 = Trash, 1 = Archive

  const TrashArchiveScreen({super.key, this.initialTab = 0});

  @override
  State<TrashArchiveScreen> createState() => _TrashArchiveScreenState();
}

class _TrashArchiveScreenState extends State<TrashArchiveScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialTab);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NoteProvider>(
      builder: (context, provider, child) {
        final trashedNotes = provider.trashedNotes;
        final archivedNotes = provider.archivedNotes;

        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded, color: AppTheme.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              _tabController.index == 0
                  ? (provider.languageCode == 'en' ? 'Trash' : 'Tempat Sampah')
                  : (provider.languageCode == 'en' ? 'Archive' : 'Arsip'),
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontFamily: 'Outfit',
                fontWeight: FontWeight.bold,
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              onTap: (_) => setState(() {}),
              indicatorColor: AppTheme.accent,
              labelColor: AppTheme.accent,
              unselectedLabelColor: AppTheme.textSecondary,
              labelStyle: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold),
              tabs: [
                Tab(
                  icon: const Icon(Icons.delete_outline_rounded),
                  text: provider.languageCode == 'en' ? 'Trash (${trashedNotes.length})' : 'Sampah (${trashedNotes.length})',
                ),
                Tab(
                  icon: const Icon(Icons.archive_outlined),
                  text: provider.languageCode == 'en' ? 'Archive (${archivedNotes.length})' : 'Arsip (${archivedNotes.length})',
                ),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildNotesList(context, trashedNotes, provider, isTrash: true),
              _buildNotesList(context, archivedNotes, provider, isTrash: false),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotesList(BuildContext context, List<Note> notes, NoteProvider provider, {required bool isTrash}) {
    if (notes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isTrash ? Icons.delete_sweep_outlined : Icons.archive_outlined,
              size: 64,
              color: AppTheme.textSecondary.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              isTrash
                  ? (provider.languageCode == 'en' ? 'Trash is empty' : 'Tempat Sampah kosong')
                  : (provider.languageCode == 'en' ? 'No archived notes' : 'Tidak ada catatan diarsipkan'),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textSecondary.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        final auraColor = AppTheme.getColorForCategory(note.category);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: AppTheme.glassDecoration(auraColor: auraColor),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            note.title.isEmpty ? (provider.languageCode == 'en' ? 'Untitled Note' : 'Catatan Tanpa Judul') : note.title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: auraColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            note.category,
                            style: TextStyle(fontSize: 10, color: auraColor, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    if (note.content.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        note.content,
                        style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.4),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          _formatDate(note.dateModified),
                          style: TextStyle(fontSize: 10, color: AppTheme.textSecondary.withOpacity(0.5)),
                        ),
                        const Spacer(),
                        if (isTrash) ...[
                          // Restore button
                          _buildActionChip(
                            icon: Icons.restore_rounded,
                            label: provider.languageCode == 'en' ? 'Restore' : 'Pulihkan',
                            color: const Color(0xFF00FF87),
                            onTap: () {
                              provider.restoreFromTrash(note.id);
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(provider.languageCode == 'en' ? 'Note restored' : 'Catatan dipulihkan'),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: AppTheme.surface,
                              ));
                            },
                          ),
                          const SizedBox(width: 8),
                          // Delete permanently
                          _buildActionChip(
                            icon: Icons.delete_forever_rounded,
                            label: provider.languageCode == 'en' ? 'Delete' : 'Hapus',
                            color: Colors.redAccent,
                            onTap: () {
                              provider.deletePermanently(note.id);
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(provider.languageCode == 'en' ? 'Note permanently deleted' : 'Catatan dihapus permanen'),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: AppTheme.surface,
                              ));
                            },
                          ),
                        ] else ...[
                          // Unarchive
                          _buildActionChip(
                            icon: Icons.unarchive_rounded,
                            label: provider.languageCode == 'en' ? 'Unarchive' : 'Buka Arsip',
                            color: AppTheme.accent,
                            onTap: () {
                              provider.toggleArchive(note.id);
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(provider.languageCode == 'en' ? 'Note unarchived' : 'Catatan dibuka dari arsip'),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: AppTheme.surface,
                              ));
                            },
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionChip({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3), width: 0.8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
