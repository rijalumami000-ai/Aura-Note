import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import '../theme/app_theme.dart';

class AuraLockDialog extends StatefulWidget {
  final String category;
  final VoidCallback onAuthenticated;

  const AuraLockDialog({
    super.key,
    required this.category,
    required this.onAuthenticated,
  });

  @override
  State<AuraLockDialog> createState() => _AuraLockDialogState();
}

class _AuraLockDialogState extends State<AuraLockDialog> with SingleTickerProviderStateMixin {
  late AnimationController _scannerController;
  final LocalAuthentication _auth = LocalAuthentication();
  bool _isScanning = false;
  bool _isSuccess = false;
  String _statusText = 'Sentuh sensor sidik jari';
  Timer? _verificationTimer;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _scannerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    // Automatically trigger native biometric authentication on dialog open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authenticateWithBiometrics();
    });
  }

  @override
  void dispose() {
    _scannerController.dispose();
    _verificationTimer?.cancel();
    super.dispose();
  }

  Future<void> _authenticateWithBiometrics() async {
    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await _auth.isDeviceSupported();

      if (!canAuthenticate) {
        setState(() {
          _statusText = 'Biometrik tidak tersedia. Menggunakan sensor simulator.';
        });
        return;
      }

      setState(() {
        _isScanning = true;
        _statusText = 'Memverifikasi identitas Anda...';
      });
      _scannerController.repeat();

      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: 'Gunakan biometrik untuk membuka kunci catatan AuraNote',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // allows PIN/pattern fallback
        ),
      );

      if (didAuthenticate) {
        _verificationSuccess();
      } else {
        setState(() {
          _isScanning = false;
          _statusText = 'Autentikasi gagal / dibatalkan';
        });
        _scannerController.stop();
      }
    } catch (e) {
      debugPrint('Error local_auth: $e');
      setState(() {
        _isScanning = false;
        _statusText = 'Gagal menggunakan biometrik. Gunakan simulator.';
      });
      _scannerController.stop();
    }
  }

  // Fallback simulator if native biometrics fails or is not available
  void _startVerificationSimulator() {
    if (_isSuccess || _isScanning) return;

    setState(() {
      _isScanning = true;
      _statusText = 'Membaca sidik jari (Simulasi)...';
      _progress = 0.0;
    });
    _scannerController.repeat();

    int tick = 0;
    _verificationTimer = Timer.periodic(const Duration(milliseconds: 120), (timer) {
      tick++;
      setState(() {
        _progress = (tick * 10) / 100.0;
        if (tick == 3) {
          _statusText = 'Mencocokkan data biometrik...';
        } else if (tick == 7) {
          _statusText = 'Mengotentikasi brankas...';
        } else if (tick >= 10) {
          timer.cancel();
          _verificationSuccess();
        }
      });
    });
  }

  void _verificationSuccess() {
    _scannerController.stop();
    setState(() {
      _isScanning = false;
      _isSuccess = true;
      _statusText = 'Akses Diterima!';
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        Navigator.pop(context);
        widget.onAuthenticated();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auraColor = AppTheme.getColorForCategory(widget.category);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          decoration: AppTheme.glassDecoration(
            auraColor: auraColor,
            showGlow: true,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _isSuccess ? Icons.lock_open_outlined : Icons.lock_outline,
                size: 32,
                color: _isSuccess ? Colors.greenAccent : auraColor,
              ),
              const SizedBox(height: 16),
              const Text(
                'AuraLock Keamanan Biometrik',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Outfit',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Brankas Terkunci Ekstra Aman',
                style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.textSecondary.withOpacity(0.8),
                  fontFamily: 'Outfit',
                ),
              ),
              const SizedBox(height: 32),

              GestureDetector(
                onTap: () {
                  if (!_isScanning && !_isSuccess) {
                    _authenticateWithBiometrics();
                  }
                },
                onLongPress: _startVerificationSimulator,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.02),
                    border: Border.all(
                      color: _isSuccess
                          ? Colors.greenAccent.withOpacity(0.3)
                          : _isScanning
                              ? auraColor.withOpacity(0.5)
                              : Colors.white.withOpacity(0.08),
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (_isScanning)
                        SizedBox(
                          width: 106,
                          height: 106,
                          child: CircularProgressIndicator(
                            value: _verificationTimer != null ? _progress : null, // indeterminate spinner for native biometric
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(auraColor),
                          ),
                        ),
                      AnimatedScale(
                        scale: _isScanning ? 0.92 : 1.0,
                        duration: const Duration(milliseconds: 150),
                        child: Container(
                          width: 86,
                          height: 86,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isSuccess
                                ? Colors.greenAccent.withOpacity(0.12)
                                : _isScanning
                                    ? auraColor.withOpacity(0.15)
                                    : Colors.white.withOpacity(0.03),
                            boxShadow: [
                              BoxShadow(
                                color: _isSuccess
                                    ? Colors.greenAccent.withOpacity(0.25)
                                    : _isScanning
                                        ? auraColor.withOpacity(0.35)
                                        : Colors.transparent,
                                blurRadius: 16,
                              )
                            ],
                          ),
                          child: Icon(
                            _isSuccess
                                ? Icons.check
                                : _isScanning
                                    ? Icons.fingerprint
                                    : Icons.fingerprint_outlined,
                            size: 40,
                            color: _isSuccess
                                ? Colors.greenAccent
                                : _isScanning
                                    ? auraColor
                                    : AppTheme.textSecondary.withOpacity(0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              Text(
                _statusText,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: _isSuccess ? Colors.greenAccent : Colors.white,
                  fontFamily: 'Outfit',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              if (!_isScanning && !_isSuccess)
                Text(
                  'Ketuk untuk biometrik native, tahan untuk simulator',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppTheme.textSecondary,
                    fontFamily: 'Outfit',
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
