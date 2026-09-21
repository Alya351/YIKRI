import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'app_service.dart';

// ─── Modèle Notification ──────────────────────────────────────────────────────

enum NotifType { info, succes, attention, examen, credits }

class YikriNotif {
  final String id;
  final String titre;
  final String message;
  final NotifType type;
  final DateTime date;
  bool lue;

  YikriNotif({
    required this.id,
    required this.titre,
    required this.message,
    required this.type,
    required this.date,
    this.lue = false,
  });
}

// ─── Service Notifications ────────────────────────────────────────────────────

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final List<YikriNotif> _notifications = [];
  final StreamController<YikriNotif> _streamController = StreamController.broadcast();

  Stream<YikriNotif> get stream => _streamController.stream;
  List<YikriNotif> get toutes => List.unmodifiable(_notifications);
  int get nonLues => _notifications.where((n) => !n.lue).length;

  void init() {
    // Vérifier le profil et générer les notifs initiales
    _verifierEtNotifier();
  }

  void _verifierEtNotifier() {
    final profile = AppService().profile;
    if (profile == null) return;

    // Notif mode examen
    if (AppService().modeExamenActif) {
      final fin = AppService().modeExamenFin;
      if (fin != null) {
        final jours = fin.difference(DateTime.now()).inDays;
        if (jours <= 2) {
          _ajouter(YikriNotif(
            id: 'examen_fin',
            titre: '🎓 Mode Examen bientôt terminé',
            message: 'Ton Mode Examen se termine dans $jours jour${jours > 1 ? 's' : ''}. Tes crédits seront à nouveau soumis aux déductions.',
            type: NotifType.examen,
            date: DateTime.now(),
          ));
        }
      }
    }

    // Notif crédits bonus bas
    final bonus = profile.creditsInfo.bonus;
    if (bonus < 10 && bonus >= 0) {
      _ajouter(YikriNotif(
        id: 'credits_bas',
        titre: '⭐ Crédits bonus faibles',
        message: 'Il te reste $bonus crédits bonus. Joue au mini-jeu pour en gagner plus et obtenir des réductions sur les cours.',
        type: NotifType.credits,
        date: DateTime.now(),
      ));
    }

    // Notif de bienvenue
    _ajouter(YikriNotif(
      id: 'bienvenue',
      titre: '👋 Salam ${profile.prenom} !',
      message: 'Le Sage est prêt à t\'accompagner. Pose-lui une question, fais un défi ou consulte ton plan de révision.',
      type: NotifType.info,
      date: DateTime.now(),
    ));
  }

  void _ajouter(YikriNotif notif) {
    // Éviter les doublons
    if (_notifications.any((n) => n.id == notif.id)) return;
    _notifications.insert(0, notif);
    _streamController.add(notif);
  }

  void ajouterNotif({
    required String id,
    required String titre,
    required String message,
    NotifType type = NotifType.info,
  }) {
    _ajouter(YikriNotif(
      id: id,
      titre: titre,
      message: message,
      type: type,
      date: DateTime.now(),
    ));
  }

  void marquerCommeLue(String id) {
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx != -1) _notifications[idx].lue = true;
  }

  void marquerToutesCommeLues() {
    for (final n in _notifications) n.lue = true;
  }

  void dispose() {
    _streamController.close();
  }
}

// ─── Widget Bannière In-App ───────────────────────────────────────────────────

class YikriNotifBanner extends StatefulWidget {
  final YikriNotif notif;
  final VoidCallback onDismiss;

  const YikriNotifBanner({
    super.key,
    required this.notif,
    required this.onDismiss,
  });

  @override
  State<YikriNotifBanner> createState() => _YikriNotifBannerState();
}

class _YikriNotifBannerState extends State<YikriNotifBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;
  Timer? _autoTimer;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _slideAnim = Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
    _ctrl.forward();
    // Auto-dismiss après 4 secondes
    _autoTimer = Timer(const Duration(seconds: 4), _dismiss);
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    await _ctrl.reverse();
    widget.onDismiss();
  }

  Color get _bgColor {
    switch (widget.notif.type) {
      case NotifType.succes: return AppColors.greenLight;
      case NotifType.attention: return AppColors.redLight;
      case NotifType.examen: return AppColors.goldLight;
      case NotifType.credits: return AppColors.goldLight;
      default: return AppColors.dark;
    }
  }

  Color get _textColor {
    switch (widget.notif.type) {
      case NotifType.succes: return AppColors.green;
      case NotifType.attention: return AppColors.red;
      case NotifType.examen: return AppColors.gold;
      case NotifType.credits: return AppColors.gold;
      default: return Colors.white;
    }
  }

  Color get _borderColor {
    switch (widget.notif.type) {
      case NotifType.succes: return AppColors.greenMid.withOpacity(0.3);
      case NotifType.attention: return AppColors.red.withOpacity(0.3);
      case NotifType.examen: return AppColors.goldMid.withOpacity(0.3);
      case NotifType.credits: return AppColors.goldMid.withOpacity(0.3);
      default: return Colors.white.withOpacity(0.1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnim,
      child: FadeTransition(
        opacity: _fadeAnim,
        child: GestureDetector(
          onTap: _dismiss,
          onVerticalDragEnd: (d) { if (d.primaryVelocity! < 0) _dismiss(); },
          child: Container(
            margin: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 8,
              left: 12, right: 12,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: _bgColor,
              border: Border.all(color: _borderColor, width: 1.5),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 16, offset: const Offset(0, 4))],
            ),
            child: Row(children: [
              // Icône Sage
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  gradient: widget.notif.type == NotifType.info || widget.notif.type == NotifType.succes
                      ? const LinearGradient(colors: [AppColors.goldMid, AppColors.gold])
                      : null,
                  color: widget.notif.type == NotifType.attention ? AppColors.red : null,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(child: Text(
                  widget.notif.type == NotifType.examen ? '🎓' :
                  widget.notif.type == NotifType.succes ? '✅' :
                  widget.notif.type == NotifType.attention ? '⚠️' :
                  widget.notif.type == NotifType.credits ? '⭐' : '🧙',
                  style: const TextStyle(fontSize: 16),
                )),
              ),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(widget.notif.titre, style: TextStyle(fontFamily: 'PlusJakartaSans', 
                    fontSize: 12, fontWeight: FontWeight.w700, color: _textColor)),
                const SizedBox(height: 2),
                Text(widget.notif.message, style: TextStyle(fontFamily: 'PlusJakartaSans', 
                    fontSize: 11, color: _textColor.withOpacity(0.75), height: 1.35),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
              ])),
              const SizedBox(width: 8),
              Icon(Icons.close, size: 14, color: _textColor.withOpacity(0.5)),
            ]),
          ),
        ),
      ),
    );
  }
}

// ─── Overlay Notifications ────────────────────────────────────────────────────

class NotifOverlay extends StatefulWidget {
  final Widget child;
  const NotifOverlay({super.key, required this.child});

  @override
  State<NotifOverlay> createState() => _NotifOverlayState();
}

class _NotifOverlayState extends State<NotifOverlay> {
  final List<YikriNotif> _queue = [];
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    _sub = NotificationService().stream.listen((notif) {
      if (!mounted) return;
      setState(() => _queue.add(notif));
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      widget.child,
      if (_queue.isNotEmpty)
        Positioned(
          top: 0, left: 0, right: 0,
          child: YikriNotifBanner(
            notif: _queue.first,
            onDismiss: () {
              if (mounted) setState(() => _queue.removeAt(0));
            },
          ),
        ),
    ]);
  }
}