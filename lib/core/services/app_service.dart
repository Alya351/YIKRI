import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

// ─── Modèle Mode Examen ───────────────────────────────────────────────────────

class ModeExamen {
  final bool actif;
  final DateTime? debut;
  final DateTime? fin;
  final bool automatique;
  final List<String> matieres;

  const ModeExamen({
    this.actif = false,
    this.debut,
    this.fin,
    this.automatique = false,
    this.matieres = const [],
  });

  bool get estExpire =>
      fin != null && DateTime.now().isAfter(fin!);

  ModeExamen copyWith({
    bool? actif,
    DateTime? debut,
    DateTime? fin,
    bool? automatique,
    List<String>? matieres,
  }) =>
      ModeExamen(
        actif: actif ?? this.actif,
        debut: debut ?? this.debut,
        fin: fin ?? this.fin,
        automatique: automatique ?? this.automatique,
        matieres: matieres ?? this.matieres,
      );

  Map<String, dynamic> toJson() => {
        'actif': actif,
        'debut': debut?.toIso8601String(),
        'fin': fin?.toIso8601String(),
        'automatique': automatique,
        'matieres': matieres,
      };

  factory ModeExamen.fromJson(Map<String, dynamic> json) => ModeExamen(
        actif: json['actif'] ?? false,
        debut: json['debut'] != null ? DateTime.parse(json['debut']) : null,
        fin: json['fin'] != null ? DateTime.parse(json['fin']) : null,
        automatique: json['automatique'] ?? false,
        matieres: List<String>.from(json['matieres'] ?? []),
      );
}

// ─── Modèle Crédits ──────────────────────────────────────────────────────────

class CreditsInfo {
  /// Crédits de base : 20, jamais déduits, jamais utilisés pour réductions
  static const int baseCredits = 20;

  /// Plafond crédits bonus
  static const int maxBonusCredits = 40;

  /// Déduction inactivité normale (par semaine)
  static const int deductionNormale = 10;

  /// Déduction inactivité en mode examen
  static const int deductionExamen = 2;

  final int bonus; // 0 à 40
  final DateTime? derniereActivite;
  final DateTime? dateInscription; // pour remise à zéro mensuelle
  final DateTime? dernierMoisReset;

  const CreditsInfo({
    this.bonus = 0,
    this.derniereActivite,
    this.dateInscription,
    this.dernierMoisReset,
  });

  /// Crédits totaux affichés = base + bonus
  int get total => baseCredits + bonus;

  CreditsInfo copyWith({
    int? bonus,
    DateTime? derniereActivite,
    DateTime? dateInscription,
    DateTime? dernierMoisReset,
  }) =>
      CreditsInfo(
        bonus: bonus ?? this.bonus,
        derniereActivite: derniereActivite ?? this.derniereActivite,
        dateInscription: dateInscription ?? this.dateInscription,
        dernierMoisReset: dernierMoisReset ?? this.dernierMoisReset,
      );

  Map<String, dynamic> toJson() => {
        'bonus': bonus,
        'derniereActivite': derniereActivite?.toIso8601String(),
        'dateInscription': dateInscription?.toIso8601String(),
        'dernierMoisReset': dernierMoisReset?.toIso8601String(),
      };

  factory CreditsInfo.fromJson(Map<String, dynamic> json) => CreditsInfo(
        bonus: json['bonus'] ?? 0,
        derniereActivite: json['derniereActivite'] != null
            ? DateTime.parse(json['derniereActivite'])
            : null,
        dateInscription: json['dateInscription'] != null
            ? DateTime.parse(json['dateInscription'])
            : null,
        dernierMoisReset: json['dernierMoisReset'] != null
            ? DateTime.parse(json['dernierMoisReset'])
            : null,
      );
}

// ─── Modèle profil ────────────────────────────────────────────────────────────

class UserProfile {
  final String prenom;
  final String nom;
  final String avatar;
  final String classe;
  final String role;
  final String matiere;
  final CreditsInfo creditsInfo;
  final ModeExamen modeExamen;
  final List<String> badges;
  final Map<String, double> progressionCours;
  final Map<String, dynamic> orientationResult;

  const UserProfile({
    required this.prenom,
    this.nom = '',
    required this.avatar,
    required this.classe,
    this.role = 'eleve',
    this.matiere = '',
    this.creditsInfo = const CreditsInfo(),
    this.modeExamen = const ModeExamen(),
    this.badges = const [],
    this.progressionCours = const {},
    this.orientationResult = const {},
  });

  /// Compatibilité avec l'ancien code qui utilisait .credits
  int get credits => creditsInfo.total;

  UserProfile copyWith({
    String? prenom,
    String? nom,
    String? avatar,
    String? classe,
    String? role,
    String? matiere,
    CreditsInfo? creditsInfo,
    ModeExamen? modeExamen,
    List<String>? badges,
    Map<String, double>? progressionCours,
    Map<String, dynamic>? orientationResult,
  }) =>
      UserProfile(
        prenom: prenom ?? this.prenom,
        nom: nom ?? this.nom,
        avatar: avatar ?? this.avatar,
        classe: classe ?? this.classe,
        role: role ?? this.role,
        matiere: matiere ?? this.matiere,
        creditsInfo: creditsInfo ?? this.creditsInfo,
        modeExamen: modeExamen ?? this.modeExamen,
        badges: badges ?? this.badges,
        progressionCours: progressionCours ?? this.progressionCours,
        orientationResult: orientationResult ?? this.orientationResult,
      );

  Map<String, dynamic> toJson() => {
        'prenom': prenom,
        'nom': nom,
        'avatar': avatar,
        'classe': classe,
        'role': role,
        'matiere': matiere,
        'creditsInfo': creditsInfo.toJson(),
        'modeExamen': modeExamen.toJson(),
        'badges': badges,
        'progressionCours': progressionCours,
        'orientationResult': orientationResult,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    // Compatibilité avec l'ancien format (champ 'credits' simple)
    CreditsInfo creditsInfo;
    if (json['creditsInfo'] != null) {
      creditsInfo = CreditsInfo.fromJson(json['creditsInfo']);
    } else {
      final oldCredits = json['credits'] ?? 20;
      final bonus = (oldCredits - CreditsInfo.baseCredits).clamp(0, CreditsInfo.maxBonusCredits);
      creditsInfo = CreditsInfo(bonus: bonus, dateInscription: DateTime.now());
    }

    ModeExamen modeExamen;
    if (json['modeExamen'] != null) {
      modeExamen = ModeExamen.fromJson(json['modeExamen']);
    } else {
      modeExamen = const ModeExamen();
    }

    return UserProfile(
      prenom: json['prenom'] ?? '',
      nom: json['nom'] ?? '',
      avatar: json['avatar'] ?? '🦁',
      classe: json['classe'] ?? 'Terminale D',
      role: json['role'] ?? 'eleve',
      matiere: json['matiere'] ?? '',
      creditsInfo: creditsInfo,
      modeExamen: modeExamen,
      badges: List<String>.from(json['badges'] ?? []),
      progressionCours: Map<String, double>.from(
          (json['progressionCours'] ?? {})
              .map((k, v) => MapEntry(k, (v as num).toDouble()))),
      orientationResult:
          Map<String, dynamic>.from(json['orientationResult'] ?? {}),
    );
  }
}

// ─── Service principal ────────────────────────────────────────────────────────

class AppService extends ChangeNotifier {
  static final AppService _instance = AppService._internal();
  factory AppService() => _instance;
  AppService._internal();

  SharedPreferences? _prefs;
  bool _isOnline = true;
  UserProfile? _profile;
  StreamSubscription? _connectivitySub;
  Timer? _creditCheckTimer;

  bool get isOnline => _isOnline;
  UserProfile? get profile => _profile;
  bool get hasProfile => _profile != null && _profile!.prenom.isNotEmpty;

  // ─── Initialisation ───────────────────────────────────────────────────────

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadProfile();
    await _initConnectivity();
    _startCreditCheck();
  }

  // ─── Connectivité ─────────────────────────────────────────────────────────

  Future<void> _initConnectivity() async {
    final connectivity = Connectivity();
    final result = await connectivity.checkConnectivity();
    _updateOnlineStatus(result);
    _connectivitySub = connectivity.onConnectivityChanged.listen(_updateOnlineStatus);
  }

  void _updateOnlineStatus(List<ConnectivityResult> results) {
    final wasOnline = _isOnline;
    _isOnline = results.any((r) =>
        r == ConnectivityResult.mobile ||
        r == ConnectivityResult.wifi ||
        r == ConnectivityResult.ethernet);
    if (wasOnline != _isOnline) notifyListeners();
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    _creditCheckTimer?.cancel();
    super.dispose();
  }

  // ─── Vérification crédits périodique ─────────────────────────────────────

  void _startCreditCheck() {
    // Vérifie les crédits au démarrage puis toutes les heures
    _verifierCredits();
    _creditCheckTimer = Timer.periodic(
      const Duration(hours: 1),
      (_) => _verifierCredits(),
    );
  }

  Future<void> _verifierCredits() async {
    if (_profile == null) return;
    var info = _profile!.creditsInfo;
    var modeExamen = _profile!.modeExamen;
    bool changed = false;

    // 1. Désactiver Mode Examen expiré
    if (modeExamen.actif && modeExamen.estExpire) {
      modeExamen = modeExamen.copyWith(actif: false);
      changed = true;
    }

    // 2. Remise à zéro mensuelle des crédits bonus
    final now = DateTime.now();
    final dateInscription = info.dateInscription ?? now;
    final dernierReset = info.dernierMoisReset;

    // Calculer si on est dans un nouveau mois depuis l'inscription
    final moisDepuisInscription = (now.year - dateInscription.year) * 12 +
        now.month - dateInscription.month;
    final moisDernierReset = dernierReset != null
        ? (dernierReset.year - dateInscription.year) * 12 +
            dernierReset.month - dateInscription.month
        : -1;

    if (moisDepuisInscription > moisDernierReset) {
      // C'est un nouveau mois depuis l'inscription → remise à zéro des bonus
      info = info.copyWith(
        bonus: 0,
        dernierMoisReset: now,
      );
      changed = true;
    }

    // 3. Déduction inactivité (seulement sur les crédits bonus)
    final derniereActivite = info.derniereActivite;
    if (derniereActivite != null && info.bonus > 0) {
      final semaines = now.difference(derniereActivite).inDays ~/ 7;
      if (semaines >= 1) {
        final deductionParSemaine = modeExamen.actif
            ? CreditsInfo.deductionExamen
            : CreditsInfo.deductionNormale;
        final deductionTotale = (semaines * deductionParSemaine)
            .clamp(0, info.bonus);
        if (deductionTotale > 0) {
          info = info.copyWith(
            bonus: info.bonus - deductionTotale,
            derniereActivite: now, // reset le timer
          );
          changed = true;
        }
      }
    }

    if (changed) {
      await saveProfile(_profile!.copyWith(
        creditsInfo: info,
        modeExamen: modeExamen,
      ));
    }
  }

  // ─── Profil ───────────────────────────────────────────────────────────────

  Future<void> _loadProfile() async {
    final json = _prefs?.getString('user_profile');
    if (json != null) {
      try {
        _profile = UserProfile.fromJson(jsonDecode(json));
      } catch (_) {
        _profile = null;
      }
    }
  }

  Future<void> saveProfile(UserProfile profile) async {
    _profile = profile;
    await _prefs?.setString('user_profile', jsonEncode(profile.toJson()));
    notifyListeners();
  }

  // ─── Crédits ──────────────────────────────────────────────────────────────

  /// Ajouter des crédits bonus via le mini-jeu (+2 par niveau)
  Future<void> ajouterCreditsBonus(int delta) async {
    if (_profile == null) return;
    final info = _profile!.creditsInfo;
    final newBonus = (info.bonus + delta).clamp(0, CreditsInfo.maxBonusCredits);
    await saveProfile(_profile!.copyWith(
      creditsInfo: info.copyWith(
        bonus: newBonus,
        derniereActivite: DateTime.now(),
      ),
    ));
  }

  /// Utiliser des crédits bonus pour une réduction (retourne true si succès)
  /// - 20 crédits bonus = 50% de réduction
  /// - 40 crédits bonus = 100% (cours gratuit)
  Future<bool> utiliserCreditsBonus(int montant) async {
    if (_profile == null) return false;
    final info = _profile!.creditsInfo;
    if (info.bonus < montant) return false;
    await saveProfile(_profile!.copyWith(
      creditsInfo: info.copyWith(
        bonus: info.bonus - montant,
        derniereActivite: DateTime.now(),
      ),
    ));
    return true;
  }

  /// Compatibilité avec l'ancien code updateCredits
  Future<void> updateCredits(int delta) async {
    await ajouterCreditsBonus(delta);
  }

  /// Marquer une activité (empêche la déduction d'inactivité)
  Future<void> marquerActivite() async {
    if (_profile == null) return;
    await saveProfile(_profile!.copyWith(
      creditsInfo: _profile!.creditsInfo.copyWith(
        derniereActivite: DateTime.now(),
      ),
    ));
  }

  /// Calculer la réduction applicable
  /// Retourne: {'reduction': 0.0|0.5|1.0, 'creditsNecessaires': 0|20|40}
  Map<String, dynamic> calculerReduction(int creditsBonus) {
    if (creditsBonus >= 40) return {'reduction': 1.0, 'creditsNecessaires': 40};
    if (creditsBonus >= 20) return {'reduction': 0.5, 'creditsNecessaires': 20};
    return {'reduction': 0.0, 'creditsNecessaires': 0};
  }

  // ─── Mode Examen ──────────────────────────────────────────────────────────

  /// Activer le Mode Examen manuellement
  Future<void> activerModeExamen({
    required DateTime fin,
    List<String> matieres = const [],
  }) async {
    if (_profile == null) return;
    await saveProfile(_profile!.copyWith(
      modeExamen: ModeExamen(
        actif: true,
        debut: DateTime.now(),
        fin: fin,
        automatique: false,
        matieres: matieres,
      ),
    ));
  }

  /// Désactiver le Mode Examen
  Future<void> desactiverModeExamen() async {
    if (_profile == null) return;
    await saveProfile(_profile!.copyWith(
      modeExamen: const ModeExamen(actif: false),
    ));
  }

  bool get modeExamenActif =>
      _profile?.modeExamen.actif == true &&
      !(_profile?.modeExamen.estExpire ?? true);

  DateTime? get modeExamenFin => _profile?.modeExamen.fin;

  // ─── Badges, progression, orientation ────────────────────────────────────

  Future<void> addBadge(String badge) async {
    if (_profile == null) return;
    if (_profile!.badges.contains(badge)) return;
    await saveProfile(_profile!.copyWith(badges: [..._profile!.badges, badge]));
  }

  Future<void> updateProgression(String coursId, double progression) async {
    if (_profile == null) return;
    final newProg = Map<String, double>.from(_profile!.progressionCours);
    newProg[coursId] = progression;
    await saveProfile(_profile!.copyWith(progressionCours: newProg));
  }

  Future<void> saveOrientationResult(Map<String, dynamic> result) async {
    if (_profile == null) return;
    await saveProfile(_profile!.copyWith(orientationResult: result));
  }

  Future<void> clearProfile() async {
    _profile = null;
    await _prefs?.remove('user_profile');
    notifyListeners();
  }

  // ─── Connectivité ─────────────────────────────────────────────────────────

  Future<void> _initConnectivityStream() async {
    final connectivity = Connectivity();
    final result = await connectivity.checkConnectivity();
    _updateOnlineStatus(result);
    _connectivitySub = connectivity.onConnectivityChanged.listen(_updateOnlineStatus);
  }
}
