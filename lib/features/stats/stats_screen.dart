import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';

class StatsNationalesScreen extends StatefulWidget {
  const StatsNationalesScreen({super.key});

  @override
  State<StatsNationalesScreen> createState() => _StatsNationalesScreenState();
}

class _StatsNationalesScreenState extends State<StatsNationalesScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late AnimationController _counterController;
  late Animation<double> _fadeAnim;
  late Animation<double> _pulseAnim;
  late Animation<double> _counterAnim;
  Timer? _liveTimer;
  final Random _rand = Random();

  // Données simulées réalistes
  int _elevesActifs = 1247;
  int _defisResolus = 4832;
  int _coursAchetes = 2341;
  int _enseignants = 89;

  final List<Map<String, dynamic>> _provinces = [
    {'nom': 'Kadiogo', 'eleves': 342, 'actif': true},
    {'nom': 'Houet', 'eleves': 198, 'actif': true},
    {'nom': 'Zoundwéogo', 'eleves': 87, 'actif': true},
    {'nom': 'Bazèga', 'eleves': 134, 'actif': true},
    {'nom': 'Boulgou', 'eleves': 112, 'actif': false},
    {'nom': 'Gnagna', 'eleves': 76, 'actif': true},
    {'nom': 'Gourma', 'eleves': 98, 'actif': false},
    {'nom': 'Sanmatenga', 'eleves': 145, 'actif': true},
    {'nom': 'Sourou', 'eleves': 55, 'actif': false},
    {'nom': 'Mouhoun', 'eleves': 102, 'actif': true},
    {'nom': 'Sissili', 'eleves': 45, 'actif': false},
    {'nom': 'Ioba', 'eleves': 63, 'actif': true},
    {'nom': 'Poni', 'eleves': 38, 'actif': false},
  ];

  final List<Map<String, dynamic>> _activiteRecente = [
    {
      'type': 'defi',
      'msg': 'Aminata O. a relevé un défi Maths',
      'temps': 'il y a 12s',
      'province': 'Kadiogo'
    },
    {
      'type': 'cours',
      'msg': 'Salif K. a acheté "Fonctions dérivées"',
      'temps': 'il y a 28s',
      'province': 'Houet'
    },
    {
      'type': 'badge',
      'msg': 'Fatima T. a débloqué le badge 🔥 7 jours',
      'temps': 'il y a 45s',
      'province': 'Gnagna'
    },
    {
      'type': 'defi',
      'msg': 'Ibrahim K. a réussi son premier défi',
      'temps': 'il y a 1min',
      'province': 'Sanmatenga'
    },
    {
      'type': 'cours',
      'msg': 'Moussa D. a terminé "La cellule"',
      'temps': 'il y a 2min',
      'province': 'Kadiogo'
    },
    {
      'type': 'badge',
      'msg': 'Rasmata O. a atteint le niveau Sage',
      'temps': 'il y a 3min',
      'province': 'Houet'
    },
  ];

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _pulseController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat(reverse: true);
    _counterController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));
    _pulseAnim = Tween<double>(begin: 0.97, end: 1.03).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
    _counterAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _counterController, curve: Curves.easeOut));

    _fadeController.forward();
    _counterController.forward();

    // Simuler des données live qui changent toutes les 3 secondes
    _liveTimer = Timer.periodic(const Duration(seconds: 3), (t) {
      if (mounted) {
        setState(() {
          _elevesActifs += _rand.nextInt(5) - 1;
          _defisResolus += _rand.nextInt(4);
          _coursAchetes += _rand.nextInt(2);
        });
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    _counterController.dispose();
    _liveTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D2118),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D2118), AppColors.dark2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                  child: Column(
                    children: [
                      _buildLiveIndicator(),
                      const SizedBox(height: 16),
                      _buildStatsPrincipales(),
                      const SizedBox(height: 16),
                      _buildCarteBurkina(),
                      const SizedBox(height: 16),
                      _buildActiviteRecente(),
                      const SizedBox(height: 16),
                      _buildMatiereStats(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 14,
        left: 16,
        right: 16,
        bottom: 18,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(11)),
              child:
                  const Icon(Icons.arrow_back, color: Colors.white60, size: 18),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('yikri au Burkina Faso',
                  style: GoogleFonts.sora(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
              Text('Statistiques nationales en temps réel',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 11, color: Colors.white.withOpacity(0.45))),
            ],
          ),
          const Spacer(),
          Text('🇧🇫', style: const TextStyle(fontSize: 24)),
        ],
      ),
    );
  }

  Widget _buildLiveIndicator() {
    return ScaleTransition(
      scale: _pulseAnim,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.greenMid.withOpacity(0.15),
          border: Border.all(color: AppColors.greenMid.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: AppColors.greenMid),
            ),
            const SizedBox(width: 8),
            Text(
              '● DONNÉES EN DIRECT · Mis à jour il y a 3 secondes',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.greenMid,
                  letterSpacing: 0.3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsPrincipales() {
    return AnimatedBuilder(
      animation: _counterAnim,
      builder: (context, child) {
        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.4,
          children: [
            _buildStatCard(
              '${(_elevesActifs * _counterAnim.value).toInt()}',
              'Élèves actifs\naujourd\'hui',
              Icons.people_rounded,
              AppColors.greenMid,
              AppColors.greenLight,
            ),
            _buildStatCard(
              '${(_defisResolus * _counterAnim.value).toInt()}',
              'Défis résolus\nce mois',
              Icons.emoji_events_rounded,
              AppColors.goldMid,
              AppColors.goldLight,
            ),
            _buildStatCard(
              '${(_coursAchetes * _counterAnim.value).toInt()}',
              'Cours achetés\nce mois',
              Icons.menu_book_rounded,
              const Color(0xFF8B5CF6),
              const Color(0xFFF3F0FF),
            ),
            _buildStatCard(
              '$_enseignants',
              'Enseignants\nactifs',
              Icons.school_rounded,
              AppColors.red,
              AppColors.redLight,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
      String val, String label, IconData icon, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        border: Border.all(color: color.withOpacity(0.25)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 18),
          ),
          const Spacer(),
          Text(val,
              style: GoogleFonts.sora(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
          Text(label,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  color: Colors.white.withOpacity(0.45),
                  height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildCarteBurkina() {
    final provincesActives = _provinces.where((p) => p['actif'] == true).length;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Couverture nationale',
                  style: GoogleFonts.sora(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [AppColors.greenMid, AppColors.green]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                    '$provincesActives / ${_provinces.length} provinces',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: _provinces.map((p) {
              final isActif = p['actif'] as bool;
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isActif
                      ? AppColors.greenMid.withOpacity(0.15)
                      : Colors.white.withOpacity(0.05),
                  border: Border.all(
                      color: isActif
                          ? AppColors.greenMid.withOpacity(0.4)
                          : Colors.white.withOpacity(0.08)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActif
                            ? AppColors.greenMid
                            : Colors.white.withOpacity(0.2),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${p['nom']} · ${p['eleves']}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isActif
                            ? AppColors.greenMid
                            : Colors.white.withOpacity(0.3),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActiviteRecente() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Activité en direct',
              style: GoogleFonts.sora(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white)),
          const SizedBox(height: 12),
          ..._activiteRecente.map((a) {
            Color color;
            String emoji;
            switch (a['type']) {
              case 'defi':
                color = AppColors.greenMid;
                emoji = '⚡';
                break;
              case 'cours':
                color = AppColors.goldMid;
                emoji = '📚';
                break;
              default:
                color = const Color(0xFF8B5CF6);
                emoji = '🏆';
            }
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.07),
                border: Border.all(color: color.withOpacity(0.15)),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Row(
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(a['msg'],
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withOpacity(0.85))),
                        Text('${a['province']} · ${a['temps']}',
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                color: Colors.white.withOpacity(0.35))),
                      ],
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

  Widget _buildMatiereStats() {
    final matieres = [
      {
        'label': 'Mathématiques',
        'pct': 0.82,
        'color': AppColors.greenMid,
        'eleves': 1024
      },
      {'label': 'SVT', 'pct': 0.68, 'color': AppColors.goldMid, 'eleves': 847},
      {
        'label': 'Physique-Chimie',
        'pct': 0.54,
        'color': AppColors.red,
        'eleves': 672
      },
      {
        'label': 'Français',
        'pct': 0.71,
        'color': const Color(0xFF8B5CF6),
        'eleves': 889
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Matières les plus suivies',
              style: GoogleFonts.sora(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white)),
          const SizedBox(height: 14),
          ...matieres.map((m) {
            final color = m['color'] as Color;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(m['label'] as String,
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withOpacity(0.85))),
                      Text('${m['eleves']} élèves',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: color,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: AnimatedBuilder(
                      animation: _counterAnim,
                      builder: (context, child) => LinearProgressIndicator(
                        value: (m['pct'] as double) * _counterAnim.value,
                        backgroundColor: Colors.white.withOpacity(0.08),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                        minHeight: 6,
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
}