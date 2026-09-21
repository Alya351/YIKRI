import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/app_service.dart';

// ─── Écran Parent ─────────────────────────────────────────────────────────────

class ParentScreen extends StatefulWidget {
  const ParentScreen({super.key});

  @override
  State<ParentScreen> createState() => _ParentScreenState();
}

class _ParentScreenState extends State<ParentScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  int _semaine = 0; // 0 = cette semaine, 1 = semaine dernière
  bool _lienActif = false;
  bool _modeExamenActif = false;
  final TextEditingController _codeController = TextEditingController();

  // ─── Données enfant ──────────────────────────────────────────────────────────

  final Map<String, dynamic> _enfant = {
    'prenom': 'Aminata',
    'nom': 'Ouédraogo',
    'avatar': '👧',
    'classe': 'Terminale D',
    'niveau': 'Érudit',
    'yikriDepuis': 'Janvier 2025',
  };

  final Map<String, dynamic> _stats = {
    'credits': 42,
    'serie': 7,
    'rang': 12,
    'moyenne': 68,
    'coursAchetes': 8,
    'devoirsFaits': 15,
    'tempsTotal': '12h 40min',
    'defisReussis': 9,
  };

  final List<Map<String, dynamic>> _activitesSemaine = [
    {
      'jour': 'Lun',
      'duree': 45,
      'matiere': 'MATHS',
      'action': 'Cours · Équations',
      'credits': '+3',
    },
    {
      'jour': 'Mar',
      'duree': 30,
      'matiere': 'SVT',
      'action': 'Défi Sage réussi',
      'credits': '+5',
    },
    {
      'jour': 'Mer',
      'duree': 50,
      'matiere': 'PHYS',
      'action': 'Cours · Lois de Newton',
      'credits': '+2',
    },
    {
      'jour': 'Jeu',
      'duree': 0,
      'matiere': '',
      'action': 'Pas de session',
      'credits': '',
    },
    {
      'jour': 'Ven',
      'duree': 40,
      'matiere': 'MATHS',
      'action': 'Quiz · 85% réussi',
      'credits': '+3',
    },
    {
      'jour': 'Sam',
      'duree': 25,
      'matiere': 'FR',
      'action': 'Révision · Dissertation',
      'credits': '+1',
    },
    {
      'jour': 'Dim',
      'duree': 0,
      'matiere': '',
      'action': 'Repos',
      'credits': '',
    },
  ];

  final List<Map<String, dynamic>> _progressionMatieres = [
    {'matiere': 'Mathématiques', 'pct': 0.78, 'delta': '+5%', 'up': true},
    {'matiere': 'SVT', 'pct': 0.65, 'delta': '+3%', 'up': true},
    {'matiere': 'Physique-Chimie', 'pct': 0.52, 'delta': '-2%', 'up': false},
    {'matiere': 'Français', 'pct': 0.70, 'delta': '+1%', 'up': true},
  ];

  final List<Map<String, dynamic>> _alertes = [
    {
      'type': 'bon',
      'icon': '🏆',
      'titre': 'Série de 7 jours !',
      'detail': 'Aminata travaille tous les jours depuis 1 semaine.',
    },
    {
      'type': 'attention',
      'icon': '⚠️',
      'titre': 'Physique en baisse',
      'detail': 'Sa progression en Physique-Chimie a baissé de 2% cette semaine.',
    },
    {
      'type': 'info',
      'icon': '📚',
      'titre': 'Nouveau cours acheté',
      'detail': 'Lois de Newton — Prof. Traoré (200 FCFA).',
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();
    _chargerDonneesEnfant();
  }

  void _chargerDonneesEnfant() {
    // Si un profil est lié, on enrichit les données avec les vraies infos
    final profile = AppService().profile;
    if (profile != null && _lienActif) {
      setState(() {
        _enfant['prenom'] = profile.prenom;
        _enfant['avatar'] = profile.avatar;
        _enfant['classe'] = profile.classe;
        _stats['credits'] = profile.credits;
        _modeExamenActif = AppService().modeExamenActif;
      });
    }
    AppService().addListener(_onProfileUpdate);
  }

  void _onProfileUpdate() {
    if (!mounted) return;
    final profile = AppService().profile;
    if (profile != null && _lienActif) {
      setState(() {
        _enfant['prenom'] = profile.prenom;
        _enfant['avatar'] = profile.avatar;
        _enfant['classe'] = profile.classe;
        _stats['credits'] = profile.credits;
        _modeExamenActif = AppService().modeExamenActif;
      });
    }
  }

  @override
  void dispose() {
    AppService().removeListener(_onProfileUpdate);
    _codeController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAlertes(),
                    const SizedBox(height: 14),
                    _buildStatsRapides(),
                    const SizedBox(height: 14),
                    _buildActiviteSemaine(),
                    const SizedBox(height: 14),
                    _buildProgression(),
                    const SizedBox(height: 14),
                    _buildDerniersDevoirs(),
                    const SizedBox(height: 14),
                    _buildCodeLiaison(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Header ──────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      color: AppColors.dark2,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 14,
        left: 16,
        right: 16,
        bottom: 0,
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(Icons.arrow_back,
                      color: Colors.white54, size: 16),
                ),
              ),
              const SizedBox(width: 12),
              // Avatar enfant
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.greenMid, AppColors.green],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(_enfant['avatar'],
                      style: const TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_enfant['prenom']} ${_enfant['nom']}',
                      style: TextStyle(fontFamily: 'Sora', 
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${_enfant['classe']}',
                      style: TextStyle(fontFamily: 'PlusJakartaSans', 
                        fontSize: 10,
                        color: Colors.white.withOpacity(0.4),
                      ),
                    ),
                  ],
                ),
              ),
              // Badge niveau + mode examen
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.goldMid.withOpacity(0.15),
                      border: Border.all(color: AppColors.goldMid.withOpacity(0.25)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(_enfant['niveau'], style: TextStyle(fontFamily: 'Sora', fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.goldMid)),
                  ),
                  if (_modeExamenActif) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.goldMid.withOpacity(0.1),
                        border: Border.all(color: AppColors.goldMid.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Text('🎓', style: TextStyle(fontSize: 10)),
                        const SizedBox(width: 4),
                        Text('Examen', style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.goldMid)),
                      ]),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Barre stats rapides
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(13),
                topRight: Radius.circular(13),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                _buildStatItem('${_stats['credits']}', 'Crédits',
                    isGold: true),
                _buildStatDiv(),
                _buildStatItem('${_stats['serie']}j', 'Série'),
                _buildStatDiv(),
                _buildStatItem('#${_stats['rang']}', 'Rang'),
                _buildStatDiv(),
                _buildStatItem('${_stats['moyenne']}%', 'Moyenne'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String val, String label, {bool isGold = false}) {
    return Expanded(
      child: Column(
        children: [
          Text(
            val,
            style: TextStyle(fontFamily: 'Sora', 
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isGold ? AppColors.goldMid : Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontFamily: 'PlusJakartaSans', 
              fontSize: 10,
              color: Colors.white.withOpacity(0.35),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDiv() => Container(
        width: 1,
        height: 30,
        color: Colors.white.withOpacity(0.07),
      );

  // ─── Alertes ─────────────────────────────────────────────────────────────────

  Widget _buildAlertes() {
    return Column(
      children: _alertes.map((a) {
        Color bg, border, textColor;
        switch (a['type']) {
          case 'bon':
            bg = AppColors.greenLight;
            border = AppColors.greenMid.withOpacity(0.3);
            textColor = AppColors.green;
            break;
          case 'attention':
            bg = AppColors.redLight;
            border = AppColors.red.withOpacity(0.3);
            textColor = AppColors.red;
            break;
          default:
            bg = AppColors.goldLight;
            border = AppColors.goldMid.withOpacity(0.3);
            textColor = AppColors.gold;
        }
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: bg,
            border: Border.all(color: border, width: 1.5),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(a['icon'], style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      a['titre'],
                      style: TextStyle(fontFamily: 'PlusJakartaSans', 
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    Text(
                      a['detail'],
                      style: TextStyle(fontFamily: 'PlusJakartaSans', 
                        fontSize: 11,
                        color: textColor.withOpacity(0.75),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ─── Stats rapides ────────────────────────────────────────────────────────────

  Widget _buildStatsRapides() {
    final items = [
      {
        'icon': '📚',
        'val': '${_stats['coursAchetes']}',
        'label': 'Cours achetés',
      },
      {
        'icon': '✅',
        'val': '${_stats['devoirsFaits']}',
        'label': 'Devoirs faits',
      },
      {
        'icon': '⏱',
        'val': _stats['tempsTotal'],
        'label': 'Temps total',
      },
      {
        'icon': '🎯',
        'val': '${_stats['defisReussis']}',
        'label': 'Défis réussis',
      },
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 9,
      mainAxisSpacing: 9,
      childAspectRatio: 2.0,
      children: items.map((item) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border.all(color: AppColors.border, width: 1.5),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Row(
            children: [
              Text(item['icon']!, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item['val']!,
                    style: TextStyle(fontFamily: 'Sora', 
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                  ),
                  Text(
                    item['label']!,
                    style: TextStyle(fontFamily: 'PlusJakartaSans', 
                      fontSize: 10,
                      color: AppColors.text3,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ─── Activité semaine ─────────────────────────────────────────────────────────

  Widget _buildActiviteSemaine() {
    final maxDuree = _activitesSemaine
        .map((a) => a['duree'] as int)
        .reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border, width: 1.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Activité de la semaine',
                style: TextStyle(fontFamily: 'Sora', 
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
              // Toggle semaine
              Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: ['Cette sem.', 'Précédente']
                      .asMap()
                      .entries
                      .map((e) {
                    final isActive = _semaine == e.key;
                    return GestureDetector(
                      onTap: () => setState(() => _semaine = e.key),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 5),
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.green
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Text(
                          e.value,
                          style: TextStyle(fontFamily: 'PlusJakartaSans', 
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isActive
                                ? Colors.white
                                : AppColors.text3,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Graphique à barres jours
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: _activitesSemaine.map((a) {
              final duree = a['duree'] as int;
              final pct = maxDuree > 0 ? duree / maxDuree : 0.0;
              final hasActivity = duree > 0;
              final isAujourd =
                  a['jour'] == 'Ven'; // simuler aujourd'hui = vendredi

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Column(
                    children: [
                      // Durée
                      if (hasActivity)
                        Text(
                          '${duree}m',
                          style: TextStyle(fontFamily: 'PlusJakartaSans', 
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            color: AppColors.greenMid,
                          ),
                        )
                      else
                        const SizedBox(height: 12),
                      const SizedBox(height: 3),
                      // Barre
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOutCubic,
                        height: hasActivity ? (pct * 60).clamp(8, 60) : 6,
                        decoration: BoxDecoration(
                          color: hasActivity
                              ? (isAujourd
                                  ? AppColors.greenMid
                                  : AppColors.greenLight)
                              : AppColors.border,
                          borderRadius: BorderRadius.circular(4),
                          border: isAujourd
                              ? Border.all(
                                  color: AppColors.greenMid, width: 1.5)
                              : null,
                        ),
                      ),
                      const SizedBox(height: 5),
                      // Jour
                      Text(
                        a['jour'],
                        style: TextStyle(fontFamily: 'PlusJakartaSans', 
                          fontSize: 9,
                          fontWeight: isAujourd
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: isAujourd
                              ? AppColors.greenMid
                              : AppColors.text3,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          // Liste activités récentes
          ...(_activitesSemaine
              .where((a) => (a['duree'] as int) > 0)
              .take(3)
              .map((a) {
            return Container(
              margin: const EdgeInsets.only(bottom: 7),
              padding: const EdgeInsets.symmetric(
                  horizontal: 11, vertical: 9),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.greenLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      a['matiere'],
                      style: TextStyle(fontFamily: 'PlusJakartaSans', 
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: AppColors.green,
                      ),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      a['action'],
                      style: TextStyle(fontFamily: 'PlusJakartaSans', 
                        fontSize: 12,
                        color: AppColors.text,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        '${a['duree']}min',
                        style: TextStyle(fontFamily: 'PlusJakartaSans', 
                          fontSize: 11,
                          color: AppColors.text3,
                        ),
                      ),
                      if ((a['credits'] as String).isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Text(
                          a['credits'],
                          style: TextStyle(fontFamily: 'Sora', 
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.goldMid,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            );
          })),
        ],
      ),
    );
  }

  // ─── Progression matières ─────────────────────────────────────────────────────

  Widget _buildProgression() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border, width: 1.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progression par matière',
            style: TextStyle(fontFamily: 'Sora', 
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 12),
          ..._progressionMatieres.map((p) {
            final isUp = p['up'] as bool;
            return Padding(
              padding: const EdgeInsets.only(bottom: 13),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        p['matiere'],
                        style: TextStyle(fontFamily: 'PlusJakartaSans', 
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            isUp
                                ? Icons.trending_up
                                : Icons.trending_down,
                            size: 13,
                            color: isUp ? AppColors.greenMid : AppColors.red,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            p['delta'],
                            style: TextStyle(fontFamily: 'PlusJakartaSans', 
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color:
                                  isUp ? AppColors.greenMid : AppColors.red,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${((p['pct'] as double) * 100).toInt()}%',
                            style: TextStyle(fontFamily: 'Sora', 
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: p['pct'] as double,
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isUp ? AppColors.greenMid : AppColors.red,
                      ),
                      minHeight: 5,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ─── Derniers devoirs ─────────────────────────────────────────────────────────

  Widget _buildDerniersDevoirs() {
    final devoirs = [
      {
        'titre': 'QCM Maths — Fonctions',
        'date': 'Ven 26 avr.',
        'score': '85%',
        'ok': true,
      },
      {
        'titre': 'Défi Sage · SVT',
        'date': 'Mar 23 avr.',
        'score': 'Réussi',
        'ok': true,
      },
      {
        'titre': 'Dissertation Français',
        'date': 'Lun 22 avr.',
        'score': '14/20',
        'ok': true,
      },
      {
        'titre': 'TP Physique',
        'date': 'Non rendu',
        'score': '—',
        'ok': false,
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border, width: 1.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Text(
              'Derniers devoirs',
              style: TextStyle(fontFamily: 'Sora', 
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          ...devoirs.asMap().entries.map((e) {
            final i = e.key;
            final d = e.value;
            final isLast = i == devoirs.length - 1;
            final ok = d['ok'] as bool;

            return Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                border: isLast
                    ? null
                    : const Border(
                        bottom:
                            BorderSide(color: AppColors.border, width: 1)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: ok ? AppColors.greenLight : AppColors.redLight,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Icon(
                      ok ? Icons.check : Icons.close,
                      size: 14,
                      color: ok ? AppColors.greenMid : AppColors.red,
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          d['titre'] as String,
                          style: TextStyle(fontFamily: 'PlusJakartaSans', 
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.text,
                          ),
                        ),
                        Text(
                          d['date'] as String,
                          style: TextStyle(fontFamily: 'PlusJakartaSans', 
                            fontSize: 11,
                            color: AppColors.text3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: ok
                          ? AppColors.greenLight
                          : AppColors.redLight,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text(
                      d['score'] as String,
                      style: TextStyle(fontFamily: 'Sora', 
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: ok ? AppColors.green : AppColors.red,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ─── Code de liaison ──────────────────────────────────────────────────────────

  Widget _buildCodeLiaison() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border, width: 1.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🔗', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(
                'Liaison avec l\'enfant',
                style: TextStyle(fontFamily: 'Sora', 
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (_lienActif)
            Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: AppColors.greenLight,
                border: Border.all(
                    color: AppColors.greenMid.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle,
                      size: 16, color: AppColors.greenMid),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      'Compte lié à ${_enfant['prenom']} · ${_enfant['classe']}',
                      style: TextStyle(fontFamily: 'PlusJakartaSans', 
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.green,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else ...[
            Text(
              'Demande à ton enfant de générer un code depuis son profil yikri, puis entre-le ici.',
              style: TextStyle(fontFamily: 'PlusJakartaSans', 
                fontSize: 12,
                color: AppColors.text3,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      border:
                          Border.all(color: AppColors.border, width: 1.5),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: TextField(
                      controller: _codeController,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: 'Sora', 
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                        letterSpacing: 2,
                      ),
                      decoration: InputDecoration(
                        hintText: 'YK-XXXX-BF',
                        hintStyle: TextStyle(fontFamily: 'Sora', 
                          fontSize: 14,
                          color: AppColors.text3,
                          letterSpacing: 1,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 13, vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    final code = _codeController.text.trim().toUpperCase();
                    final regex = RegExp(r'^YK-[0-9A-Z]{4}-BF$');
                    if (regex.hasMatch(code) || code.length >= 6) {
                      setState(() {
                        _lienActif = true;
                        // Charger les vraies données du profil lié
                        final profile = AppService().profile;
                        if (profile != null) {
                          _enfant['prenom'] = profile.prenom;
                          _enfant['avatar'] = profile.avatar;
                          _enfant['classe'] = profile.classe;
                          _stats['credits'] = profile.credits;
                          _modeExamenActif = AppService().modeExamenActif;
                          // Ajouter alerte Mode Examen si actif
                          if (_modeExamenActif && !_alertes.any((a) => a['titre'] == 'Mode Examen actif')) {
                            _alertes.insert(0, {
                              'type': 'info',
                              'icon': '🎓',
                              'titre': 'Mode Examen actif',
                              'detail': " ${profile.prenom} est en période d'examen. Ses crédits sont protégés.",
                            });
                          }
                        }
                      });
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Compte lié avec succès ! ✓', style: TextStyle(fontFamily: 'PlusJakartaSans')),
                        backgroundColor: AppColors.green,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Code invalide. Format : YK-XXXX-BF', style: TextStyle(fontFamily: 'PlusJakartaSans')),
                        backgroundColor: AppColors.red,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11)),
                  ),
                  child: Text(
                    'Lier',
                    style: TextStyle(fontFamily: 'PlusJakartaSans', 
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}