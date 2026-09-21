import 'package:flutter/material.dart';
import '../services/app_service.dart';
import '../theme/app_theme.dart';

class OfflineBanner extends StatefulWidget {
  const OfflineBanner({super.key});

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnim;
  bool _showReconnected = false;
  bool _wasOffline = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    AppService().addListener(_onConnectivityChange);
    _checkInitial();
  }

  void _checkInitial() {
    if (!AppService().isOnline) {
      _wasOffline = true;
      _controller.forward();
    }
  }

  void _onConnectivityChange() {
    final isOnline = AppService().isOnline;

    if (!isOnline) {
      // Vient de passer offline
      _wasOffline = true;
      _showReconnected = false;
      setState(() {});
      _controller.forward();
    } else if (_wasOffline) {
      // Vient de se reconnecter
      setState(() => _showReconnected = true);
      // Cacher après 3 secondes
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          _controller.reverse().then((_) {
            if (mounted) {
              setState(() {
                _showReconnected = false;
                _wasOffline = false;
              });
            }
          });
        }
      });
    }
  }

  @override
  void dispose() {
    AppService().removeListener(_onConnectivityChange);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = AppService().isOnline;

    if (isOnline && !_showReconnected && !_wasOffline) {
      return const SizedBox.shrink();
    }

    final isReconnected = isOnline && _showReconnected;

    return SlideTransition(
      position: _slideAnim,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        color: isReconnected ? AppColors.greenMid : const Color(0xFFD32F2F),
        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isReconnected ? Icons.wifi : Icons.wifi_off,
              color: Colors.white,
              size: 14,
            ),
            const SizedBox(width: 8),
            Text(
              isReconnected
                  ? 'Connexion rétablie ✓'
                  : 'Pas de connexion · Mode hors ligne',
              style: TextStyle(fontFamily: 'PlusJakartaSans', 
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}