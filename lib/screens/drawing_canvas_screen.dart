import 'package:flutter/material.dart';
import '../models/note.dart';
import '../theme/app_theme.dart';

class DrawingCanvasScreen extends StatefulWidget {
  final List<DrawingStroke> initialStrokes;
  final String category;

  const DrawingCanvasScreen({
    super.key,
    required this.initialStrokes,
    required this.category,
  });

  @override
  State<DrawingCanvasScreen> createState() => _DrawingCanvasScreenState();
}

class _DrawingCanvasScreenState extends State<DrawingCanvasScreen> {
  late List<DrawingStroke> _strokes;
  List<DrawingPoint> _currentPoints = [];
  late Color _selectedColor;
  double _strokeWidth = 4.0;

  // Neon colors palette
  final List<Color> _neonColors = [
    const Color(0xFF00FF87), // Neon Green
    const Color(0xFF00F2FE), // Neon Cyan
    const Color(0xFF8A2BE2), // Neon Purple
    const Color(0xFFFF007F), // Neon Pink
    const Color(0xFFFFD700), // Neon Gold
    Colors.white,
  ];

  @override
  void initState() {
    super.initState();
    _strokes = List.from(widget.initialStrokes);
    _selectedColor = AppTheme.getColorForCategory(widget.category);
    // Ensure category color is in the palette or set a default neon color
    if (!_neonColors.contains(_selectedColor)) {
      _selectedColor = _neonColors.first;
    }
  }

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _currentPoints = [DrawingPoint(details.localPosition.dx, details.localPosition.dy)];
      _strokes.add(DrawingStroke(
        points: _currentPoints,
        colorValue: _selectedColor.value,
        strokeWidth: _strokeWidth,
      ));
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _currentPoints.add(DrawingPoint(details.localPosition.dx, details.localPosition.dy));
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _currentPoints = [];
    });
  }

  void _undo() {
    if (_strokes.isNotEmpty) {
      setState(() {
        _strokes.removeLast();
      });
    }
  }

  void _clearCanvas() {
    setState(() {
      _strokes.clear();
      _currentPoints.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AuraDraw Kanvas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.undo, color: AppTheme.textPrimary),
            tooltip: 'Undo',
            onPressed: _undo,
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: Colors.redAccent),
            tooltip: 'Reset Kanvas',
            onPressed: _clearCanvas,
          ),
          IconButton(
            icon: const Icon(Icons.check, color: Colors.greenAccent),
            tooltip: 'Simpan Gambar',
            onPressed: () {
              Navigator.pop(context, _strokes);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // The Interactive Drawing Area
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _selectedColor.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: GestureDetector(
                  onPanStart: _onPanStart,
                  onPanUpdate: _onPanUpdate,
                  onPanEnd: _onPanEnd,
                  child: CustomPaint(
                    painter: SketchPainter(strokes: _strokes),
                    size: Size.infinite,
                  ),
                ),
              ),
            ),
          ),

          // Tools Panel (Colors & Brush Width)
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
            decoration: BoxDecoration(
              color: AppTheme.surface.withOpacity(0.9),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              border: Border.all(color: Colors.white.withOpacity(0.04)),
            ),
            child: Column(
              children: [
                // Width selection slider
                Row(
                  children: [
                    const Icon(Icons.brush, size: 16, color: AppTheme.textSecondary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Slider(
                        value: _strokeWidth,
                        min: 2.0,
                        max: 15.0,
                        activeColor: _selectedColor,
                        inactiveColor: Colors.white.withOpacity(0.05),
                        onChanged: (val) {
                          setState(() {
                            _strokeWidth = val;
                          });
                        },
                      ),
                    ),
                    Text(
                      '${_strokeWidth.toInt()}px',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Color Selection row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: _neonColors.map((color) {
                    final isSelected = _selectedColor == color;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedColor = color;
                        });
                      },
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? Colors.white : Colors.transparent,
                            width: 2.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(0.4),
                              blurRadius: 8,
                              spreadRadius: isSelected ? 1 : -1,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter to render paths smoothly with Neon glow effects
class SketchPainter extends CustomPainter {
  final List<DrawingStroke> strokes;

  SketchPainter({required this.strokes});

  @override
  void paint(Canvas canvas, Size size) {
    for (var stroke in strokes) {
      if (stroke.points.length < 2) continue;

      final color = Color(stroke.colorValue);
      
      // Draw outer blur/glow first
      final glowPaint = Paint()
        ..color = color.withOpacity(0.3)
        ..strokeCap = StrokeCap.round
        ..strokeWidth = stroke.strokeWidth * 2.5
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.5);

      final path = Path();
      path.moveTo(stroke.points[0].x, stroke.points[0].y);

      for (int i = 1; i < stroke.points.length; i++) {
        path.lineTo(stroke.points[i].x, stroke.points[i].y);
      }
      
      canvas.drawPath(path, glowPaint);

      // Draw the main sharp stroke on top
      final corePaint = Paint()
        ..color = color
        ..strokeCap = StrokeCap.round
        ..strokeWidth = stroke.strokeWidth
        ..style = PaintingStyle.stroke;

      canvas.drawPath(path, corePaint);
    }
  }

  @override
  bool shouldRepaint(covariant SketchPainter oldDelegate) => true;
}
