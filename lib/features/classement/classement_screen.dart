import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/app_service.dart';

class ClassementScreen extends StatefulWidget {
  const ClassementScreen({super.key});

  @override
  State<ClassementScreen> createState() => _ClassementScreenState();
}

class _ClassementScreenState extends State<ClassementScreen>
    with SingleTickerProviderStateMixin {
  int _periodeActive = 0;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  final List<String> _periodes = ['Hebdo', 'Mensuel', 'Total'];

  final List<Map<String, dynamic>> _classement = [
    {'rang': 1, 'initiales': 'FT', 'nom': 'Fatima Traoré', 'niveau': 'SAGE', 'pts': 1024, 'avatar': '👧', 'couleur': 'gold'},
    {'rang': 2, 'initiales': 'SK', 'nom': 'Salif Kaboré', 'niveau': 'ÉRUDIT', 'pts': 892, 'avatar': '👦', 'couleur': 'silver'},
    {'rang': 3, 'initiales': 'IK', 'nom': 'Ibrahim Kaboré', 'niveau': 'ÉRUDIT', 'pts': 756, 'avatar': '👦', 'couleur': 'bronze'},
    {'rang': 4, 'initiales': 'RO', 'nom': 'Rasmata Ouédraogo', 'niveau': 'SAGE', 'pts': 698, 'avatar': '👧', 'couleur': 'none'},
    {'rang': 5, 'initiales': 'AB', 'nom': 'Adama Bassole', 'niveau': 'ÉRUDIT', 'pts': 634, 'avatar': '👦', 'couleur': 'none'},
    {'rang': 6, 'initiales': 'MS', 'nom': 'Mariam Sawadogo', 'niveau': 'APPRENTI', 'pts': 589, 'avatar': '👧', 'couleur': 'none'},
    {'rang': 7, 'initiales': 'BK', 'nom': 'Brahima Kone', 'niveau': 'ÉRUDIT', 'pts': 567, 'avatar': '👦', 'couleur': 'none'},
    {'rang': 8, 'initiales': 'YO', 'nom': 'Yvette Ouédraogo', 'niveau': 'APPRENTI', 'pts': 543, 'avatar': '👧', 'couleur': 'none'},
    {'rang': 9, 'initiales': 'MD', 'nom': 'Moussa Diallo', 'niveau': 'ÉRUDIT', 'pts': 534, 'avatar': '👦', 'couleur': 'none'},
    {'rang': 10, 'initiales': 'KT', 'nom': 'Kofi Traoré', 'niveau': 'APPRENTI', 'pts': 521, 'avatar': '👦', 'couleur': 'none'},
    {'rang': 11, 'initiales': 'ZO', 'nom': 'Zara Ouédraogo', 'niveau': 'ÉRUDIT', 'pts': 510, 'avatar': '👧', 'couleur': 'none'},
    // Moi — toujours visible
    {'rang': 12, 'initiales': 'AO', 'nom': 'Moi', 'niveau': 'ÉRUDIT', 'pts': 498, 'avatar': '👦', 'couleur': 'me'},
    {'rang': 13, 'initiales': 'AS', 'nom': 'Adama Sawadogo', 'niveau': 'APPRENTI', 'pts': 487, 'avatar': '👦', 'couleur': 'none'},
  ];

  String _monPrenom = 'Aminata';
  Timer? _liveTimer;
  final Random _rand = Random();

  int _monRang = 12;

  int _calculerScoreJoueur() {
    final profile = AppService().profile;
    if (profile == null) return 498;
    // Score basé sur crédits bonus, progression et badges
    final bonus = profile.creditsInfo.bonus;
    final badges = profile.badges.length;
    final progression = profile.progressionCours.values.fold(0.0, (a, b) => a + b);
    return 400 + (bonus * 5) + (badges * 20) + (progression * 10).round();
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _controller.forward();

    // Charger le vrai profil dans le classement
    final profile = AppService().profile;
    if (profile != null) {
      _monPrenom = profile.prenom;
      final score = _calculerScoreJoueur();
      final idx = _classement.indexWhere((e) => e['couleur'] == 'me');
      if (idx != -1) {
        _classement[idx]['nom'] = '${profile.prenom} (moi)';
        _classement[idx]['pts'] = score;
        _classement[idx]['avatar'] = profile.avatar;
        _classement[idx]['initiales'] = profile.prenom.isNotEmpty ? profile.prenom[0] : 'M';
        // Badge niveau selon crédits
        final bonus = profile.creditsInfo.bonus;
        _classement[idx]['niveau'] = bonus >= 30 ? 'SAGE' : bonus >= 15 ? 'ÉRUDIT' : 'APPRENTI';
      }
    }

    // Trier et calculer le vrai rang
    _classement.sort((a, b) => (b['pts'] as int).compareTo(a['pts'] as int));
    for (int i = 0; i < _classement.length; i++) {
      _classement[i]['rang'] = i + 1;
      if (_classement[i]['couleur'] == 'me') _monRang = i + 1;
    }

    // Animation live des autres joueurs
    _liveTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      setState(() {
        for (int i = 0; i < _classement.length; i++) {
          if (_classement[i]['couleur'] != 'me') {
            final delta = _rand.nextInt(7) - 3;
            _classement[i]['pts'] = ((_classement[i]['pts'] as int) + delta).clamp(100, 9999);
          }
        }
        _classement.sort((a, b) => (b['pts'] as int).compareTo(a['pts'] as int));
        for (int i = 0; i < _classement.length; i++) {
          _classement[i]['rang'] = i + 1;
          if (_classement[i]['couleur'] == 'me') _monRang = i + 1;
        }
      });
    });
  }

  @override
  void dispose() {
    _liveTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: _buildPodium(),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          // Sauter les 3 premiers (podium)
                          final item = _classement[index + 3];
                          return _buildRankRow(item);
                        },
                        childCount: _classement.length - 3,
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 20),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 14,
        left: 15,
        right: 15,
        bottom: 12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(Icons.arrow_back,
                      color: AppColors.text2, size: 16),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Classement',
                style: GoogleFonts.sora(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
              const Spacer(),
              // Ma position mise en avant
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.greenLight,
                  border: Border.all(
                      color: AppColors.greenMid.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Tu es #$_monRang',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.green,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Sélecteur période
          Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(11),
            ),
            padding: const EdgeInsets.all(3),
            child: Row(
              children: List.generate(_periodes.length, (i) {
                final isActive = _periodeActive == i;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _periodeActive = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(9),
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                )
                              ]
                            : null,
                      ),
                      child: Text(
                        _periodes[i],
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isActive ? AppColors.text : AppColors.text3,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodium() {
    final top3 = _classement.take(3).toList();
    return Column(
      children: [
        // Avatars podium
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // 2ème
            Expanded(child: _buildPodiumItem(top3[1], height: 80)),
            const SizedBox(width: 8),
            // 1er — plus grand
            Expanded(child: _buildPodiumItem(top3[0], height: 110)),
            const SizedBox(width: 8),
            // 3ème
            Expanded(child: _buildPodiumItem(top3[2], height: 60)),
          ],
        ),
        // Blocs podium
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(child: _buildPodiumBlock('2', 72, AppColors.text3)),
            const SizedBox(width: 8),
            Expanded(child: _buildPodiumBlock('1', 90, AppColors.goldMid)),
            const SizedBox(width: 8),
            Expanded(child: _buildPodiumBlock('3', 54, const Color(0xFFCD7F32))),
          ],
        ),
      ],
    );
  }

  Widget _buildPodiumItem(Map<String, dynamic> item, {required double height}) {
    final isGold = item['couleur'] == 'gold';
    Color avatarBg;
    switch (item['couleur']) {
      case 'gold': avatarBg = AppColors.goldLight; break;
      case 'silver': avatarBg = const Color(0xFFF0F0F0); break;
      case 'bronze': avatarBg = const Color(0xFFFAECD8); break;
      default: avatarBg = AppColors.greenLight;
    }

    return Column(
      children: [
        // Rang
        Text(
          '#${item['rang']}',
          style: GoogleFonts.sora(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isGold ? AppColors.goldMid : AppColors.text3,
          ),
        ),
        const SizedBox(height: 6),
        // Avatar
        Container(
          width: isGold ? 60 : 50,
          height: isGold ? 60 : 50,
          decoration: BoxDecoration(
            color: avatarBg,
            shape: BoxShape.circle,
            border: Border.all(
              color: isGold
                  ? AppColors.goldMid
                  : AppColors.border,
              width: isGold ? 2 : 1.5,
            ),
          ),
          child: Center(
            child: Text(
              item['avatar'],
              style: TextStyle(fontSize: isGold ? 28 : 22),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          item['nom'].toString().split(' ')[0],
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          '${item['pts']} pts',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            color: AppColors.text3,
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _buildPodiumBlock(String rang, double height, Color color) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.7)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Center(
        child: Text(
          rang,
          style: GoogleFonts.sora(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ),
    );
  }

  Widget _buildRankRow(Map<String, dynamic> item) {
    final isMe = item['couleur'] == 'me';
    final isSage = item['niveau'] == 'SAGE';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: isMe ? AppColors.greenLight : AppColors.white,
        border: Border.all(
          color: isMe ? AppColors.greenMid : AppColors.border,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          // Rang
          SizedBox(
            width: 28,
            child: Text(
              '#${item['rang']}',
              textAlign: TextAlign.center,
              style: GoogleFonts.sora(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isMe ? AppColors.green : AppColors.text3,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Avatar
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isMe
                  ? AppColors.greenMid.withOpacity(0.15)
                  : AppColors.background,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Center(
              child: Text(item['avatar'],
                  style: const TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(width: 10),

          // Nom + niveau
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['nom'],
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isMe ? AppColors.green : AppColors.text,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSage
                        ? AppColors.goldLight
                        : isMe
                            ? AppColors.greenLight
                            : AppColors.background,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    item['niveau'],
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: isSage
                          ? AppColors.gold
                          : isMe
                              ? AppColors.green
                              : AppColors.text3,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Points
          Text(
            '${item['pts']} pts',
            style: GoogleFonts.sora(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isMe ? AppColors.green : AppColors.text2,
            ),
          ),
        ],
      ),
    );
  }
}