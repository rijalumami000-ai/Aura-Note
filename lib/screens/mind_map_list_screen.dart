import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../providers/note_provider.dart';
import '../theme/app_theme.dart';
import 'mind_map_screen.dart';

class MindMapListScreen extends StatefulWidget {
  const MindMapListScreen({super.key});

  @override
  State<MindMapListScreen> createState() => _MindMapListScreenState();
}

class _MindMapListScreenState extends State<MindMapListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NoteProvider>(
      builder: (context, provider, child) {
        // Ambil semua catatan berkategori "MindMap" yang tidak sedang di sampah
        final mindmapNotes = provider.notes
            .where((n) => n.category == 'MindMap' && !n.isTrashed)
            .where((n) {
              if (_searchQuery.trim().isEmpty) return true;
              return n.title.toLowerCase().contains(_searchQuery.toLowerCase());
            })
            .toList();

        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'AuraMind Galeri',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontFamily: 'Outfit',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: Stack(
            children: [
              // Backdrop glow
              Positioned(
                top: -100,
                right: -100,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accent.withOpacity(0.08),
                        blurRadius: 100,
                        spreadRadius: 20,
                      ),
                    ],
                  ),
                ),
              ),

              Column(
                children: [
                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
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
                          setState(() {
                            _searchQuery = val;
                          });
                        },
                        style: const TextStyle(color: AppTheme.textPrimary),
                        decoration: InputDecoration(
                          hintText: provider.languageCode == 'en'
                              ? 'Search mind maps...'
                              : 'Cari peta pikiran...',
                          hintStyle: TextStyle(color: AppTheme.textSecondary.withOpacity(0.5)),
                          prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                  ),

                  // Grid view
                  Expanded(
                    child: mindmapNotes.isEmpty
                        ? _buildEmptyState(provider)
                        : GridView.builder(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 14,
                              childAspectRatio: 1.15,
                            ),
                            itemCount: mindmapNotes.length,
                            itemBuilder: (context, index) {
                              final note = mindmapNotes[index];
                              return _buildMindMapCard(context, note, provider);
                            },
                          ),
                  ),
                ],
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MindMapScreen(),
                ),
              );
            },
            backgroundColor: AppTheme.accent,
            icon: const Icon(Icons.add, color: Colors.black),
            label: Text(
              provider.languageCode == 'en' ? 'New Map' : 'Peta Baru',
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(NoteProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.hub_outlined,
            size: 64,
            color: AppTheme.textSecondary.withOpacity(0.15),
          ),
          const SizedBox(height: 16),
          Text(
            provider.languageCode == 'en'
                ? 'No Peta Pikiran found'
                : 'Belum ada Peta Pikiran',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textSecondary.withOpacity(0.6),
              fontFamily: 'Outfit',
            ),
          ),
          const SizedBox(height: 6),
          Text(
            provider.languageCode == 'en'
                ? 'Create one by clicking the + button below'
                : 'Buat baru dengan mengetuk tombol + di bawah',
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.textSecondary.withOpacity(0.4),
              fontFamily: 'Outfit',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMindMapCard(BuildContext context, Note note, NoteProvider provider) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          decoration: AppTheme.glassDecoration(auraColor: AppTheme.accent),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MindMapScreen(note: note),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.hub_outlined, color: AppTheme.accent, size: 20),
                      Icon(Icons.open_in_new_rounded, color: AppTheme.textSecondary, size: 14),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    note.title.isEmpty
                        ? (provider.languageCode == 'en' ? 'Untitled Map' : 'Peta Tanpa Judul')
                        : note.title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Outfit',
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${note.dateModified.day}/${note.dateModified.month}/${note.dateModified.year}',
                    style: TextStyle(
                      fontSize: 9,
                      color: AppTheme.textSecondary.withOpacity(0.5),
                      fontFamily: 'Outfit',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
