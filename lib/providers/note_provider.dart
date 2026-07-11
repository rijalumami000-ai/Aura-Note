import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note.dart';
import '../utils/crypt_helper.dart';
import '../services/google_drive_service.dart';

class NoteProvider extends ChangeNotifier {
  final GoogleDriveService _googleDriveService = GoogleDriveService();
  List<Note> _notes = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedCategory = 'Semua';
  String _languageCode = 'id'; // New field
  String? _googleEmail; // New field
  String? _lastSyncTime; // New field
  bool _isSyncEnabled = false; // New field
  bool _isE2eeEnabled = false; // New field
  String? _e2eePassphrase; // New field

  List<Note> get notes => _notes;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  String get languageCode => _languageCode; // Getter
  String? get googleEmail => _googleEmail; // Getter
  String? get lastSyncTime => _lastSyncTime; // Getter
  bool get isSyncEnabled => _isSyncEnabled; // Getter
  bool get isE2eeEnabled => _isE2eeEnabled; // Getter
  String? get e2eePassphrase => _e2eePassphrase; // Getter

  static const String _storageKey = 'auranote_notes_storage';

  NoteProvider() {
    loadNotes();
  }

  // Load notes from SharedPreferences
  Future<void> loadNotes() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      _languageCode = prefs.getString('auranote_language_code') ?? 'id';
      _googleEmail = prefs.getString('auranote_google_email');
      _lastSyncTime = prefs.getString('auranote_last_sync_time');
      _isSyncEnabled = prefs.getBool('auranote_is_sync_enabled') ?? false;
      _isE2eeEnabled = prefs.getBool('auranote_is_e2ee_enabled') ?? false;
      _e2eePassphrase = prefs.getString('auranote_e2ee_passphrase');
      final String? notesJson = prefs.getString(_storageKey);
      if (notesJson != null) {
        final List<dynamic> decodedList = json.decode(notesJson);
        _notes = decodedList.map((item) {
          Note note = Note.fromMap(item);
          if (note.isEncrypted && _isE2eeEnabled && _e2eePassphrase != null && _e2eePassphrase!.isNotEmpty) {
            String decryptedTitle = CryptHelper.decrypt(note.title, _e2eePassphrase!);
            String decryptedContent = CryptHelper.decrypt(note.content, _e2eePassphrase!);
            return note.copyWith(
              title: decryptedTitle,
              content: decryptedContent,
              isEncrypted: false, // in memory it is decrypted
            );
          }
          return note;
        }).toList();
      } else {
        // Add dummy initial notes for gorgeous first-time experience
        _notes = _generateInitialNotes();
        await saveNotesToStorage();
      }
    } catch (e) {
      debugPrint('Error loading notes: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save notes to SharedPreferences
  Future<void> saveNotesToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> mappedList = [];
      for (final n in _notes) {
        Map<String, dynamic> noteMap = n.toMap();
        if (_isE2eeEnabled && _e2eePassphrase != null && _e2eePassphrase!.isNotEmpty) {
          noteMap['title'] = CryptHelper.encrypt(n.title, _e2eePassphrase!);
          noteMap['content'] = CryptHelper.encrypt(n.content, _e2eePassphrase!);
          noteMap['isEncrypted'] = true;
        } else {
          noteMap['isEncrypted'] = false;
        }
        mappedList.add(noteMap);
      }
      final String encodedList = json.encode(mappedList);
      await prefs.setString(_storageKey, encodedList);
    } catch (e) {
      debugPrint('Error saving notes: $e');
    }
  }

  // Set search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Set category filter
  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // Set language setting
  Future<void> setLanguageCode(String code) async {
    _languageCode = code;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auranote_language_code', code);
    } catch (e) {
      debugPrint('Error saving language code: $e');
    }
  }

  // Google Sync Methods
  Future<bool> signInGoogle() async {
    try {
      final account = await _googleDriveService.signIn();
      if (account != null) {
        _googleEmail = account.email;
        _isSyncEnabled = true;
        _lastSyncTime = DateTime.now().toIso8601String();
        notifyListeners();

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auranote_google_email', account.email);
        await prefs.setBool('auranote_is_sync_enabled', true);
        await prefs.setString('auranote_last_sync_time', _lastSyncTime!);
        return true;
      }
    } catch (e) {
      debugPrint('Error signing in Google: $e');
    }
    return false;
  }

  Future<void> signOutGoogle() async {
    try {
      await _googleDriveService.signOut();
    } catch (e) {
      debugPrint('Error signing out Google Drive service: $e');
    }
    _googleEmail = null;
    _isSyncEnabled = false;
    _lastSyncTime = null;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auranote_google_email');
      await prefs.setBool('auranote_is_sync_enabled', false);
      await prefs.remove('auranote_last_sync_time');
    } catch (e) {
      debugPrint('Error saving google sign out: $e');
    }
  }

  Future<bool> performSync() async {
    if (!_isSyncEnabled) return false;
    try {
      // 1. Download notes from cloud if they exist
      final cloudNotes = await _googleDriveService.downloadNotes();
      
      if (cloudNotes != null) {
        // Two-way merge logic
        final Map<String, Note> mergedNotes = {};
        
        // Put all local notes in the map
        for (var note in _notes) {
          mergedNotes[note.id] = note;
        }

        // Merge cloud notes
        for (var cloudNote in cloudNotes) {
          if (mergedNotes.containsKey(cloudNote.id)) {
            final localNote = mergedNotes[cloudNote.id]!;
            // Keep the one with the newer dateModified
            if (cloudNote.dateModified.isAfter(localNote.dateModified)) {
              mergedNotes[cloudNote.id] = cloudNote;
            }
          } else {
            // New note from cloud
            mergedNotes[cloudNote.id] = cloudNote;
          }
        }

        _notes = mergedNotes.values.toList();
      }

      // 2. Upload the final merged list back to cloud
      final success = await _googleDriveService.uploadNotes(_notes);

      if (success) {
        _lastSyncTime = DateTime.now().toIso8601String();
        notifyListeners();
        await saveNotesToStorage();
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auranote_last_sync_time', _lastSyncTime!);
        return true;
      }
    } catch (e) {
      debugPrint('Error performing sync: $e');
    }
    return false;
  }

  // E2EE Crypt Methods
  Future<void> enableE2ee(String passphrase) async {
    _isE2eeEnabled = true;
    _e2eePassphrase = passphrase;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('auranote_is_e2ee_enabled', true);
      await prefs.setString('auranote_e2ee_passphrase', passphrase);
      await saveNotesToStorage();
    } catch (e) {
      debugPrint('Error enabling E2EE: $e');
    }
  }

  Future<void> disableE2ee() async {
    _isE2eeEnabled = false;
    _e2eePassphrase = null;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('auranote_is_e2ee_enabled', false);
      await prefs.remove('auranote_e2ee_passphrase');
      await saveNotesToStorage();
    } catch (e) {
      debugPrint('Error disabling E2EE: $e');
    }
  }

  // Filtered lists based on search & category
  List<Note> getFilteredNotes({
    required bool getPinned,
    required bool getArchived,
    required bool getTrashed,
  }) {
    return _notes.where((note) {
      // Filter by state (Pinned / Archived / Trashed)
      if (getTrashed) return note.isTrashed;
      if (note.isTrashed) return false;

      if (getArchived) return note.isArchived;
      if (note.isArchived) return false;

      if (getPinned && !note.isPinned) return false;
      if (!getPinned && note.isPinned) return false;

      // Filter by category
      if (_selectedCategory != 'Semua' && note.category != _selectedCategory) {
        return false;
      }

      // Filter by search query
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesTitle = note.title.toLowerCase().contains(query);
        final matchesContent = note.content.toLowerCase().contains(query);
        final matchesTodos = note.todos.any((t) => t.title.toLowerCase().contains(query));
        return matchesTitle || matchesContent || matchesTodos;
      }

      return true;
    }).toList();
  }

  // Get active notes (not pinned, not archived, not trashed)
  List<Note> get activeNotes => getFilteredNotes(getPinned: false, getArchived: false, getTrashed: false);

  // Get pinned notes (not archived, not trashed)
  List<Note> get pinnedNotes => getFilteredNotes(getPinned: true, getArchived: false, getTrashed: false);

  // Get archived notes (not trashed)
  List<Note> get archivedNotes => getFilteredNotes(getPinned: false, getArchived: true, getTrashed: false);

  // Get trashed notes
  List<Note> get trashedNotes => getFilteredNotes(getPinned: false, getArchived: false, getTrashed: true);

  // Add a new note
  Future<void> addNote(Note note) async {
    _notes.insert(0, note);
    notifyListeners();
    await saveNotesToStorage();
  }

  // Update an existing note
  Future<void> updateNote(Note updatedNote) async {
    final index = _notes.indexWhere((n) => n.id == updatedNote.id);
    if (index != -1) {
      _notes[index] = updatedNote.copyWith(dateModified: DateTime.now());
      notifyListeners();
      await saveNotesToStorage();
    }
  }

  // Toggle Pinned status
  Future<void> togglePin(String noteId) async {
    final index = _notes.indexWhere((n) => n.id == noteId);
    if (index != -1) {
      _notes[index] = _notes[index].copyWith(
        isPinned: !_notes[index].isPinned,
        dateModified: DateTime.now(),
      );
      notifyListeners();
      await saveNotesToStorage();
    }
  }

  // Toggle Archived status
  Future<void> toggleArchive(String noteId) async {
    final index = _notes.indexWhere((n) => n.id == noteId);
    if (index != -1) {
      _notes[index] = _notes[index].copyWith(
        isArchived: !_notes[index].isArchived,
        isPinned: false, // Unpin if archived
        dateModified: DateTime.now(),
      );
      notifyListeners();
      await saveNotesToStorage();
    }
  }

  // Toggle Lock status
  Future<void> toggleNoteLock(String noteId) async {
    final index = _notes.indexWhere((n) => n.id == noteId);
    if (index != -1) {
      _notes[index] = _notes[index].copyWith(
        isLocked: !_notes[index].isLocked,
        dateModified: DateTime.now(),
      );
      notifyListeners();
      await saveNotesToStorage();
    }
  }

  // Set note reminder date
  Future<void> setNoteReminder(String noteId, DateTime? date) async {
    final index = _notes.indexWhere((n) => n.id == noteId);
    if (index != -1) {
      _notes[index] = _notes[index].copyWith(
        reminderDate: date,
        clearReminder: date == null,
        dateModified: DateTime.now(),
      );
      notifyListeners();
      await saveNotesToStorage();
    }
  }

  // Move to Trash (Soft delete)
  Future<void> moveToTrash(String noteId) async {
    final index = _notes.indexWhere((n) => n.id == noteId);
    if (index != -1) {
      _notes[index] = _notes[index].copyWith(
        isTrashed: true,
        isPinned: false,
        dateModified: DateTime.now(),
      );
      notifyListeners();
      await saveNotesToStorage();
    }
  }

  // Restore from Trash
  Future<void> restoreFromTrash(String noteId) async {
    final index = _notes.indexWhere((n) => n.id == noteId);
    if (index != -1) {
      _notes[index] = _notes[index].copyWith(
        isTrashed: false,
        dateModified: DateTime.now(),
      );
      notifyListeners();
      await saveNotesToStorage();
    }
  }

  // Delete Permanently
  Future<void> deletePermanently(String noteId) async {
    _notes.removeWhere((n) => n.id == noteId);
    notifyListeners();
    await saveNotesToStorage();
  }

  // Clear Trash
  Future<void> clearTrash() async {
    _notes.removeWhere((n) => n.isTrashed);
    notifyListeners();
    await saveNotesToStorage();
  }

  // Generate local heuristic-based summary for offline AI simulation
  String _generateLocalSummary(Note note) {
    if (note.content.trim().isEmpty && note.todos.isEmpty) {
      return 'Catatan ini kosong. Tuliskan beberapa paragraf atau buat daftar tugas terlebih dahulu agar AuraAI dapat merangkumnya.';
    }

    final buffer = StringBuffer();
    
    // Title/Focus
    final String cleanTitle = note.title.replaceAll(RegExp(r'[^\w\s\u00C0-\u00FF]'), '').trim();
    buffer.writeln('📌 **Fokus Utama**:');
    if (cleanTitle.isNotEmpty) {
      buffer.writeln('Analisis rencana mengenai "$cleanTitle".');
    } else {
      buffer.writeln('Ringkasan ide dari catatan tanpa judul.');
    }
    buffer.writeln();

    // Content extraction
    final sentences = note.content
        .split(RegExp(r'(?<=[.!?])\s+'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    List<String> keyPoints = [];
    
    // Look for sentences with action/important keywords
    final keywords = ['penting', 'harus', 'rencana', 'ide', 'tugas', 'fokus', 'jangan lupa', 'agenda', 'target', 'biaya', 'anggaran', 'sprint', 'prioritas'];
    for (var sentence in sentences) {
      final lower = sentence.toLowerCase();
      if (keywords.any((kw) => lower.contains(kw))) {
        if (keyPoints.length < 3) {
          keyPoints.add(sentence);
        }
      }
    }

    // If we didn't find enough key sentences, take first sentence and/or longest sentences
    if (keyPoints.length < 2 && sentences.isNotEmpty) {
      final sortedByLength = List<String>.from(sentences)
        ..sort((a, b) => b.length.compareTo(a.length));
      for (var s in sortedByLength) {
        if (!keyPoints.contains(s) && keyPoints.length < 3) {
          keyPoints.add(s);
        }
      }
    }

    if (keyPoints.isNotEmpty) {
      buffer.writeln('🔑 **Poin Penting**:');
      for (var point in keyPoints) {
        // Strip markdown list characters if any
        String cleanPt = point.replaceAll(RegExp(r'^[-*+]\s+'), '');
        buffer.writeln('• $cleanPt');
      }
      buffer.writeln();
    }

    // Action items from Todos
    if (note.todos.isNotEmpty) {
      buffer.writeln('⚡ **Rencana Tindakan**:');
      final activeTodos = note.todos.where((t) => !t.isDone).toList();
      final doneTodos = note.todos.where((t) => t.isDone).toList();
      
      if (activeTodos.isNotEmpty) {
        for (int i = 0; i < activeTodos.length && i < 3; i++) {
          final tTitle = activeTodos[i].title.trim().isEmpty ? 'Tugas tanpa nama' : activeTodos[i].title;
          buffer.writeln('☐ Selesaikan tugas: "$tTitle"');
        }
      }
      if (doneTodos.isNotEmpty) {
        buffer.writeln('✓ ${doneTodos.length} tugas telah berhasil diselesaikan.');
      }
    } else {
      buffer.writeln('⚡ **Saran Tindakan**:');
      buffer.writeln('Tindak lanjuti poin-poin di atas dan tambahkan daftar tugas (checklist) untuk melacak kemajuan pengerjaan.');
    }

    return buffer.toString();
  }

  // Trigger AI summarization with a simulated processing delay
  Future<void> summarizeNote(String noteId) async {
    final index = _notes.indexWhere((n) => n.id == noteId);
    if (index != -1) {
      // Simulated AI calculation delay
      await Future.delayed(const Duration(milliseconds: 1800));

      final note = _notes[index];
      final summary = _generateLocalSummary(note);
      
      _notes[index] = note.copyWith(
        aiSummary: summary,
        dateModified: DateTime.now(),
      );
      notifyListeners();
      await saveNotesToStorage();
    }
  }

  // Get note statistics for dashboard
  Map<String, dynamic> getStatistics() {
    final activeCount = _notes.where((n) => !n.isTrashed && !n.isArchived).length;
    final archivedCount = _notes.where((n) => n.isArchived && !n.isTrashed).length;
    final trashedCount = _notes.where((n) => n.isTrashed).length;

    int totalTodos = 0;
    int completedTodos = 0;

    for (var note in _notes.where((n) => !n.isTrashed)) {
      totalTodos += note.todos.length;
      completedTodos += note.todos.where((t) => t.isDone).length;
    }

    double todoProgress = totalTodos > 0 ? (completedTodos / totalTodos) : 0.0;

    // Category distribution
    Map<String, int> categoriesCount = {
      'Pekerjaan': 0,
      'Pribadi': 0,
      'Ide': 0,
      'Keuangan': 0,
      'Gaya Hidup': 0,
    };

    for (var note in _notes.where((n) => !n.isTrashed && !n.isArchived)) {
      if (categoriesCount.containsKey(note.category)) {
        categoriesCount[note.category] = categoriesCount[note.category]! + 1;
      }
    }

    return {
      'activeCount': activeCount,
      'archivedCount': archivedCount,
      'trashedCount': trashedCount,
      'totalTodos': totalTodos,
      'completedTodos': completedTodos,
      'todoProgress': todoProgress,
      'categoriesCount': categoriesCount,
    };
  }

  // Helper: Initial dummy notes to make the app look stunning immediately
  List<Note> _generateInitialNotes() {
    final now = DateTime.now();
    return [
      Note(
        id: 'init_1',
        title: '💡 Ide AuraNote Premium UI',
        content: 'Rencana pembuatan aplikasi catatan tercantik dengan sentuhan neon glow. Gunakan kombinasi warna latar belakang cosmic navy, tumpukan kartu glassmorphic semi-transparan, dan pendaran cahaya (glow effect) di pinggir kartu yang melambangkan kategorinya.',
        category: 'Ide',
        dateCreated: now.subtract(const Duration(hours: 2)),
        dateModified: now.subtract(const Duration(hours: 2)),
        isPinned: true,
        todos: [
          TodoItem(id: 't1', title: 'Inisialisasi Flutter', isDone: true),
          TodoItem(id: 't2', title: 'Rancang Tema Glassmorphic', isDone: true),
          TodoItem(id: 't3', title: 'Tambahkan Efek Aura Neon Kategori', isDone: false),
          TodoItem(id: 't4', title: 'Selesaikan Fitur Papan Gambar AuraDraw', isDone: false),
        ],
      ),
      Note(
        id: 'init_2',
        title: '💼 Agenda Pekerjaan Minggu Ini',
        content: 'Berikut adalah poin-poin penting yang harus diselesaikan untuk sprint pengerjaan aplikasi mobile ini. Pastikan untuk selalu menjalankan flutter analyze secara berkala.',
        category: 'Pekerjaan',
        dateCreated: now.subtract(const Duration(days: 1)),
        dateModified: now.subtract(const Duration(days: 1)),
        todos: [
          TodoItem(id: 'w1', title: 'Perbaiki bug transisi Hero', isDone: true),
          TodoItem(id: 'w2', title: 'Integrasikan local storage SharedPreferences', isDone: true),
          TodoItem(id: 'w3', title: 'Kirim progress update ke klien', isDone: false),
        ],
      ),
      Note(
        id: 'init_3',
        title: '🍕 Daftar Belanja Bulanan',
        content: 'Membeli perlengkapan bulanan dan bahan makanan. Pastikan membelinya di supermarket lokal terdekat.',
        category: 'Pribadi',
        dateCreated: now.subtract(const Duration(days: 2)),
        dateModified: now.subtract(const Duration(days: 2)),
        todos: [
          TodoItem(id: 'p1', title: 'Susu UHT & Keju Cheddar', isDone: false),
          TodoItem(id: 'p2', title: 'Biji kopi arabika medium roast', isDone: true),
          TodoItem(id: 'p3', title: 'Buah apel & pisang segar', isDone: false),
        ],
      ),
      Note(
        id: 'init_4',
        title: '📊 Anggaran Keuangan Projek',
        content: 'Estimasi pendapatan dan alokasi dana operasional untuk pengembangan aplikasi AuraNote mobile.',
        category: 'Keuangan',
        dateCreated: now.subtract(const Duration(days: 3)),
        dateModified: now.subtract(const Duration(days: 3)),
        todos: [
          TodoItem(id: 'f1', title: 'Alokasi beli lisensi asset', isDone: true),
          TodoItem(id: 'f2', title: 'Biaya deployment Google Play Store', isDone: false),
        ],
      ),
      Note(
        id: 'init_5',
        title: '🏃 Target Gaya Hidup Sehat',
        content: 'Rencana olahraga mingguan agar tetap bugar selama masa pengembangan aplikasi.',
        category: 'Gaya Hidup',
        dateCreated: now.subtract(const Duration(days: 4)),
        dateModified: now.subtract(const Duration(days: 4)),
        todos: [
          TodoItem(id: 'l1', title: 'Jogging pagi 5km di hari Minggu', isDone: false),
          TodoItem(id: 'l2', title: 'Minum air putih minimal 3 liter sehari', isDone: true),
        ],
      ),
    ];
  }
}
