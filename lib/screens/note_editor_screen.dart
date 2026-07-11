import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import '../models/note.dart';
import '../providers/note_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/aura_lock_dialog.dart';
import 'drawing_canvas_screen.dart';
import 'mind_map_screen.dart';
import '../utils/translation_helper.dart';

class NoteEditorScreen extends StatefulWidget {
  final Note? note;

  const NoteEditorScreen({super.key, this.note});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late String _id;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  late String _selectedCategory;
  late bool _isPinned;
  late bool _isArchived;
  late List<TodoItem> _todos;
  late List<DrawingStroke> _sketchStrokes;
  String? _aiSummary;
  bool _isAiCardExpanded = true;
  bool _isNewNote = true;
  late bool _isLocked;
  DateTime? _reminderDate;
  late List<String> _tags;
  String? _coverValue;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      final note = widget.note!;
      _id = note.id;
      _titleController.text = note.title;
      _contentController.text = note.content;
      _selectedCategory = note.category;
      _isPinned = note.isPinned;
      _isArchived = note.isArchived;
      _todos = List.from(note.todos);
      _sketchStrokes = List.from(note.sketchStrokes);
      _aiSummary = note.aiSummary;
      _isLocked = note.isLocked;
      _reminderDate = note.reminderDate;
      _tags = List.from(note.tags);
      _coverValue = note.coverValue;
      _isNewNote = false;
    } else {
      _id = 'note_${DateTime.now().millisecondsSinceEpoch}';
      _selectedCategory = 'Pribadi';
      _isPinned = false;
      _isArchived = false;
      _isLocked = false;
      _reminderDate = null;
      _tags = [];
      _coverValue = null;
      _todos = [];
      _sketchStrokes = [];
      _aiSummary = null;
    }

    _titleController.addListener(_autoSave);
    _contentController.addListener(_autoSave);
  }

  @override
  void dispose() {
    _titleController.removeListener(_autoSave);
    _contentController.removeListener(_autoSave);
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  // Method to auto-save or manually save notes
  void _saveNote() {
    final note = Note(
      id: _id,
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      category: _selectedCategory,
      dateCreated: widget.note?.dateCreated ?? DateTime.now(),
      dateModified: DateTime.now(),
      isPinned: _isPinned,
      isArchived: _isArchived,
      isTrashed: widget.note?.isTrashed ?? false,
      isLocked: _isLocked,
      reminderDate: _reminderDate,
      todos: _todos,
      sketchStrokes: _sketchStrokes,
      aiSummary: _aiSummary,
      tags: _tags,
      coverValue: _coverValue,
    );

    final provider = context.read<NoteProvider>();
    if (_isNewNote) {
      if (note.title.isNotEmpty || note.content.isNotEmpty || _todos.isNotEmpty || _sketchStrokes.isNotEmpty) {
        provider.addNote(note);
        _isNewNote = false; // Now it is not a new note anymore
      }
    } else {
      provider.updateNote(note);
    }
  }

  void _autoSave() {
    _saveNote();
  }

  // Adding a new sub-task item
  void _addTodoItem() {
    setState(() {
      _todos.add(
        TodoItem(
          id: 'todo_${DateTime.now().millisecondsSinceEpoch}',
          title: '',
        ),
      );
    });
    _saveNote();
  }

  // Edit sub-task title
  void _updateTodoItemTitle(int index, String newTitle) {
    setState(() {
      _todos[index].title = newTitle;
    });
    _saveNote();
  }

  // Toggle sub-task checklist status
  void _toggleTodoItemStatus(int index) {
    setState(() {
      _todos[index].isDone = !_todos[index].isDone;
    });
    _saveNote();
  }

  // Delete a sub-task item
  void _deleteTodoItem(int index) {
    setState(() {
      _todos.removeAt(index);
    });
    _saveNote();
  }

  // Calculate read time
  String _calculateReadTimeAndChars() {
    final text = _contentController.text;
    final chars = text.length;
    final words = text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
    final minutes = (words / 200).ceil(); // Assuming average reading speed is 200 wpm
    return '$chars Karakter • $minutes min baca';
  }

  // Trigger AuraVoice sheet
  void _showAuraVoicePanel() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black.withOpacity(0.65),
      builder: (context) {
        return AuraVoiceBottomSheet(
          category: _selectedCategory,
          onTextTranscribed: (text) {
            final currentText = _contentController.text;
            final selection = _contentController.selection;
            
            String newText;
            if (selection.start != -1 && selection.end != -1) {
              newText = currentText.replaceRange(selection.start, selection.end, text);
            } else {
              newText = currentText.isEmpty ? text : '$currentText\n$text';
            }
            
            setState(() {
              _contentController.text = newText;
              _contentController.selection = TextSelection.fromPosition(
                TextPosition(offset: newText.length),
              );
            });
            _saveNote();
          },
        );
      },
    );
  }

  // Trigger AuraScan sheet
  void _showAuraScanPanel() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black.withOpacity(0.65),
      builder: (context) {
        return AuraScanBottomSheet(
          category: _selectedCategory,
          onTextScanned: (text) {
            final currentText = _contentController.text;
            final selection = _contentController.selection;
            
            String newText;
            if (selection.start != -1 && selection.end != -1) {
              newText = currentText.replaceRange(selection.start, selection.end, text);
            } else {
              newText = currentText.isEmpty ? text : '$currentText\n$text';
            }
            
            setState(() {
              _contentController.text = newText;
              _contentController.selection = TextSelection.fromPosition(
                TextPosition(offset: newText.length),
              );
            });
            _saveNote();
          },
        );
      },
    );
  }

  // Formatting helper for reminder label
  String _formatReminderLabel(DateTime dateTime) {
    final String timeStr = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} $timeStr';
  }

  // Show kustom glassmorphic Date and Time picker
  Future<void> _showReminderPicker() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _reminderDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppTheme.getColorForCategory(_selectedCategory),
              onPrimary: Colors.black,
              surface: AppTheme.surface,
              onSurface: AppTheme.textPrimary,
            ),
            dialogBackgroundColor: AppTheme.surface,
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null) return;

    if (!mounted) return;
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_reminderDate ?? DateTime.now()),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppTheme.getColorForCategory(_selectedCategory),
              onPrimary: Colors.black,
              surface: AppTheme.surface,
              onSurface: AppTheme.textPrimary,
            ),
            dialogBackgroundColor: AppTheme.surface,
          ),
          child: child!,
        );
      },
    );

    if (pickedTime == null) return;

    final DateTime scheduledDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    setState(() {
      _reminderDate = scheduledDateTime;
    });
    _saveNote();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Pengingat dijadwalkan: ${_formatReminderLabel(scheduledDateTime)}',
          style: const TextStyle(fontFamily: 'Outfit'),
        ),
        backgroundColor: AppTheme.getColorForCategory(_selectedCategory),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        action: SnackBarAction(
          label: 'HAPUS',
          textColor: Colors.black,
          onPressed: () {
            setState(() {
              _reminderDate = null;
            });
            _saveNote();
          },
        ),
      ),
    );
  }

  // Toggle Lock with Biometric verification
  void _toggleLockWithBiometrics() {
    if (!_isLocked) {
      setState(() {
        _isLocked = true;
      });
      _saveNote();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Catatan dikunci dengan AuraLock', style: TextStyle(fontFamily: 'Outfit')),
          backgroundColor: AppTheme.surface,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: Colors.white.withOpacity(0.08)),
          ),
        ),
      );
    } else {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return AuraLockDialog(
            category: _selectedCategory,
            onAuthenticated: () {
              setState(() {
                _isLocked = false;
              });
              _saveNote();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Kunci catatan berhasil dibuka', style: TextStyle(fontFamily: 'Outfit')),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              );
            },
          );
        },
      );
    }
  }

  // Trigger local AI summarization
  Future<void> _runAISummary() async {
    _saveNote();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return _buildAILoadingDialog();
      },
    );

    try {
      final provider = context.read<NoteProvider>();
      await provider.summarizeNote(_id);

      final updatedNote = provider.notes.firstWhere((n) => n.id == _id);

      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        setState(() {
          _aiSummary = updatedNote.aiSummary;
          _isAiCardExpanded = true;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('AuraAI berhasil merangkum catatan!', style: TextStyle(fontFamily: 'Outfit')),
            backgroundColor: AppTheme.surface,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('AuraAI Gagal: $e', style: const TextStyle(fontFamily: 'Outfit')),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Widget _buildAILoadingDialog() {
    final auraColor = AppTheme.getColorForCategory(_selectedCategory);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: AppTheme.glassDecoration(
            auraColor: auraColor,
            showGlow: true,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AnimatedAILoader(),
              const SizedBox(height: 24),
              const Text(
                'AuraAI Menganalisis Catatan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Outfit',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Membaca teks, memilah tugas kritis, dan menyusun ringkasan penting...',
                style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.textSecondary,
                  fontFamily: 'Outfit',
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auraColor = AppTheme.getColorForCategory(_selectedCategory);

    return WillPopScope(
      onWillPop: () async {
        _saveNote();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _isNewNote ? TranslationHelper.translateReactive(context, 'editor_new') : TranslationHelper.translateReactive(context, 'editor_edit'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          actions: [
            // AuraAI Summarize Button
            IconButton(
              icon: const Icon(Icons.auto_awesome, color: AppTheme.accent),
              tooltip: 'Rangkum dengan AuraAI',
              onPressed: _runAISummary,
            ),
            // AuraLock Biometric Toggle Button
            IconButton(
              icon: Icon(
                _isLocked ? Icons.lock : Icons.lock_open_outlined,
                color: _isLocked ? Colors.redAccent : AppTheme.textPrimary,
              ),
              tooltip: _isLocked ? 'Buka Kunci Catatan' : 'Kunci Catatan',
              onPressed: _toggleLockWithBiometrics,
            ),
            // AuraSchedule Reminder Button
            IconButton(
              icon: Icon(
                _reminderDate != null ? Icons.notifications_active : Icons.notifications_none_outlined,
                color: _reminderDate != null ? auraColor : AppTheme.textPrimary,
              ),
              tooltip: _reminderDate != null
                  ? 'Ubah/Hapus Pengingat (${_formatReminderLabel(_reminderDate!)})'
                  : 'Atur Pengingat',
              onPressed: _showReminderPicker,
            ),
            // AuraMind Mind Map Button
            IconButton(
              icon: const Icon(Icons.hub_outlined, color: AppTheme.accent),
              tooltip: 'Visualisasi Peta Pikiran AuraMind',
              onPressed: () {
                _saveNote();
                final note = Note(
                  id: _id,
                  title: _titleController.text.trim(),
                  content: _contentController.text.trim(),
                  category: _selectedCategory,
                  dateCreated: widget.note?.dateCreated ?? DateTime.now(),
                  dateModified: DateTime.now(),
                  isPinned: _isPinned,
                  isArchived: _isArchived,
                  isTrashed: widget.note?.isTrashed ?? false,
                  isLocked: _isLocked,
                  reminderDate: _reminderDate,
                  todos: _todos,
                  sketchStrokes: _sketchStrokes,
                  aiSummary: _aiSummary,
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MindMapScreen(note: note),
                  ),
                );
              },
            ),
            // AuraCover Palette Button
            IconButton(
              icon: Icon(
                Icons.palette_outlined,
                color: _coverValue != null ? auraColor : AppTheme.textPrimary,
              ),
              tooltip: 'Pilih Sampul Catatan AuraCover',
              onPressed: _showAuraCoverSheet,
            ),
            // Sketch Canvas Button
            IconButton(
              icon: Icon(
                Icons.brush,
                color: _sketchStrokes.isNotEmpty ? auraColor : AppTheme.textPrimary,
              ),
              tooltip: 'AuraDraw Kanvas Gambar',
              onPressed: () async {
                final result = await Navigator.push<List<DrawingStroke>>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DrawingCanvasScreen(
                      initialStrokes: _sketchStrokes,
                      category: _selectedCategory,
                    ),
                  ),
                );
                if (result != null) {
                  setState(() {
                    _sketchStrokes = result;
                  });
                  _saveNote();
                }
              },
            ),
            // Pin Toggle Button
            IconButton(
              icon: Icon(
                _isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                color: _isPinned ? auraColor : AppTheme.textPrimary,
              ),
              onPressed: () {
                setState(() {
                  _isPinned = !_isPinned;
                });
                _saveNote();
              },
            ),
            // Archive Toggle Button
            IconButton(
              icon: Icon(
                _isArchived ? Icons.archive : Icons.archive_outlined,
                color: _isArchived ? auraColor : AppTheme.textPrimary,
              ),
              onPressed: () {
                setState(() {
                  _isArchived = !_isArchived;
                  if (_isArchived) _isPinned = false; // Archive automatically unpins
                });
                _saveNote();
                // Pop with message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _isArchived ? 'Catatan diarsipkan' : 'Catatan dipulihkan dari arsip',
                      style: const TextStyle(fontFamily: 'Outfit'),
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                Navigator.pop(context);
              },
            ),
            // Popup Menu Button for Extra Actions
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: AppTheme.textPrimary),
              onSelected: (value) {
                if (value == 'delete') {
                  // Move to trash
                  final provider = context.read<NoteProvider>();
                  provider.moveToTrash(_id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Catatan dipindahkan ke sampah', style: TextStyle(fontFamily: 'Outfit')),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  Navigator.pop(context); // Go back to Home
                } else if (value == 'lock') {
                  _toggleLockWithBiometrics();
                } else if (value == 'archive') {
                  setState(() {
                    _isArchived = !_isArchived;
                    if (_isArchived) _isPinned = false;
                  });
                  _saveNote();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_isArchived ? 'Catatan diarsipkan' : 'Catatan dipulihkan dari arsip', style: const TextStyle(fontFamily: 'Outfit')),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              itemBuilder: (ctx) => [
                PopupMenuItem(
                  value: 'archive',
                  child: Row(
                    children: [
                      Icon(_isArchived ? Icons.unarchive : Icons.archive, color: AppTheme.textPrimary, size: 20),
                      const SizedBox(width: 8),
                      Text(_isArchived ? 'Buka Arsip' : 'Arsipkan'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'lock',
                  child: Row(
                    children: [
                      Icon(_isLocked ? Icons.lock_open : Icons.lock, color: AppTheme.textPrimary, size: 20),
                      const SizedBox(width: 8),
                      Text(_isLocked ? 'Buka Kunci' : 'Kunci Catatan'),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                      const SizedBox(width: 8),
                      Text('Hapus', style: TextStyle(color: Colors.redAccent)),
                    ],
                  ),
                ),
              ],
            ),
            // Confirm/Check button (Manual Save/Done)
            IconButton(
              icon: const Icon(Icons.check, color: Colors.greenAccent),
              onPressed: () {
                _saveNote();
                Navigator.pop(context);
              },
            ),
          ],
        body: Column(
          children: [
            // Category Select Slider
            Container(
              height: 48,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: AppTheme.categoryGradients.keys.map((cat) {
                  final isSel = _selectedCategory == cat;
                  final catColor = AppTheme.getColorForCategory(cat);
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                        cat,
                        style: TextStyle(
                          fontSize: 12,
                          color: isSel ? Colors.black : AppTheme.textSecondary,
                          fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      selected: isSel,
                      selectedColor: catColor,
                      backgroundColor: AppTheme.surface.withOpacity(0.4),
                      side: BorderSide(
                        color: isSel ? catColor : Colors.white.withOpacity(0.08),
                        width: 1.0,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      showCheckmark: false,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedCategory = cat;
                          });
                          _saveNote();
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // AuraCover Banner inside Editor
                    if (_coverValue != null) ...[
                      Container(
                        height: 160,
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          gradient: AppTheme.getCoverGradient(_coverValue),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.getCoverGradient(_coverValue)!.colors.first.withOpacity(0.25),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            )
                          ],
                        ),
                        child: Stack(
                          children: [
                            // Close Button to remove cover
                            Positioned(
                              top: 12,
                              right: 12,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _coverValue = null;
                                  });
                                  _saveNote();
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Sketch Preview if present
                    if (_sketchStrokes.isNotEmpty) ...[
                      Center(
                        child: Container(
                          height: 160,
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: auraColor.withOpacity(0.2),
                              width: 1.2,
                            ),
                          ),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: CustomPaint(
                                  painter: SketchMiniPainter(strokes: _sketchStrokes),
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _sketchStrokes.clear();
                                    });
                                    _saveNote();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.redAccent,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    // Note Title Text Field
                    TextField(
                      controller: _titleController,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                      decoration: InputDecoration(
                        hintText: TranslationHelper.translateReactive(context, 'editor_title_hint'),
                        hintStyle: TextStyle(color: AppTheme.textSecondary.withOpacity(0.4)),
                        border: InputBorder.none,
                      ),
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    
                    // Neon Divider
                    Container(
                      height: 1.5,
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [auraColor, auraColor.withOpacity(0.01)],
                        ),
                      ),
                    ),

                    // AuraAI Summary Card
                    if (_aiSummary != null && _aiSummary!.isNotEmpty)
                      AuraAISummaryCard(
                        summary: _aiSummary!,
                        isExpanded: _isAiCardExpanded,
                        auraColor: auraColor,
                        onToggle: () {
                          setState(() {
                            _isAiCardExpanded = !_isAiCardExpanded;
                          });
                        },
                        onDelete: () {
                          setState(() {
                            _aiSummary = null;
                          });
                          _saveNote();
                        },
                      ),

                    // Note Content Text Field
                    TextField(
                      controller: _contentController,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.textPrimary.withOpacity(0.9),
                            height: 1.6,
                          ),
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        hintText: TranslationHelper.translateReactive(context, 'editor_content_hint'),
                        hintStyle: TextStyle(color: AppTheme.textSecondary.withOpacity(0.3)),
                        border: InputBorder.none,
                      ),
                      textCapitalization: TextCapitalization.sentences,
                    ),

                    // Checklist Section Header
                    if (_todos.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Icon(Icons.format_list_bulleted, size: 18, color: auraColor),
                          const SizedBox(width: 8),
                          Text(
                            TranslationHelper.translateReactive(context, 'todo_title'),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: auraColor,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // List of Checklist items
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _todos.length,
                        itemBuilder: (context, index) {
                          final item = _todos[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                // Checkbox
                                Checkbox(
                                  value: item.isDone,
                                  activeColor: auraColor,
                                  onChanged: (val) => _toggleTodoItemStatus(index),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                // Text field
                                Expanded(
                                  child: TextField(
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: item.isDone
                                          ? AppTheme.textSecondary.withOpacity(0.5)
                                          : AppTheme.textPrimary,
                                      decoration: item.isDone
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                                    controller: TextEditingController(text: item.title)
                                      ..selection = TextSelection.fromPosition(
                                        TextPosition(offset: item.title.length),
                                      ),
                                    onChanged: (text) => _updateTodoItemTitle(index, text),
                                    decoration: InputDecoration(
                                      hintText: TranslationHelper.translateReactive(context, 'todo_hint'),
                                      hintStyle: TextStyle(color: AppTheme.textSecondary.withOpacity(0.3)),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                                // Delete Item Button
                                IconButton(
                                  icon: const Icon(Icons.close, size: 16, color: Colors.redAccent),
                                  onPressed: () => _deleteTodoItem(index),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],

                    // Quick Button to Add Task Checklist
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: _addTodoItem,
                      icon: Icon(Icons.add_task, size: 16, color: auraColor),
                      label: Text(
                        'Tambah Item Tugas',
                        style: TextStyle(
                          fontSize: 13,
                          color: auraColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        backgroundColor: auraColor.withOpacity(0.08),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // Editor Bottom Panel (Metadata / Words)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.surface.withOpacity(0.9),
                border: Border.all(color: Colors.white.withOpacity(0.04)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Metadata Text
                  Expanded(
                    child: Text(
                      _calculateReadTimeAndChars(),
                      style: TextStyle(fontSize: 11, color: AppTheme.textSecondary.withOpacity(0.8)),
                    ),
                  ),
                  
                  // AuraVoice Microphone Button
                  IconButton(
                    icon: const Icon(Icons.mic, color: AppTheme.accent),
                    tooltip: 'Rekam dengan AuraVoice',
                    onPressed: () {
                      _showAuraVoicePanel();
                    },
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.accent.withOpacity(0.08),
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // AuraScan Camera Button
                  IconButton(
                    icon: const Icon(Icons.camera_alt, color: AppTheme.accent),
                    tooltip: 'Pindai dengan AuraScan',
                    onPressed: () {
                      _showAuraScanPanel();
                    },
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.accent.withOpacity(0.08),
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // AuraWiki Note Relations Button
                  IconButton(
                    icon: const Icon(Icons.link, color: AppTheme.accent),
                    tooltip: 'AuraWiki Hub Relasi Catatan',
                    onPressed: () {
                      _showAuraWikiSheet();
                    },
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.accent.withOpacity(0.08),
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Save Status & Sync Cloud Icon
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (context.read<NoteProvider>().isSyncEnabled) ...[
                        const Icon(
                          Icons.cloud_done,
                          size: 14,
                          color: Colors.greenAccent,
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        _isNewNote ? TranslationHelper.translateReactive(context, 'status_new') : TranslationHelper.translateReactive(context, 'status_saved'),
                        style: const TextStyle(fontSize: 11, color: Colors.greenAccent),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // AuraWiki Sheet: Handles outgoing wiki-links, incoming backlinks, and custom tags
  void _showAuraWikiSheet() {
    _saveNote();

    final noteProvider = context.read<NoteProvider>();
    final notes = noteProvider.notes;
    final currentTitle = _titleController.text.trim();

    final outgoingMatches = RegExp(r'\[\[(.*?)\]\]').allMatches(_contentController.text);
    final List<String> outgoingTitles = outgoingMatches
        .map((m) => m.group(1)!.trim())
        .where((title) => title.isNotEmpty)
        .toSet()
        .toList();

    final List<Note> backlinks = [];
    if (currentTitle.isNotEmpty) {
      for (var n in notes) {
        if (n.id != _id && !n.isTrashed && n.content.contains('[[$currentTitle]]')) {
          backlinks.add(n);
        }
      }
    }

    final hashtagMatches = RegExp(r'#(\w+)').allMatches(_contentController.text);
    final List<String> textTags = hashtagMatches.map((m) => m.group(1)!.trim()).toSet().toList();
    final List<String> mergedTags = <String>{..._tags, ...textTags}.toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final TextEditingController tagController = TextEditingController();
            final auraColor = AppTheme.getColorForCategory(_selectedCategory);

            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.75,
                decoration: BoxDecoration(
                  color: AppTheme.surface.withOpacity(0.92),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.08),
                    width: 1.0,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Column(
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
                    const SizedBox(height: 24),

                    Row(
                      children: [
                        Icon(Icons.link, color: auraColor, size: 24),
                        const SizedBox(width: 10),
                        const Text(
                          'AuraWiki Hub Relasi',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Outfit',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildWikiSectionTitle('🏷️ HASHTAGS & TAGS'),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                ...mergedTags.map((tag) {
                                  final isManual = _tags.contains(tag);
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isManual ? auraColor.withOpacity(0.12) : Colors.white.withOpacity(0.04),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: isManual ? auraColor.withOpacity(0.3) : Colors.white.withOpacity(0.08),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '#$tag',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: isManual ? auraColor : AppTheme.textSecondary.withOpacity(0.7),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        if (isManual) ...[
                                          const SizedBox(width: 4),
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _tags.remove(tag);
                                              });
                                              setModalState(() {});
                                              _saveNote();
                                            },
                                            child: Icon(Icons.close, size: 10, color: auraColor),
                                          ),
                                        ],
                                      ],
                                    ),
                                  );
                                }),
                                Container(
                                  width: 100,
                                  height: 24,
                                  child: TextField(
                                    controller: tagController,
                                    style: const TextStyle(fontSize: 11, color: Colors.white),
                                    decoration: InputDecoration(
                                      hintText: '+ Tambah Tag',
                                      hintStyle: TextStyle(fontSize: 10, color: AppTheme.textSecondary.withOpacity(0.4)),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    onSubmitted: (val) {
                                      final newTag = val.trim().replaceAll('#', '');
                                      if (newTag.isNotEmpty && !_tags.contains(newTag)) {
                                        setState(() {
                                          _tags.add(newTag);
                                        });
                                        setModalState(() {});
                                        _saveNote();
                                      }
                                      tagController.clear();
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            _buildWikiSectionTitle('🔗 PRANALA KELUAR (WIKI LINKS)'),
                            const SizedBox(height: 8),
                            if (outgoingTitles.isEmpty)
                              _buildWikiEmptyText('Tulis [[Judul Catatan]] di isi teks untuk membuat tautan Wiki.')
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: outgoingTitles.length,
                                itemBuilder: (context, index) {
                                  final title = outgoingTitles[index];
                                  final matchingNotes = notes.where((n) => n.title.toLowerCase() == title.toLowerCase() && !n.isTrashed).toList();
                                  final bool exists = matchingNotes.isNotEmpty;

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    decoration: AppTheme.glassDecoration(
                                      auraColor: exists ? AppTheme.getColorForCategory(matchingNotes.first.category) : Colors.redAccent,
                                      showGlow: false,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            title,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: exists ? Colors.white : Colors.white.withOpacity(0.5),
                                              fontFamily: 'Outfit',
                                            ),
                                          ),
                                        ),
                                        if (exists)
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              _openRelatedNote(matchingNotes.first);
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppTheme.getColorForCategory(matchingNotes.first.category).withOpacity(0.12),
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                                side: BorderSide(color: AppTheme.getColorForCategory(matchingNotes.first.category).withOpacity(0.3)),
                                              ),
                                            ),
                                            child: const Text('Buka', style: TextStyle(color: Colors.white, fontSize: 11)),
                                          )
                                        else
                                          ElevatedButton.icon(
                                            onPressed: () {
                                              final newNote = Note(
                                                id: 'note_${DateTime.now().millisecondsSinceEpoch}',
                                                title: title,
                                                content: '',
                                                category: _selectedCategory,
                                                dateCreated: DateTime.now(),
                                                dateModified: DateTime.now(),
                                              );
                                              noteProvider.addNote(newNote);
                                              Navigator.pop(context);
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => NoteEditorScreen(note: newNote),
                                                ),
                                              );
                                            },
                                            icon: const Icon(Icons.add, size: 12, color: Colors.black),
                                            label: const Text('Buat', style: TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold)),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.white,
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            const SizedBox(height: 24),

                            _buildWikiSectionTitle('🔄 PRANALA MASUK (BACKLINKS)'),
                            const SizedBox(height: 8),
                            if (backlinks.isEmpty)
                              _buildWikiEmptyText('Tidak ada catatan lain yang menautkan ke catatan ini.')
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: backlinks.length,
                                itemBuilder: (context, index) {
                                  final relatedNote = backlinks[index];
                                  final relatedAura = AppTheme.getColorForCategory(relatedNote.category);

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    decoration: AppTheme.glassDecoration(
                                      auraColor: relatedAura,
                                      showGlow: false,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            relatedNote.title.isEmpty ? 'Catatan Tanpa Judul' : relatedNote.title,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              fontFamily: 'Outfit',
                                            ),
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            _openRelatedNote(relatedNote);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: relatedAura.withOpacity(0.12),
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                              side: BorderSide(color: relatedAura.withOpacity(0.3)),
                                            ),
                                          ),
                                          child: const Text('Buka', style: TextStyle(color: Colors.white, fontSize: 11)),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildWikiSectionTitle(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        color: AppTheme.textSecondary.withOpacity(0.8),
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildWikiEmptyText(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          color: AppTheme.textSecondary.withOpacity(0.4),
          fontStyle: FontStyle.italic,
          fontFamily: 'Outfit',
        ),
      ),
    );
  }

  void _openRelatedNote(Note note) {
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

  // AuraCover Sheet: Custom glowing color/gradient chooser
  void _showAuraCoverSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final auraColor = AppTheme.getColorForCategory(_selectedCategory);

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
                    const Text(
                      'Pilih Sampul AuraCover',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Outfit',
                      ),
                    ),
                    const SizedBox(height: 18),
                    
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: AppTheme.coverGradients.length + 1,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.6,
                      ),
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return InkWell(
                            onTap: () {
                              setState(() {
                                _coverValue = null;
                              });
                              _saveNote();
                              Navigator.pop(context);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.04),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white.withOpacity(0.08)),
                              ),
                              child: const Center(
                                child: Text(
                                  'Tanpa Sampul',
                                  style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          );
                        }

                        final key = AppTheme.coverGradients.keys.elementAt(index - 1);
                        final gradient = AppTheme.getCoverGradient(key)!;

                        return InkWell(
                          onTap: () {
                            setState(() {
                              _coverValue = key;
                            });
                            _saveNote();
                            Navigator.pop(context);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: gradient,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _coverValue == key ? Colors.white : Colors.transparent,
                                width: 2.0,
                              ),
                            ),
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                width: double.infinity,
                                color: Colors.black38,
                                padding: const EdgeInsets.symmetric(vertical: 2),
                                child: Text(
                                  key.replaceAll('_', ' ').toUpperCase(),
                                  style: const TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// Custom Painter to render a miniature preview of sketch points inside Editor
class SketchMiniPainter extends CustomPainter {
  final List<DrawingStroke> strokes;

  SketchMiniPainter({required this.strokes});

  @override
  void paint(Canvas canvas, Size size) {
    if (strokes.isEmpty) return;

    // Find bounds of all stroke points to auto scale/fit the mini canvas
    double minX = double.infinity;
    double maxX = -double.infinity;
    double minY = double.infinity;
    double maxY = -double.infinity;

    for (var stroke in strokes) {
      for (var pt in stroke.points) {
        if (pt.x < minX) minX = pt.x;
        if (pt.x > maxX) maxX = pt.x;
        if (pt.y < minY) minY = pt.y;
        if (pt.y > maxY) maxY = pt.y;
      }
    }

    // Default padding margins
    if (minX == double.infinity) return;
    double strokeW = maxX - minX;
    double strokeH = maxY - minY;
    if (strokeW == 0) strokeW = 1.0;
    if (strokeH == 0) strokeH = 1.0;

    final scaleX = (size.width - 20) / strokeW;
    final scaleY = (size.height - 20) / strokeH;
    final scale = scaleX < scaleY ? scaleX : scaleY;

    // Translate to center and draw
    canvas.save();
    canvas.translate(
      (size.width - strokeW * scale) / 2 - minX * scale,
      (size.height - strokeH * scale) / 2 - minY * scale,
    );

    for (var stroke in strokes) {
      if (stroke.points.length < 2) continue;

      final paint = Paint()
        ..color = Color(stroke.colorValue)
        ..strokeCap = StrokeCap.round
        ..strokeWidth = stroke.strokeWidth * 0.6 // Scale down stroke size a bit
        ..style = PaintingStyle.stroke;

      final path = Path();
      path.moveTo(stroke.points[0].x * scale, stroke.points[0].y * scale);

      for (int i = 1; i < stroke.points.length; i++) {
        path.lineTo(stroke.points[i].x * scale, stroke.points[i].y * scale);
      }
      canvas.drawPath(path, paint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant SketchMiniPainter oldDelegate) => true;
}

// Animated AI Loader with Pulsing Glow Effect
class AnimatedAILoader extends StatefulWidget {
  const AnimatedAILoader({super.key});

  @override
  State<AnimatedAILoader> createState() => _AnimatedAILoaderState();
}

class _AnimatedAILoaderState extends State<AnimatedAILoader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [AppTheme.accent, Color(0xFFC71585)], // Violet to Pink
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.accent.withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(
          Icons.auto_awesome,
          size: 40,
          color: Colors.white,
        ),
      ),
    );
  }
}

// Custom Glassmorphic Card to display AI Summary text with markdown support
class AuraAISummaryCard extends StatelessWidget {
  final String summary;
  final VoidCallback onDelete;
  final bool isExpanded;
  final VoidCallback onToggle;
  final Color auraColor;

  const AuraAISummaryCard({
    super.key,
    required this.summary,
    required this.onDelete,
    required this.isExpanded,
    required this.onToggle,
    required this.auraColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: AppTheme.glassDecoration(
        auraColor: AppTheme.accent,
        showGlow: true,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: onToggle,
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome, size: 16, color: AppTheme.accent),
                      const SizedBox(width: 8),
                      const Text(
                        'Ringkasan AuraAI',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accent,
                          fontFamily: 'Outfit',
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        size: 16,
                        color: AppTheme.textSecondary,
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: onDelete,
                  child: Icon(
                    Icons.close_rounded,
                    size: 16,
                    color: AppTheme.textSecondary.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),

          // Content body
          if (isExpanded) ...[
            Container(
              height: 1.0,
              width: double.infinity,
              color: Colors.white.withOpacity(0.06),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textPrimary,
                    fontFamily: 'Outfit',
                    height: 1.5,
                  ),
                  children: _parseMarkdownToTextSpans(summary),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Simple parser to convert **bold** text in summary into bold TextSpans
  List<TextSpan> _parseMarkdownToTextSpans(String text) {
    final List<TextSpan> spans = [];
    final RegExp regExp = RegExp(r'\*\*(.*?)\*\*');
    int start = 0;

    for (final Match match in regExp.allMatches(text)) {
      if (match.start > start) {
        spans.add(TextSpan(text: text.substring(start, match.start)));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ));
      start = match.end;
    }

    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }

    return spans;
  }
}

// AuraVoice Bottom Sheet with real microphone input and speech to text transcription
class AuraVoiceBottomSheet extends StatefulWidget {
  final String category;
  final Function(String) onTextTranscribed;

  const AuraVoiceBottomSheet({
    super.key,
    required this.category,
    required this.onTextTranscribed,
  });

  @override
  State<AuraVoiceBottomSheet> createState() => _AuraVoiceBottomSheetState();
}

class _AuraVoiceBottomSheetState extends State<AuraVoiceBottomSheet> with SingleTickerProviderStateMixin {
  late AnimationController _waveController;
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isSpeechInitialized = false;
  bool _isRecording = false;
  bool _isFinished = false;
  String _transcriptionText = '';
  double _currentSoundLevel = 0.0;
  String _statusMessage = 'Menginisialisasi mikrofon...';

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    try {
      bool available = await _speech.initialize(
        onStatus: (status) {
          debugPrint('Speech status: $status');
          if (status == 'done' || status == 'notListening') {
            if (_isRecording) {
              _stopRecording();
            }
          }
        },
        onError: (errorNotification) {
          debugPrint('Speech error: $errorNotification');
          setState(() {
            _statusMessage = 'Error: ${errorNotification.errorMsg}';
            _isRecording = false;
          });
          _waveController.stop();
        },
      );
      setState(() {
        _isSpeechInitialized = available;
        _statusMessage = available ? 'Siap Merekam' : 'Speech recognition tidak didukung di perangkat ini';
      });
    } catch (e) {
      setState(() {
        _isSpeechInitialized = false;
        _statusMessage = 'Gagal menginisialisasi Speech: $e';
      });
    }
  }

  @override
  void dispose() {
    _speech.stop();
    _waveController.dispose();
    super.dispose();
  }

  void _startRecording() async {
    if (!_isSpeechInitialized) {
      await _initSpeech();
    }

    if (_isSpeechInitialized && !_isRecording) {
      setState(() {
        _isRecording = true;
        _isFinished = false;
        _transcriptionText = '';
        _currentSoundLevel = 0.0;
        _statusMessage = 'Mendengarkan...';
      });
      _waveController.repeat();

      await _speech.listen(
        onResult: (SpeechRecognitionResult result) {
          setState(() {
            _transcriptionText = result.recognizedWords;
            if (result.finalResult) {
              _statusMessage = 'Merekam Selesai';
            }
          });
        },
        soundLevelListener: (level) {
          setState(() {
            _currentSoundLevel = level;
          });
        },
      );
    }
  }

  void _stopRecording() async {
    if (_isRecording) {
      await _speech.stop();
      _waveController.stop();
      setState(() {
        _isRecording = false;
        _isFinished = true;
        _statusMessage = 'Rekaman Selesai';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auraColor = AppTheme.getColorForCategory(widget.category);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.surface.withOpacity(0.85),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
          border: Border.all(
            color: Colors.white.withOpacity(0.08),
            width: 1.0,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 18),

            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.mic, color: AppTheme.accent, size: 20),
                SizedBox(width: 8),
                Text(
                  'AuraVoice Asisten Suara (Native)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Outfit',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Sound level dynamic visualizer
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.04)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AnimatedBuilder(
                  animation: _waveController,
                  builder: (context, child) {
                    // level ranges from -2 to ~10dB, normalize it
                    final double amp = _isRecording ? (1.0 + (_currentSoundLevel + 2.0) / 6.0) : 0.08;
                    return CustomPaint(
                      painter: VoiceWavePainter(
                        phase: _waveController.value * 2 * math.pi * 2,
                        amplitudeScale: amp.clamp(0.05, 3.0),
                        waveColor: auraColor,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isRecording ? Colors.redAccent : AppTheme.textSecondary.withOpacity(0.4),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _statusMessage,
                  style: const TextStyle(fontSize: 13, color: Colors.white, fontFamily: 'Outfit'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            if (_transcriptionText.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                constraints: const BoxConstraints(maxHeight: 120),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.02),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: SingleChildScrollView(
                  reverse: true,
                  physics: const BouncingScrollPhysics(),
                  child: Text(
                    _transcriptionText,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textPrimary,
                      height: 1.5,
                      fontFamily: 'Outfit',
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!_isRecording && !_isFinished)
                  ElevatedButton.icon(
                    onPressed: _isSpeechInitialized ? _startRecording : null,
                    icon: const Icon(Icons.play_arrow, color: Colors.white),
                    label: const Text('Mulai Bicara', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: auraColor,
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                if (_isRecording)
                  ElevatedButton.icon(
                    onPressed: _stopRecording,
                    icon: const Icon(Icons.stop, color: Colors.white),
                    label: const Text('Berhenti', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                if (_isFinished) ...[
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isFinished = false;
                        _transcriptionText = '';
                        _statusMessage = 'Siap Merekam';
                      });
                    },
                    child: const Text('Bicara Ulang', style: TextStyle(color: AppTheme.textSecondary)),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      widget.onTextTranscribed(_transcriptionText);
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.check, color: Colors.white),
                    label: const Text('Sematkan Teks', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// Custom Painter to render overlapping dynamic neon sine waves
class VoiceWavePainter extends CustomPainter {
  final double phase;
  final double amplitudeScale;
  final Color waveColor;

  VoiceWavePainter({
    required this.phase,
    required this.amplitudeScale,
    required this.waveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = waveColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path = Path();
    final double midY = size.height / 2;

    // Draw Wave 1 (Base Wave)
    path.reset();
    for (double x = 0; x <= size.width; x += 1) {
      double relativeX = x / size.width;
      double modulation = math.sin(relativeX * math.pi);
      double y = midY + 
          math.sin(relativeX * 2 * math.pi * 1.5 + phase) * 22 * amplitudeScale * modulation;
      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint..color = waveColor.withOpacity(0.85)..strokeWidth = 2.5);

    // Draw Wave 2 (Higher Frequency, Lower Amplitude)
    path.reset();
    for (double x = 0; x <= size.width; x += 1) {
      double relativeX = x / size.width;
      double modulation = math.sin(relativeX * math.pi);
      double y = midY + 
          math.sin(relativeX * 2 * math.pi * 3.2 - phase * 1.6) * 12 * amplitudeScale * modulation;
      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint..color = waveColor.withOpacity(0.45)..strokeWidth = 1.5);

    // Draw Wave 3 (Low Frequency, High Amplitude)
    path.reset();
    for (double x = 0; x <= size.width; x += 1) {
      double relativeX = x / size.width;
      double modulation = math.sin(relativeX * math.pi);
      double y = midY + 
          math.sin(relativeX * 2 * math.pi * 0.8 + phase * 0.4) * 28 * amplitudeScale * modulation;
      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint..color = waveColor.withOpacity(0.2)..strokeWidth = 3.2);
  }

  @override
  bool shouldRepaint(covariant VoiceWavePainter oldDelegate) {
    return oldDelegate.phase != phase || oldDelegate.amplitudeScale != amplitudeScale;
  }
}

// AuraScan Bottom Sheet utilizing real Camera and Google ML Kit Text Recognition
class AuraScanBottomSheet extends StatefulWidget {
  final String category;
  final Function(String) onTextScanned;

  const AuraScanBottomSheet({
    super.key,
    required this.category,
    required this.onTextScanned,
  });

  @override
  State<AuraScanBottomSheet> createState() => _AuraScanBottomSheetState();
}

class _AuraScanBottomSheetState extends State<AuraScanBottomSheet> with SingleTickerProviderStateMixin {
  late AnimationController _scanController;
  final ImagePicker _picker = ImagePicker();
  File? _scannedImageFile;
  bool _isScanning = false;
  bool _isProcessing = false;
  bool _isFinished = false;
  String _scannedText = '';
  String _statusMessage = 'Ambil foto dokumen Anda untuk memindai teks';

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  Future<void> _captureAndScan(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() {
        _scannedImageFile = File(image.path);
        _isScanning = true;
        _isFinished = false;
        _statusMessage = 'Memindai dokumen...';
      });

      // Animating the scan bar
      _scanController.repeat();
      await Future.delayed(const Duration(milliseconds: 1500));
      _scanController.stop();

      setState(() {
        _isScanning = false;
        _isProcessing = true;
        _statusMessage = 'Mengekstrak teks dengan Aura AI Engine...';
      });

      final inputImage = InputImage.fromFilePath(image.path);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      await textRecognizer.close();

      setState(() {
        _scannedText = recognizedText.text.trim();
        _isProcessing = false;
        _isFinished = true;
        _statusMessage = _scannedText.isEmpty 
            ? 'Tidak ada teks terdeteksi di dokumen.' 
            : 'Pemindaian selesai!';
      });
    } catch (e) {
      setState(() {
        _isScanning = false;
        _isProcessing = false;
        _isFinished = true;
        _scannedText = 'Gagal memproses gambar: $e';
        _statusMessage = 'Gagal memindai.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auraColor = AppTheme.getColorForCategory(widget.category);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.surface.withOpacity(0.85),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
          border: Border.all(
            color: Colors.white.withOpacity(0.08),
            width: 1.0,
          ),
        ),
        child: Column(
          children: [
            // Slide indicator
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 14),

            // Header title
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.camera_alt, color: AppTheme.accent, size: 20),
                SizedBox(width: 8),
                Text(
                  'AuraScan Pemindai Dokumen (OCR)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Outfit',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Text(
              _statusMessage,
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary.withOpacity(0.8), fontFamily: 'Outfit'),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Main camera view / OCR text preview box
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(_isFinished ? 0.25 : 0.6),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _isFinished ? Colors.white.withOpacity(0.08) : auraColor.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Show Image Preview when picked
                      if (_scannedImageFile != null)
                        Positioned.fill(
                          child: Opacity(
                            opacity: _isFinished ? 0.2 : 0.8,
                            child: Image.file(
                              _scannedImageFile!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                      // Viewfinder Grid/Laser sweep (when scanning)
                      if (_isScanning)
                        Positioned.fill(
                          child: AnimatedBuilder(
                            animation: _scanController,
                            builder: (context, child) {
                              return CustomPaint(
                                painter: ScanViewfinderPainter(
                                  scanProgress: _scanController.value,
                                  isScanning: _isScanning,
                                  scanColor: auraColor,
                                );
                              };
                            },
                          ),
                        ),

                      // Default UI before picking
                      if (_scannedImageFile == null)
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.document_scanner, size: 64, color: auraColor.withOpacity(0.25)),
                            const SizedBox(height: 12),
                            Text(
                              'Posisikan dokumen Anda di depan kamera',
                              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary.withOpacity(0.6), fontFamily: 'Outfit'),
                            ),
                          ],
                        ),

                      // Processing Spinner (ML Kit extraction)
                      if (_isProcessing)
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(auraColor)),
                            const SizedBox(height: 16),
                            const Text(
                              'AuraScan Mengekstrak Teks...',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Outfit'),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Mendeteksi karakter digital via ML Engine',
                              style: TextStyle(fontSize: 11, color: AppTheme.textSecondary, fontFamily: 'Outfit'),
                            ),
                          ],
                        ),

                      // Finished Text Result Preview
                      if (_isFinished)
                        Positioned.fill(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      _scannedText.isEmpty ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                                      color: _scannedText.isEmpty ? Colors.amberAccent : Colors.greenAccent,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _scannedText.isEmpty ? 'Gagal Deteksi OCR' : 'Hasil Deteksi OCR',
                                      style: TextStyle(
                                        fontSize: 12, 
                                        fontWeight: FontWeight.bold, 
                                        color: _scannedText.isEmpty ? Colors.amberAccent : Colors.greenAccent, 
                                        fontFamily: 'Outfit',
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Expanded(
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.02),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.white.withOpacity(0.04)),
                                    ),
                                    child: SingleChildScrollView(
                                      physics: const BouncingScrollPhysics(),
                                      child: Text(
                                        _scannedText.isEmpty 
                                            ? 'Tidak ada teks yang dapat dibaca pada gambar. Pastikan dokumen cukup terang dan teks terbaca jelas.' 
                                            : _scannedText,
                                        style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary, fontFamily: 'Outfit', height: 1.4),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Controls Panel
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!_isScanning && !_isProcessing && !_isFinished) ...[
                  // Gallery Button
                  ElevatedButton.icon(
                    onPressed: () => _captureAndScan(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library, color: Colors.white, size: 18),
                    label: const Text('Galeri', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.surface.withOpacity(0.4),
                      side: BorderSide(color: Colors.white.withOpacity(0.08)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Camera Button
                  ElevatedButton.icon(
                    onPressed: () => _captureAndScan(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                    label: const Text('Kamera', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: auraColor,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ],
                if (_isScanning)
                  ElevatedButton.icon(
                    onPressed: () {
                      _scanController.stop();
                      setState(() {
                        _isScanning = false;
                      });
                    },
                    icon: const Icon(Icons.cancel, color: Colors.white),
                    label: const Text('Batal', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                if (_isFinished) ...[
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isFinished = false;
                        _scannedText = '';
                        _scannedImageFile = null;
                        _statusMessage = 'Ambil foto dokumen Anda untuk memindai teks';
                      });
                    },
                    child: const Text('Pindai Ulang', style: TextStyle(color: AppTheme.textSecondary)),
                  ),
                  if (_scannedText.isNotEmpty) ...[
                    const SizedBox(width: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        widget.onTextScanned(_scannedText);
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.check, color: Colors.white),
                      label: const Text('Sematkan Teks', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ],
                ],
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

// Custom Painter to draw grid viewfinder corners and glowing neon sweep laser line
class ScanViewfinderPainter extends CustomPainter {
  final double scanProgress;
  final bool isScanning;
  final Color scanColor;

  ScanViewfinderPainter({
    required this.scanProgress,
    required this.isScanning,
    required this.scanColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double pad = 40.0;
    final Rect scanRect = Rect.fromLTWH(pad, pad, size.width - 2 * pad, size.height - 2 * pad);

    // Draw focus corners
    final cornerPaint = Paint()
      ..color = scanColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;

    final double len = 24.0;

    // Top-Left corner
    canvas.drawPath(Path()..moveTo(scanRect.left, scanRect.top + len)..lineTo(scanRect.left, scanRect.top)..lineTo(scanRect.left + len, scanRect.top), cornerPaint);
    // Top-Right corner
    canvas.drawPath(Path()..moveTo(scanRect.right - len, scanRect.top)..lineTo(scanRect.right, scanRect.top)..lineTo(scanRect.right, scanRect.top + len), cornerPaint);
    // Bottom-Left corner
    canvas.drawPath(Path()..moveTo(scanRect.left, scanRect.bottom - len)..lineTo(scanRect.left, scanRect.bottom)..lineTo(scanRect.left + len, scanRect.bottom), cornerPaint);
    // Bottom-Right corner
    canvas.drawPath(Path()..moveTo(scanRect.right - len, scanRect.bottom)..lineTo(scanRect.right, scanRect.bottom)..lineTo(scanRect.right, scanRect.bottom - len), cornerPaint);

    // Draw thin outline
    final boxPaint = Paint()
      ..color = scanColor.withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRect(scanRect, boxPaint);

    // Draw Laser Line
    if (isScanning) {
      final double laserY = scanRect.top + (scanRect.height * scanProgress);
      
      // Laser tail glow
      final glowPaint = Paint()
        ..shader = LinearGradient(
          colors: [scanColor.withOpacity(0.35), scanColor.withOpacity(0.0)],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ).createShader(Rect.fromLTRB(scanRect.left, laserY - 30, scanRect.right, laserY))
        ..style = PaintingStyle.fill;
      
      canvas.drawRect(Rect.fromLTRB(scanRect.left, math.max(scanRect.top, laserY - 30), scanRect.right, laserY), glowPaint);

      // Core bright laser line
      final laserPaint = Paint()
        ..color = scanColor
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;
      
      canvas.drawLine(Offset(scanRect.left, laserY), Offset(scanRect.right, laserY), laserPaint);

      // Edge glow circles
      final dotPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(scanRect.left, laserY), 3.0, dotPaint..color = scanColor);
      canvas.drawCircle(Offset(scanRect.right, laserY), 3.0, dotPaint..color = scanColor);
    }
  }

  @override
  bool shouldRepaint(covariant ScanViewfinderPainter oldDelegate) {
    return oldDelegate.scanProgress != scanProgress || oldDelegate.isScanning != isScanning;
  }
}
