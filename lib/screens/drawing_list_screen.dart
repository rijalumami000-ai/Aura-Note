import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../providers/note_provider.dart';
import '../theme/app_theme.dart';
import 'drawing_canvas_screen.dart';

class DrawingListScreen extends StatefulWidget {
  const DrawingListScreen({super.key});

  @override
  State<DrawingListScreen> createState() => _DrawingListScreenState();
}

class _DrawingListScreenState extends State<DrawingListScreen> {
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
        // Ambil semua catatan berkategori "Drawing" yang tidak di sampah
        final drawingNotes = provider.notes
            .where((n) => n.category == 'Drawing' && !n.isTrashed)
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
              'AuraDraw Galeri',
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
                bottom: -100,
                left: -100,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00FF87).withOpacity(0.06),
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
                              ? 'Search drawings...'
                              : 'Cari gambar sketsa...',
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
                    child: drawingNotes.isEmpty
                        ? _buildEmptyState(provider)
                        : GridView.builder(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 14,
                              childAspectRatio: 0.90, // Lebih tinggi sedikit untuk memberi ruang preview + teks
                            ),
                            itemCount: drawingNotes.length,
                            itemBuilder: (context, index) {
                              final note = drawingNotes[index];
                              return _buildDrawingCard(context, note, provider);
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
                  builder: (context) => const DrawingCanvasScreen(
                    isStandalone: true,
                  ),
                ),
              );
            },
            backgroundColor: const Color(0xFF00FF87),
            icon: const Icon(Icons.brush, color: Colors.black),
            label: Text(
              provider.languageCode == 'en' ? 'New Sketch' : 'Sketsa Baru',
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
            Icons.brush_outlined,
            size: 64,
            color: AppTheme.textSecondary.withOpacity(0.15),
          ),
          const SizedBox(height: 16),
          Text(
            provider.languageCode == 'en'
                ? 'No drawings found'
                : 'Belum ada gambar sketsa',
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
                ? 'Create one by clicking the brush button below'
                : 'Buat baru dengan mengetuk tombol kuas di bawah',
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

  Widget _buildDrawingCard(BuildContext context, Note note, NoteProvider provider) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          decoration: AppTheme.glassDecoration(auraColor: const Color(0xFF00FF87)),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DrawingCanvasScreen(
                    note: note,
                    initialStrokes: note.sketchStrokes,
                    category: note.category,
                    isStandalone: true,
                  ),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Real coretan drawing mini preview canvas!
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(12, 12, 12, 6),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withOpacity(0.04)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: CustomPaint(
                        painter: MiniSketchPainter(strokes: note.sketchStrokes),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        note.title.isEmpty
                            ? (provider.languageCode == 'en' ? 'Untitled Sketch' : 'Sketsa Tanpa Judul')
                            : note.title,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Outfit',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Mini Sketch Painter to draw drawing strokes proportionally scaled inside the grid card
class MiniSketchPainter extends CustomPainter {
  final List<DrawingStroke> strokes;

  MiniSketchPainter({required this.strokes});

  @override
  void paint(Canvas canvas, Size size) {
    if (strokes.isEmpty) return;

    double minX = double.infinity;
    double maxX = double.negativeInfinity;
    double minY = double.infinity;
    double maxY = double.negativeInfinity;

    for (var stroke in strokes) {
      for (var pt in stroke.points) {
        if (pt.x < minX) minX = pt.x;
        if (pt.x > maxX) maxX = pt.x;
        if (pt.y < minY) minY = pt.y;
        if (pt.y > maxY) maxY = pt.y;
      }
    }

    if (minX == double.infinity) return;

    double contentWidth = maxX - minX;
    double contentHeight = maxY - minY;
    if (contentWidth == 0) contentWidth = 1;
    if (contentHeight == 0) contentHeight = 1;

    // Calculate dynamic fitting scale factor
    final double scaleX = (size.width - 20) / contentWidth;
    final double scaleY = (size.height - 20) / contentHeight;
    final double scale = math.min(scaleX, scaleY);

    canvas.save();
    // Center alignment translate
    canvas.translate(
      (size.width - contentWidth * scale) / 2 - minX * scale,
      (size.height - contentHeight * scale) / 2 - minY * scale,
    );
    canvas.scale(scale);

    for (var stroke in strokes) {
      if (stroke.points.length < 2) continue;

      final color = Color(stroke.colorValue);
      final paint = Paint()
        ..color = color
        ..strokeCap = StrokeCap.round
        // Scale down stroke width for micro-preview
        ..strokeWidth = math.max(1.0, stroke.strokeWidth * 0.4)
        ..style = PaintingStyle.stroke;

      final path = Path();
      path.moveTo(stroke.points[0].x, stroke.points[0].y);

      for (int i = 1; i < stroke.points.length; i++) {
        path.lineTo(stroke.points[i].x, stroke.points[i].y);
      }
      canvas.drawPath(path, paint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant MiniSketchPainter oldDelegate) => true;
}
