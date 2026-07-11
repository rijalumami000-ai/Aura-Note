import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../providers/note_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/aura_lock_dialog.dart';
import '../widgets/note_card.dart';
import '../utils/translation_helper.dart';
import 'note_editor_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isGridView = false; // Grid view vs List view toggle
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NoteProvider>(
      builder: (context, noteProvider, child) {
        final pinnedNotes = noteProvider.pinnedNotes;
        final activeNotes = noteProvider.activeNotes;
        final hasNotes = pinnedNotes.isNotEmpty || activeNotes.isNotEmpty;

        return Scaffold(
          body: Stack(
            children: [
              // Cosmic background glow effect
              Positioned(
                top: -150,
                right: -100,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accent.withOpacity(0.15),
                        blurRadius: 120,
                        spreadRadius: 30,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: -100,
                left: -100,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00F2FE).withOpacity(0.08),
                        blurRadius: 100,
                        spreadRadius: 30,
                      ),
                    ],
                  ),
                ),
              ),

              // Main content
              SafeArea(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // Custom App Bar / Header
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getGreeting(),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'AuraNote',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.5,
                                      ),
                                ),
                              ],
                            ),
                            // Toggle Grid/List view
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _isGridView = !_isGridView;
                                });
                              },
                              style: IconButton.styleFrom(
                                backgroundColor: AppTheme.surface.withOpacity(0.6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(color: Colors.white.withOpacity(0.08)),
                                ),
                              ),
                              icon: Icon(
                                _isGridView ? Icons.view_list : Icons.grid_view,
                                color: AppTheme.textPrimary,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Search Bar
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppTheme.surface.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.08),
                              width: 1.0,
                            ),
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (val) {
                              noteProvider.setSearchQuery(val);
                            },
                            style: const TextStyle(color: AppTheme.textPrimary),
                            decoration: InputDecoration(
                              hintText: TranslationHelper.translateReactive(context, 'search_hint'),
                              hintStyle: TextStyle(color: AppTheme.textSecondary.withOpacity(0.5)),
                              prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, color: AppTheme.textSecondary),
                                      onPressed: () {
                                        _searchController.clear();
                                        noteProvider.setSearchQuery('');
                                      },
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Category Horizontal list
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              _buildCategoryTab('Semua', noteProvider),
                              ...AppTheme.categoryGradients.keys.map(
                                (cat) => _buildCategoryTab(cat, noteProvider),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Pinned Notes Header & Grid/List
                    if (pinnedNotes.isNotEmpty) ...[
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                          child: Row(
                            children: [
                              const Icon(Icons.push_pin, size: 16, color: AppTheme.accent),
                              const SizedBox(width: 8),
                              Text(
                                TranslationHelper.translateReactive(context, 'section_pinned'),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                  color: AppTheme.accent.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      _buildNotesLayout(pinnedNotes, noteProvider),
                    ],

                    // Active Notes Header & Grid/List
                    if (activeNotes.isNotEmpty) ...[
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                          child: Text(
                            pinnedNotes.isNotEmpty
                                ? (TranslationHelper.translateReactive(context, 'tab_notes').toUpperCase() + 
                                    (noteProvider.languageCode == 'en' ? ' OTHERS' : ' LAINNYA'))
                                : TranslationHelper.translateReactive(context, 'section_all'),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              color: AppTheme.textSecondary.withOpacity(0.8),
                            ),
                          ),
                        ),
                      ),
                      _buildNotesLayout(activeNotes, noteProvider),
                    ],

                    // Empty State
                    if (!hasNotes && !noteProvider.isLoading)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(40),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: AppTheme.accent.withOpacity(0.08),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppTheme.accent.withOpacity(0.3),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.notes_rounded,
                                    size: 40,
                                    color: AppTheme.accent,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  noteProvider.searchQuery.isNotEmpty
                                      ? 'Tidak menemukan hasil'
                                      : 'Belum ada catatan di kategori ini',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  noteProvider.searchQuery.isNotEmpty
                                      ? 'Coba gunakan kata kunci pencarian yang lain.'
                                      : 'Tuliskan ide cemerlang, rencana, atau pekerjaanmu hari ini menggunakan tombol tambah di bawah!',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.textSecondary,
                                    height: 1.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    // Add bottom padding
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 100),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Floating Action Button
          floatingActionButton: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accent.withOpacity(0.4),
                  blurRadius: 18,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.accent, Color(0xFFC71585)], // Violet to Medium Violet Red
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NoteEditorScreen(),
                      ),
                    );
                  },
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  highlightElevation: 0,
                  child: const Icon(Icons.add, color: Colors.white, size: 28),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Greeting helper based on hour
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat pagi ☀️';
    if (hour < 15) return 'Selamat siang 🌤️';
    if (hour < 19) return 'Selamat sore 🌅';
    return 'Selamat malam 🌙';
  }

  // Helper widget to build horizontal category tabs
  Widget _buildCategoryTab(String category, NoteProvider provider) {
    final isSelected = provider.selectedCategory == category;
    final themeColor = category == 'Semua'
        ? AppTheme.accent
        : AppTheme.getColorForCategory(category);

    return Container(
      margin: const EdgeInsets.only(right: 10),
      child: InkWell(
        onTap: () {
          provider.setSelectedCategory(category);
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? themeColor.withOpacity(0.18)
                : AppTheme.surface.withOpacity(0.5),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? themeColor.withOpacity(0.7) : Colors.white.withOpacity(0.08),
              width: isSelected ? 1.5 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: themeColor.withOpacity(0.12),
                      blurRadius: 10,
                      spreadRadius: -2,
                    )
                  ]
                : null,
          ),
          child: Text(
            category,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? themeColor : AppTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  // Dynamic layout builder: Grid or List with swipe actions
  Widget _buildNotesLayout(List<Note> notes, NoteProvider provider) {
    if (_isGridView) {
      // Masonry-like 2 column grid
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverGrid(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final note = notes[index];
              return _buildDismissibleNote(note, provider);
            },
            childCount: notes.length,
          ),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
        ),
      );
    } else {
      // Standard list view
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final note = notes[index];
              return _buildDismissibleNote(note, provider);
            },
            childCount: notes.length,
          ),
        ),
      );
    }
  }

  // Wrapping notes in Dismissible for smooth swipe-to-delete & swipe-to-archive gestures
  Widget _buildDismissibleNote(Note note, NoteProvider provider) {
    return Dismissible(
      key: Key(note.id),
      direction: DismissDirection.horizontal,
      onDismissed: (direction) async {
        if (direction == DismissDirection.endToStart) {
          // Swipe Left -> Move to Trash
          await provider.moveToTrash(note.id);
          if (mounted) {
            _showSnackBar(
              'Catatan dipindahkan ke Tempat Sampah',
              () => provider.restoreFromTrash(note.id),
            );
          }
        } else if (direction == DismissDirection.startToEnd) {
          // Swipe Right -> Archive
          await provider.toggleArchive(note.id);
          if (mounted) {
            _showSnackBar(
              'Catatan diarsipkan',
              () => provider.toggleArchive(note.id),
            );
          }
        }
      },
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
          color: Colors.blueAccent.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
        ),
        child: const Icon(Icons.archive_outlined, color: Colors.blueAccent, size: 28),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 28),
      ),
      child: NoteCard(
        note: note,
        onTap: () {
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
        },
      ),
    );
  }

  // SnackBar notification with Undo button
  void _showSnackBar(String message, VoidCallback onUndo) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: AppTheme.textPrimary, fontFamily: 'Outfit'),
        ),
        backgroundColor: AppTheme.surface.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        action: SnackBarAction(
          label: 'BATAL',
          textColor: AppTheme.accent,
          onPressed: onUndo,
        ),
      ),
    );
  }
}
