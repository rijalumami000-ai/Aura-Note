import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/googleapis_auth.dart' as gauth;
import 'package:http/http.dart' as http;
import '../models/note.dart';

/// Authenticated HTTP client that injects Google OAuth headers
class _GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  _GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _client.send(request);
  }
}

/// Service responsible for all Google Drive backup/restore operations
class GoogleDriveService {
  static const String _backupFileName = 'auranote_backup.json';
  static const String _backupMimeType = 'application/json';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      drive.DriveApi.driveFileScope,
    ],
  );

  GoogleSignInAccount? _currentUser;

  GoogleSignInAccount? get currentUser => _currentUser;
  bool get isSignedIn => _currentUser != null;
  String? get userEmail => _currentUser?.email;

  /// Sign in with Google and return the user account
  Future<GoogleSignInAccount?> signIn() async {
    try {
      _currentUser = await _googleSignIn.signIn();
      return _currentUser;
    } catch (e) {
      debugPrint('GoogleDriveService.signIn error: $e');
      return null;
    }
  }

  /// Sign out of Google
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    _currentUser = null;
  }

  /// Try to silently sign in (for restoring sessions)
  Future<GoogleSignInAccount?> silentSignIn() async {
    try {
      _currentUser = await _googleSignIn.signInSilently();
      return _currentUser;
    } catch (e) {
      debugPrint('GoogleDriveService.silentSignIn error: $e');
      return null;
    }
  }

  /// Get authenticated Drive API client
  Future<drive.DriveApi?> _getDriveApi() async {
    final account = _currentUser ?? await silentSignIn();
    if (account == null) return null;

    final authHeaders = await account.authHeaders;
    final client = _GoogleAuthClient(authHeaders);
    return drive.DriveApi(client);
  }

  /// Find existing backup file on Drive, returns file ID or null
  Future<String?> _findBackupFileId(drive.DriveApi driveApi) async {
    try {
      final fileList = await driveApi.files.list(
        q: "name = '$_backupFileName' and trashed = false",
        spaces: 'drive',
        $fields: 'files(id, name)',
      );
      if (fileList.files != null && fileList.files!.isNotEmpty) {
        return fileList.files!.first.id;
      }
    } catch (e) {
      debugPrint('GoogleDriveService._findBackupFileId error: $e');
    }
    return null;
  }

  /// Upload notes as JSON backup to Google Drive
  /// Returns true on success
  Future<bool> uploadNotes(List<Note> notes) async {
    try {
      final driveApi = await _getDriveApi();
      if (driveApi == null) return false;

      // Serialize notes to JSON
      final jsonData = jsonEncode(notes.map((n) => n.toMap()).toList());
      final bytes = utf8.encode(jsonData);
      final media = drive.Media(
        Stream.value(bytes),
        bytes.length,
        contentType: _backupMimeType,
      );

      // Check if backup file already exists
      final existingId = await _findBackupFileId(driveApi);

      if (existingId != null) {
        // Update existing file
        await driveApi.files.update(
          drive.File(),
          existingId,
          uploadMedia: media,
        );
      } else {
        // Create new file
        final driveFile = drive.File()
          ..name = _backupFileName
          ..mimeType = _backupMimeType;
        await driveApi.files.create(
          driveFile,
          uploadMedia: media,
        );
      }

      debugPrint('GoogleDriveService: Upload successful (${bytes.length} bytes)');
      return true;
    } catch (e) {
      debugPrint('GoogleDriveService.uploadNotes error: $e');
      return false;
    }
  }

  /// Download notes backup from Google Drive
  /// Returns list of notes or null on failure
  Future<List<Note>?> downloadNotes() async {
    try {
      final driveApi = await _getDriveApi();
      if (driveApi == null) return null;

      final existingId = await _findBackupFileId(driveApi);
      if (existingId == null) {
        debugPrint('GoogleDriveService: No backup file found on Drive');
        return null;
      }

      // Download file content
      final response = await driveApi.files.get(
        existingId,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;

      final List<int> dataStore = [];
      await for (final chunk in response.stream) {
        dataStore.addAll(chunk);
      }

      final jsonString = utf8.decode(dataStore);
      final List<dynamic> jsonList = jsonDecode(jsonString);
      final notes = jsonList.map((m) => Note.fromMap(m as Map<String, dynamic>)).toList();

      debugPrint('GoogleDriveService: Download successful (${notes.length} notes)');
      return notes;
    } catch (e) {
      debugPrint('GoogleDriveService.downloadNotes error: $e');
      return null;
    }
  }
}
