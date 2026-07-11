import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
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
  }

  @override
  void dispose() {
    _scannerController.dispose();
    _verificationTimer?.cancel();
    super.dispose();
  }

  void _startVerification() {
    if (_isSuccess || _isScanning) return;

    setState(() {
      _isScanning = true;
      _statusText = 'Membaca sidik jari...';
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
                onTapDown: (_) => _startVerification(),
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
                            value: _progress,
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
                  'Sentuh sidik jari untuk mulai memverifikasi',
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
