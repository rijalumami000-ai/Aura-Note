import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../providers/note_provider.dart';
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
  final Note? note;

  const MindMapScreen({super.key, this.note});

  @override
  State<MindMapScreen> createState() => _MindMapScreenState();
}

class _MindMapScreenState extends State<MindMapScreen> with SingleTickerProviderStateMixin {
  final List<MindMapNode> _nodes = [];
  final List<MindMapLink> _links = [];
  final TransformationController _transformationController = TransformationController();
  
  late Note _currentNote;
  bool _isNewMindMap = false;

  @override
  void initState() {
    super.initState();
    
    // Inisialisasi Note (Mandiri vs Terikat)
    if (widget.note != null) {
      _currentNote = widget.note!;
    } else {
      _isNewMindMap = true;
      _currentNote = Note(
        id: 'mindmap_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Peta Pikiran AuraMind',
        content: '',
        category: 'MindMap',
        dateCreated: DateTime.now(),
        dateModified: DateTime.now(),
      );
    }

    _buildMindMap();

    // Set initial zoom/translation agar root node berada di tengah layar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _centerOnRoot();
    });
  }

  void _centerOnRoot() {
    final size = MediaQuery.of(context).size;
    final double scale = 0.9;
    
    // Posisi root adalah (1250, 1000). Kita posisikan di tengah viewport screen
    final double tx = (size.width / 2) - (1250 * scale);
    final double ty = ((size.height - 80) / 2) - (1000 * scale);

    _transformationController.value = Matrix4.identity()
      ..translate(tx, ty)
      ..scale(scale);
  }

  // Populate node coordinates and links dynamically
  void _buildMindMap() {
    final auraColor = AppTheme.getColorForCategory(_currentNote.category);
    final double centerX = 1250.0;
    final double centerY = 1000.0;

    // 1. Cek apakah content berisi database JSON MindMap yang tersimpan
    if (_currentNote.content.startsWith('{"nodes":')) {
      try {
        final data = jsonDecode(_currentNote.content);
        final List<dynamic> nodesJson = data['nodes'];
        final List<dynamic> linksJson = data['links'];

        _nodes.clear();
        _links.clear();

        for (var n in nodesJson) {
          _nodes.add(MindMapNode(
            id: n['id'],
            label: n['label'],
            position: Offset(n['dx'], n['dy']),
            color: Color(n['color']),
            type: n['type'],
          ));
        }

        for (var l in linksJson) {
          _links.add(MindMapLink(l['parentId'], l['childId']));
        }
        return; // Peta pikiran berhasil di-restore!
      } catch (e) {
        debugPrint('Gagal deserialize, fallback ke parser: $e');
      }
    }

    // 2. Parser fallback (ekstrak konten catatan ke visual MindMap)
    final rootId = 'root';
    _nodes.add(MindMapNode(
      id: rootId,
      label: _currentNote.title.isEmpty ? 'Catatan Utama' : _currentNote.title,
      position: Offset(centerX, centerY),
      color: auraColor,
      type: 'root',
    ));

    double angleStep = 0.0;
    int branchesCount = 0;
    if (_currentNote.aiSummary != null && _currentNote.aiSummary!.isNotEmpty) branchesCount++;
    if (_currentNote.todos.isNotEmpty) branchesCount++;
    if (_currentNote.content.isNotEmpty && !_currentNote.content.startsWith('{"nodes":')) branchesCount++;
    
    if (branchesCount > 0) {
      angleStep = (2 * math.pi) / branchesCount;
    }

    int branchIndex = 0;
    final double radius = 220.0;

    // AI Summary Branch
    if (_currentNote.aiSummary != null && _currentNote.aiSummary!.isNotEmpty) {
      final double angle = branchIndex * angleStep;
      final branchId = 'branch_ai';
      final branchPos = Offset(
        centerX + radius * math.cos(angle),
        centerY + radius * math.sin(angle),
      );

      _nodes.add(MindMapNode(
        id: branchId,
        label: 'AuraAI Ringkasan',
        position: branchPos,
        color: AppTheme.accent,
        type: 'branch_ai',
      ));
      _links.add(MindMapLink(rootId, branchId));

      final summaryLines = _currentNote.aiSummary!
          .split('\n')
          .where((l) => l.trim().startsWith('-') || l.trim().startsWith('•') || l.trim().isNotEmpty)
          .take(3)
          .toList();

      for (int i = 0; i < summaryLines.length; i++) {
        final subId = 'ai_sub_$i';
        final double subAngle = angle - 0.4 + (i * 0.4);
        final subPos = Offset(
          branchPos.dx + 130 * math.cos(subAngle),
          branchPos.dy + 130 * math.sin(subAngle),
        );

        String cleanLine = summaryLines[i].replaceAll(RegExp(r'^[-•*\s]+'), '');
        if (cleanLine.length > 22) cleanLine = '${cleanLine.substring(0, 19)}...';

        _nodes.add(MindMapNode(
          id: subId,
          label: cleanLine,
          position: subPos,
          color: AppTheme.accent.withOpacity(0.8),
          type: 'branch_ai',
        ));
        _links.add(MindMapLink(branchId, subId));
      }
      branchIndex++;
    }

    // Todos/Tasks Branch
    if (_currentNote.todos.isNotEmpty) {
      final double angle = branchIndex * angleStep;
      final branchId = 'branch_todo';
      final branchPos = Offset(
        centerX + radius * math.cos(angle),
        centerY + radius * math.sin(angle),
      );

      _nodes.add(MindMapNode(
        id: branchId,
        label: 'Daftar Tugas',
        position: branchPos,
        color: const Color(0xFF00F2FE),
        type: 'branch_todo',
      ));
      _links.add(MindMapLink(rootId, branchId));

      final todosToRender = _currentNote.todos.take(3).toList();
      for (int i = 0; i < todosToRender.length; i++) {
        final todo = todosToRender[i];
        final subId = 'todo_sub_$i';
        final double subAngle = angle - 0.4 + (i * 0.4);
        final subPos = Offset(
          branchPos.dx + 130 * math.cos(subAngle),
          branchPos.dy + 130 * math.sin(subAngle),
        );

        String cleanText = todo.title.isEmpty ? 'Tugas Kosong' : todo.title;
        if (cleanText.length > 20) cleanText = '${cleanText.substring(0, 17)}...';

        _nodes.add(MindMapNode(
          id: subId,
          label: cleanText,
          position: subPos,
          color: todo.isDone ? Colors.greenAccent : const Color(0xFF00F2FE).withOpacity(0.8),
          type: 'branch_todo',
        ));
        _links.add(MindMapLink(branchId, subId));
      }
      branchIndex++;
    }

    // Content Branch
    if (_currentNote.content.isNotEmpty && !_currentNote.content.startsWith('{"nodes":')) {
      final double angle = branchIndex * angleStep;
      final branchId = 'branch_content';
      final branchPos = Offset(
        centerX + radius * math.cos(angle),
        centerY + radius * math.sin(angle),
      );

      _nodes.add(MindMapNode(
        id: branchId,
        label: 'Isi Catatan',
        position: branchPos,
        color: Colors.amberAccent,
        type: 'branch_content',
      ));
      _links.add(MindMapLink(rootId, branchId));

      String snip = _currentNote.content;
      if (snip.length > 25) snip = '${snip.substring(0, 22)}...';

      final subId = 'content_sub';
      final subPos = Offset(
        branchPos.dx + 130 * math.cos(angle),
        branchPos.dy + 130 * math.sin(angle),
      );

      _nodes.add(MindMapNode(
        id: subId,
        label: snip,
        position: subPos,
        color: Colors.amberAccent.withOpacity(0.8),
        type: 'branch_content',
      ));
      _links.add(MindMapLink(branchId, subId));
    }
  }

  // Serialize nodes & links to JSON String to save into Note content
  String _serializeMindMap() {
    final nodesJson = _nodes.map((n) => {
      'id': n.id,
      'label': n.label,
      'dx': n.position.dx,
      'dy': n.position.dy,
      'color': n.color.value,
      'type': n.type,
    }).toList();

    final linksJson = _links.map((l) => {
      'parentId': l.parentId,
      'childId': l.childId,
    }).toList();

    return jsonEncode({
      'nodes': nodesJson,
      'links': linksJson,
    });
  }

  void _saveMindMap() {
    final jsonContent = _serializeMindMap();
    _currentNote.content = jsonContent;
    _currentNote.dateModified = DateTime.now();

    final provider = context.read<NoteProvider>();
    if (_isNewMindMap) {
      provider.addNote(_currentNote);
      setState(() {
        _isNewMindMap = false;
      });
    } else {
      provider.updateNote(_currentNote);
    }

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        content: Text(
          provider.languageCode == 'en' 
              ? 'MindMap saved successfully' 
              : 'Peta Pikiran berhasil disimpan',
          style: const TextStyle(fontFamily: 'Outfit'),
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ));
  }

  // Add custom idea node
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
                      final double randAngle = math.Random().nextDouble() * 2 * math.pi;
                      final double radius = 150 + (math.Random().nextDouble() * 100);
                      
                      final newPos = Offset(
                        1250 + radius * math.cos(randAngle),
                        1000 + radius * math.sin(randAngle),
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

  void _editNodeLabel(MindMapNode node) {
    final TextEditingController editController = TextEditingController(text: node.label);

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
              'Ubah Label Ide',
              style: TextStyle(color: Colors.white, fontFamily: 'Outfit', fontWeight: FontWeight.bold),
            ),
            content: TextField(
              controller: editController,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: node.color)),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal', style: TextStyle(color: AppTheme.textSecondary)),
              ),
              if (node.type == 'custom') // Hanya ijinkan hapus untuk kustom node
                TextButton(
                  onPressed: () {
                    setState(() {
                      _nodes.removeWhere((n) => n.id == node.id);
                      _links.removeWhere((l) => l.parentId == node.id || l.childId == node.id);
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Hapus', style: TextStyle(color: Colors.redAccent)),
                ),
              ElevatedButton(
                onPressed: () {
                  final text = editController.text.trim();
                  if (text.isNotEmpty) {
                    setState(() {
                      node.label = text;
                    });
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: node.color,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Simpan', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final auraColor = AppTheme.getColorForCategory(_currentNote.category);

    return Scaffold(
      backgroundColor: const Color(0xFF03030F), // Deep space background
      appBar: AppBar(
        title: const Text('AuraMind Peta Pikiran', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.gps_fixed_rounded, color: AppTheme.textPrimary),
            tooltip: 'Pusatkan Peta',
            onPressed: _centerOnRoot,
          ),
          IconButton(
            icon: const Icon(Icons.save_rounded, color: Colors.greenAccent),
            tooltip: 'Simpan Peta Pikiran',
            onPressed: _saveMindMap,
          ),
        ],
      ),
      body: Stack(
        children: [
          // 2D Pan and Pinch-zoom Canvas
          InteractiveViewer(
            transformationController: _transformationController,
            boundaryMargin: const EdgeInsets.all(800),
            minScale: 0.15,
            maxScale: 3.0,
            child: SizedBox(
              width: 2500,
              height: 2000,
              child: Stack(
                children: [
                  // Latar belakang garis penghubung (Bezier curves)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: MindMapLinksPainter(
                        nodes: _nodes,
                        links: _links,
                      ),
                    ),
                  ),

                  // Node widgets diposisikan secara dinamis
                  ..._nodes.map((node) {
                    final double radius = node.type == 'root' ? 52.0 : 42.0;
                    return Positioned(
                      left: node.position.dx - radius,
                      top: node.position.dy - radius,
                      child: GestureDetector(
                        onPanUpdate: (details) {
                          final matrix = _transformationController.value;
                          final double scale = matrix.getMaxScaleOnAxis();
                          setState(() {
                            // Gerakkan node berdasarkan pergeseran delta disesuaikan dengan scale zoom
                            node.position += details.delta / scale;
                          });
                        },
                        onDoubleTap: () => _editNodeLabel(node),
                        child: MouseRegion(
                          cursor: SystemMouseCursors.grab,
                          child: Container(
                            width: radius * 2,
                            height: radius * 2,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF0C0C1E).withOpacity(0.92),
                              border: Border.all(color: node.color, width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: node.color.withOpacity(0.25),
                                  blurRadius: 14,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                node.label,
                                style: TextStyle(
                                  fontSize: node.type == 'root' ? 10.5 : 9.0,
                                  color: Colors.white,
                                  fontFamily: 'Outfit',
                                  fontWeight: node.type == 'root' ? FontWeight.bold : FontWeight.normal,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),

          // Papan petunjuk premium
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
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.02),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppTheme.accent, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Seret bulatan node secara langsung untuk memindahkan. Seret kanvas kosong untuk geser kamera. Klik dua kali node untuk mengubah nama / menghapus ide.',
                          style: TextStyle(fontSize: 10, color: AppTheme.textSecondary.withOpacity(0.8), fontFamily: 'Outfit'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Tombol untuk menambah ide kustom baru
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

// Painter khusus untuk menggambar garis kurva bersinar di latar belakang
class MindMapLinksPainter extends CustomPainter {
  final List<MindMapNode> nodes;
  final List<MindMapLink> links;

  MindMapLinksPainter({
    required this.nodes,
    required this.links,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final linkPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (var link in links) {
      final parentIndex = nodes.indexWhere((n) => n.id == link.parentId);
      final childIndex = nodes.indexWhere((n) => n.id == link.childId);

      if (parentIndex == -1 || childIndex == -1) continue;

      final parent = nodes[parentIndex];
      final child = nodes[childIndex];

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

      // Gambar kurva bezier neon glow di latar belakang
      canvas.drawPath(
        path,
        linkPaint..color = child.color.withOpacity(0.32)..strokeWidth = 2.0,
      );
    }
  }

  @override
  bool shouldRepaint(covariant MindMapLinksPainter oldDelegate) => true;
}
