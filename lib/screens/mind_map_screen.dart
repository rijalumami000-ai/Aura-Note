import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/note.dart';
import '../theme/app_theme.dart';

class MindMapNode {
  final String id;
  String label;
  Offset position;
  final Color color;
  final String type; // 'root', 'branch_ai', 'branch_todo', 'branch_content', 'custom'

  MindMapNode({
    required this.id,
    required this.label,
    required this.position,
    required this.color,
    required this.type,
  });
}

class MindMapLink {
  final String parentId;
  final String childId;

  MindMapLink(this.parentId, this.childId);
}

class MindMapScreen extends StatefulWidget {
  final Note note;

  const MindMapScreen({super.key, required this.note});

  @override
  State<MindMapScreen> createState() => _MindMapScreenState();
}

class _MindMapScreenState extends State<MindMapScreen> {
  final List<MindMapNode> _nodes = [];
  final List<MindMapLink> _links = [];
  String? _draggedNodeId;
  final TransformationController _transformationController = TransformationController();

  @override
  void initState() {
    super.initState();
    _buildMindMap();
  }

  // Populate node coordinates and links dynamically from the note content
  void _buildMindMap() {
    final auraColor = AppTheme.getColorForCategory(widget.note.category);
    
    // 1. Root Node (Center)
    final rootId = 'root';
    _nodes.add(MindMapNode(
      id: rootId,
      label: widget.note.title.isEmpty ? 'Catatan Utama' : widget.note.title,
      position: const Offset(400, 300),
      color: auraColor,
      type: 'root',
    ));

    double angleStep = 0.0;
    int branchesCount = 0;
    if (widget.note.aiSummary != null && widget.note.aiSummary!.isNotEmpty) branchesCount++;
    if (widget.note.todos.isNotEmpty) branchesCount++;
    if (widget.note.content.isNotEmpty) branchesCount++;
    
    if (branchesCount > 0) {
      angleStep = (2 * math.pi) / branchesCount;
    }

    int branchIndex = 0;
    final double radius = 160.0;

    // 2. AI Summary Branch
    if (widget.note.aiSummary != null && widget.note.aiSummary!.isNotEmpty) {
      final double angle = branchIndex * angleStep;
      final branchId = 'branch_ai';
      final branchPos = Offset(
        400 + radius * math.cos(angle),
        300 + radius * math.sin(angle),
      );

      _nodes.add(MindMapNode(
        id: branchId,
        label: 'AuraAI Ringkasan',
        position: branchPos,
        color: AppTheme.accent,
        type: 'branch_ai',
      ));
      _links.add(MindMapLink(rootId, branchId));

      // Sub-nodes from AI Summary bullets
      final summaryLines = widget.note.aiSummary!
          .split('\n')
          .where((l) => l.trim().startsWith('-') || l.trim().startsWith('•') || l.trim().isNotEmpty)
          .take(3)
          .toList();

      for (int i = 0; i < summaryLines.length; i++) {
        final subId = 'ai_sub_$i';
        final double subAngle = angle - 0.4 + (i * 0.4);
        final subPos = Offset(
          branchPos.dx + 110 * math.cos(subAngle),
          branchPos.dy + 110 * math.sin(subAngle),
        );

        String cleanLine = summaryLines[i].replaceAll(RegExp(r'^[-•*\s]+'), '');
        if (cleanLine.length > 25) cleanLine = '${cleanLine.substring(0, 22)}...';

        _nodes.add(MindMapNode(
          id: subId,
          label: cleanLine,
          position: subPos,
          color: AppTheme.accent.withOpacity(0.7),
          type: 'branch_ai',
        ));
        _links.add(MindMapLink(branchId, subId));
      }
      branchIndex++;
    }

    // 3. Todos/Tasks Branch
    if (widget.note.todos.isNotEmpty) {
      final double angle = branchIndex * angleStep;
      final branchId = 'branch_todo';
      final branchPos = Offset(
        400 + radius * math.cos(angle),
        300 + radius * math.sin(angle),
      );

      _nodes.add(MindMapNode(
        id: branchId,
        label: 'Daftar Tugas',
        position: branchPos,
        color: const Color(0xFF00F2FE),
        type: 'branch_todo',
      ));
      _links.add(MindMapLink(rootId, branchId));

      // Sub-nodes from Todos
      final todosToRender = widget.note.todos.take(3).toList();
      for (int i = 0; i < todosToRender.length; i++) {
        final todo = todosToRender[i];
        final subId = 'todo_sub_$i';
        final double subAngle = angle - 0.4 + (i * 0.4);
        final subPos = Offset(
          branchPos.dx + 110 * math.cos(subAngle),
          branchPos.dy + 110 * math.sin(subAngle),
        );

        String cleanText = todo.title.isEmpty ? 'Tugas Kosong' : todo.title;
        if (cleanText.length > 20) cleanText = '${cleanText.substring(0, 18)}...';

        _nodes.add(MindMapNode(
          id: subId,
          label: cleanText,
          position: subPos,
          color: todo.isDone ? Colors.greenAccent : const Color(0xFF00F2FE).withOpacity(0.7),
          type: 'branch_todo',
        ));
        _links.add(MindMapLink(branchId, subId));
      }
      branchIndex++;
    }

    // 4. Content / Notes Branch
    if (widget.note.content.isNotEmpty) {
      final double angle = branchIndex * angleStep;
      final branchId = 'branch_content';
      final branchPos = Offset(
        400 + radius * math.cos(angle),
        300 + radius * math.sin(angle),
      );

      _nodes.add(MindMapNode(
        id: branchId,
        label: 'Isi Catatan',
        position: branchPos,
        color: Colors.amberAccent,
        type: 'branch_content',
      ));
      _links.add(MindMapLink(rootId, branchId));

      // Extract brief snippets
      String snip = widget.note.content;
      if (snip.length > 30) snip = '${snip.substring(0, 28)}...';

      final subId = 'content_sub';
      final subPos = Offset(
        branchPos.dx + 110 * math.cos(angle),
        branchPos.dy + 110 * math.sin(angle),
      );

      _nodes.add(MindMapNode(
        id: subId,
        label: snip,
        position: subPos,
        color: Colors.amberAccent.withOpacity(0.7),
        type: 'branch_content',
      ));
      _links.add(MindMapLink(branchId, subId));
    }
  }

  // Handle addition of custom node ideas
  void _addCustomNode() {
    final TextEditingController ideaController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AlertDialog(
            backgroundColor: AppTheme.surface.withOpacity(0.9),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: Colors.white.withOpacity(0.08)),
            ),
            title: const Text(
              'Tambah Ide Kustom',
              style: TextStyle(color: Colors.white, fontFamily: 'Outfit', fontWeight: FontWeight.bold),
            ),
            content: TextField(
              controller: ideaController,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Tulis ide atau pemikiran baru...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.accent)),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal', style: TextStyle(color: AppTheme.textSecondary)),
              ),
              ElevatedButton(
                onPressed: () {
                  final text = ideaController.text.trim();
                  if (text.isNotEmpty) {
                    setState(() {
                      final newId = 'custom_${DateTime.now().millisecondsSinceEpoch}';
                      // Spawn close to the root
                      final double randAngle = math.Random().nextDouble() * 2 * math.pi;
                      final newPos = Offset(
                        400 + 130 * math.cos(randAngle),
                        300 + 130 * math.sin(randAngle),
                      );

                      _nodes.add(MindMapNode(
                        id: newId,
                        label: text,
                        position: newPos,
                        color: Colors.purpleAccent,
                        type: 'custom',
                      ));
                      _links.add(MindMapLink('root', newId));
                    });
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Tambah', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final auraColor = AppTheme.getColorForCategory(widget.note.category);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AuraMind Peta Pikiran', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Infinite grid-like panning viewer
          InteractiveViewer(
            transformationController: _transformationController,
            boundaryMargin: const EdgeInsets.all(500),
            minScale: 0.5,
            maxScale: 2.5,
            child: GestureDetector(
              onPanStart: (details) {
                // Find local coordinates inside the viewer
                final RenderBox box = context.findRenderObject() as RenderBox;
                final localTouch = box.globalToLocal(details.globalPosition);
                // Adjust for zoom matrix offsets
                final matrix = _transformationController.value;
                final double scale = matrix.getMaxScaleOnAxis();
                final double translationX = matrix.entry(0, 3);
                final double translationY = matrix.entry(1, 3);
                
                final adjustedTouch = Offset(
                  (localTouch.dx - translationX) / scale,
                  (localTouch.dy - translationY) / scale,
                );

                // Detect node hit
                String? hitId;
                for (var node in _nodes) {
                  final dist = (node.position - adjustedTouch).distance;
                  if (dist < 45) { // Radius of touch recognition
                    hitId = node.id;
                    break;
                  }
                }

                if (hitId != null) {
                  setState(() {
                    _draggedNodeId = hitId;
                  });
                }
              },
              onPanUpdate: (details) {
                if (_draggedNodeId != null) {
                  final matrix = _transformationController.value;
                  final double scale = matrix.getMaxScaleOnAxis();
                  setState(() {
                    final node = _nodes.firstWhere((n) => n.id == _draggedNodeId);
                    // Adjust node position relative to details delta and scale
                    node.position += details.delta / scale;
                  });
                }
              },
              onPanEnd: (_) {
                setState(() {
                  _draggedNodeId = null;
                });
              },
              child: Container(
                width: 900,
                height: 700,
                color: const Color(0xFF03030F), // Deep cosmic background
                child: CustomPaint(
                  painter: MindMapPainter(
                    nodes: _nodes,
                    links: _links,
                    accentColor: auraColor,
                  ),
                ),
              ),
            ),
          ),

          // Action Info Overlay
          Positioned(
            top: 10,
            left: 20,
            right: 20,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  color: Colors.white.withOpacity(0.02),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppTheme.accent, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Seret bulatan untuk menata ide. Gunakan gestur dua jari untuk cubit-zoom dan geser kanvas.',
                          style: TextStyle(fontSize: 10, color: AppTheme.textSecondary.withOpacity(0.8), fontFamily: 'Outfit'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // FAB to add custom idea node
          Positioned(
            bottom: 30,
            right: 24,
            child: FloatingActionButton.extended(
              onPressed: _addCustomNode,
              backgroundColor: auraColor,
              icon: const Icon(Icons.add, color: Colors.black),
              label: const Text(
                'Ide Baru',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Mind Map Custom Painter to render lines and neon glowing nodes
class MindMapPainter extends CustomPainter {
  final List<MindMapNode> nodes;
  final List<MindMapLink> links;
  final Color accentColor;

  MindMapPainter({
    required this.nodes,
    required this.links,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw Links (bezier curves)
    final linkPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (var link in links) {
      final parent = nodes.firstWhere((n) => n.id == link.parentId);
      final child = nodes.firstWhere((n) => n.id == link.childId);

      // Create curvy bezier link line
      final path = Path();
      path.moveTo(parent.position.dx, parent.position.dy);
      
      final controlPoint1 = Offset(
        parent.position.dx + (child.position.dx - parent.position.dx) / 2,
        parent.position.dy,
      );
      final controlPoint2 = Offset(
        parent.position.dx + (child.position.dx - parent.position.dx) / 2,
        child.position.dy,
      );
      
      path.cubicTo(
        controlPoint1.dx, controlPoint1.dy,
        controlPoint2.dx, controlPoint2.dy,
        child.position.dx, child.position.dy,
      );

      // Draw connection with glowing color matching child node
      canvas.drawPath(
        path,
        linkPaint..color = child.color.withOpacity(0.35)..strokeWidth = 2.0,
      );
    }

    // 2. Draw Nodes
    for (var node in nodes) {
      final double radius = node.type == 'root' ? 44.0 : 34.0;

      // Glow Shadow Paint
      final glowPaint = Paint()
        ..color = node.color.withOpacity(0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      canvas.drawCircle(node.position, radius + 4, glowPaint);

      // Solid Outer border
      final borderPaint = Paint()
        ..color = node.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(node.position, radius, borderPaint);

      // Core Background
      final fillPaint = Paint()
        ..color = const Color(0xFF0C0C1E).withOpacity(0.85)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(node.position, radius - 1.0, fillPaint);

      // Draw Node Label Text
      final textSpan = TextSpan(
        text: node.label,
        style: TextStyle(
          fontSize: node.type == 'root' ? 10 : 8.5,
          color: Colors.white,
          fontFamily: 'Outfit',
          fontWeight: node.type == 'root' ? FontWeight.bold : FontWeight.normal,
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
        maxLines: 2,
        ellipsis: '..',
      );
      textPainter.layout(maxWidth: radius * 1.7);
      
      // Center the text inside the node circle
      textPainter.paint(
        canvas,
        Offset(
          node.position.dx - (textPainter.width / 2),
          node.position.dy - (textPainter.height / 2),
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant MindMapPainter oldDelegate) => true;
}
