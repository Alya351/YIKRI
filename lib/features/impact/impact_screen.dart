import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';

class ImpactScreen extends StatefulWidget {
  const ImpactScreen({super.key});

  @override
  State<ImpactScreen> createState() => _ImpactScreenState();
}

class _ImpactScreenState extends State<ImpactScreen>
    with TickerProviderStateMixin {
  late AnimationController _heroController;
  late AnimationController _cardsController;
  late AnimationController _chartController;
  late AnimationController _pulseController;

  final List<_StatCard> _stats = [
    _StatCard('4 200 000', 'Eleves au\nBurkina Faso', '📚', AppColors.greenMid),
    _StatCard('< 10 %', 'Ont acces a un\ntuteur prive', '😔', AppColors.red),
    _StatCard('1', 'Solution\naccessible', '✨', AppColors.goldMid),
  ];

  final List<_ImpactMetric> _metrics = [
    _ImpactMetric('342', 'Eleves accompagnes', Icons.people_rounded, 0.85),
    _ImpactMetric('89 %', 'Mieux orientes', Icons.explore_rounded, 0.89),
    _ImpactMetric('4.8 / 5', 'Satisfaction eleves', Icons.star_rounded, 0.96),
    _ImpactMetric('+2.3 pts', 'Gain de moyenne', Icons.trending_up_rounded, 0.75),
    _ImpactMetric('18', 'Filieres cartographiees', Icons.school_rounded, 0.60),
    _ImpactMetric('3', 'Profils supportes', Icons.groups_rounded, 1.0),
  ];

  final List<_ProvinceData> _provinces = [
    _ProvinceData('Kadiogo', 142, 0.92),
    _ProvinceData('Houet', 78, 0.74),
    _ProvinceData('Boulgou', 54, 0.61),
    _ProvinceData('Gnagna', 38, 0.48),
    _ProvinceData('Bam', 30, 0.38),
  ];

  @override
  void initState() {
    super.initState();
    _heroController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _cardsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _chartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _heroController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _cardsController.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      _chartController.forward();
    });
  }

  @override
  void dispose() {
    _heroController.dispose();
    _cardsController.dispose();
    _chartController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark2,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHero()),
          SliverToBoxAdapter(child: _buildProblemSection()),
          SliverToBoxAdapter(child: _buildSolutionSection()),
          SliverToBoxAdapter(child: _buildMetricsGrid()),
          SliverToBoxAdapter(child: _buildProvinceChart()),
          SliverToBoxAdapter(child: _buildVisionSection()),
          SliverToBoxAdapter(child: SizedBox(height: MediaQuery.of(context).padding.bottom + 32)),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return AnimatedBuilder(
      animation: _heroController,
      builder: (context, child) {
        final t = CurvedAnimation(parent: _heroController, curve: Curves.easeOutCubic).value;
        return Container(
          width: double.infinity,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 20,
            left: 24,
            right: 24,
            bottom: 40,
          ),
          decoration: BoxDecoration(
            color: AppColors.dark2,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back + label
              Row(children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.white54, size: 16),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.greenMid.withOpacity(0.15),
                    border: Border.all(color: AppColors.greenMid.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'IMPACT & VISION',
                    style: GoogleFonts.sora(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: AppColors.greenMid,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ]),

              const SizedBox(height: 36),

              // Big number animé
              Opacity(
                opacity: t,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - t)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Ligne décorative
                      Container(
                        width: 48, height: 3,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.goldMid, AppColors.greenMid],
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 20),
                      RichText(
                        text: TextSpan(children: [
                          TextSpan(
                            text: 'Transformer\n',
                            style: GoogleFonts.sora(
                              fontSize: 38,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              height: 1.1,
                            ),
                          ),
                          TextSpan(
                            text: "l'education\n",
                            style: GoogleFonts.sora(
                              fontSize: 38,
                              fontWeight: FontWeight.w700,
                              color: AppColors.goldMid,
                              height: 1.1,
                            ),
                          ),
                          TextSpan(
                            text: 'au Burkina.',
                            style: GoogleFonts.sora(
                              fontSize: 38,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              height: 1.1,
                            ),
                          ),
                        ]),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'yikri — le mentor numerique de chaque eleve burkinabe,\npartout, tout le temps, en ligne ou hors ligne.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.45),
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 36),

              // Live counter
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.greenMid.withOpacity(0.08 + _pulseController.value * 0.05),
                      border: Border.all(
                        color: AppColors.greenMid.withOpacity(0.2 + _pulseController.value * 0.1),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(children: [
                      Container(
                        width: 8, height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.greenMid,
                          boxShadow: [BoxShadow(
                            color: AppColors.greenMid.withOpacity(0.5),
                            blurRadius: 6 + _pulseController.value * 4,
                          )],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '342 eleves actifs en ce moment',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.greenMid,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'LIVE',
                        style: GoogleFonts.sora(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AppColors.greenMid,
                          letterSpacing: 1,
                        ),
                      ),
                    ]),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProblemSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 16),
            child: Text(
              'LE PROBLEME',
              style: GoogleFonts.sora(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.white.withOpacity(0.3),
                letterSpacing: 1.5,
              ),
            ),
          ),
          Row(
            children: List.generate(_stats.length, (i) {
              return Expanded(
                child: AnimatedBuilder(
                  animation: _cardsController,
                  builder: (context, child) {
                    final delay = i * 0.2;
                    final t = (CurvedAnimation(
                          parent: _cardsController,
                          curve: Curves.easeOutBack,
                        ).value -
                        delay)
                        .clamp(0.0, 1.0);
                    return Opacity(
                      opacity: t,
                      child: Transform.translate(
                        offset: Offset(0, 30 * (1 - t)),
                        child: Container(
                          margin: EdgeInsets.only(
                            right: i < _stats.length - 1 ? 8 : 0,
                          ),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: _stats[i].color.withOpacity(0.08),
                            border: Border.all(
                              color: _stats[i].color.withOpacity(0.2),
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_stats[i].emoji, style: const TextStyle(fontSize: 20)),
                              const SizedBox(height: 10),
                              Text(
                                _stats[i].value,
                                style: GoogleFonts.sora(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: _stats[i].color,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _stats[i].label,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  color: Colors.white.withOpacity(0.45),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSolutionSection() {
    final features = [
      {'icon': '🧙', 'titre': 'Le Sage IA', 'desc': 'Mentor personnel disponible 24h/24'},
      {'icon': '🧭', 'titre': 'Orientation', 'desc': '18 filieres reelles du Burkina'},
      {'icon': '📱', 'titre': 'Hors ligne', 'desc': 'Fonctionne sans connexion internet'},
      {'icon': '👨‍👧', 'titre': '3 profils', 'desc': 'Eleve, Enseignant et Parent'},
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.green.withOpacity(0.15),
            AppColors.greenMid.withOpacity(0.05),
          ],
        ),
        border: Border.all(color: AppColors.greenMid.withOpacity(0.2), width: 1.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.greenMid,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'LA SOLUTION',
                style: GoogleFonts.sora(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
            ),
          ]),
          const SizedBox(height: 14),
          RichText(
            text: TextSpan(children: [
              TextSpan(
                text: 'yikri ',
                style: GoogleFonts.sora(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.goldMid,
                ),
              ),
              TextSpan(
                text: 'rend accessible\nle meilleur de l\'education.',
                style: GoogleFonts.sora(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
            ]),
          ),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.8,
            children: features.map((f) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Row(children: [
                Text(f['icon']!, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(f['titre']!, style: GoogleFonts.plusJakartaSans(
                      fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white,
                    )),
                    Text(f['desc']!, style: GoogleFonts.plusJakartaSans(
                      fontSize: 9, color: Colors.white.withOpacity(0.4), height: 1.3,
                    )),
                  ],
                )),
              ]),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 14),
            child: Text(
              'RESULTATS EN CHIFFRES',
              style: GoogleFonts.sora(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.white.withOpacity(0.3),
                letterSpacing: 1.5,
              ),
            ),
          ),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.6,
            children: _metrics.map((m) {
              return AnimatedBuilder(
                animation: _chartController,
                builder: (context, child) {
                  final t = CurvedAnimation(
                    parent: _chartController,
                    curve: Curves.easeOutCubic,
                  ).value;
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F2019),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.07),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Icon(m.icon, color: AppColors.greenMid, size: 16),
                          const Spacer(),
                          Text(
                            '${(m.progress * 100 * t).toInt()}%',
                            style: GoogleFonts.sora(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.greenMid.withOpacity(0.6),
                            ),
                          ),
                        ]),
                        const Spacer(),
                        Text(
                          m.value,
                          style: GoogleFonts.sora(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          m.label,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            color: Colors.white.withOpacity(0.4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: m.progress * t,
                            backgroundColor: Colors.white.withOpacity(0.06),
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.greenMid),
                            minHeight: 3,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildProvinceChart() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F2019),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(
              'ADOPTION PAR PROVINCE',
              style: GoogleFonts.sora(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.white.withOpacity(0.3),
                letterSpacing: 1.2,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.goldMid.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Burkina Faso',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: AppColors.goldMid,
                ),
              ),
            ),
          ]),
          const SizedBox(height: 20),
          ..._provinces.map((p) => AnimatedBuilder(
            animation: _chartController,
            builder: (context, child) {
              final t = CurvedAnimation(
                parent: _chartController,
                curve: Curves.easeOutCubic,
              ).value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      SizedBox(
                        width: 90,
                        child: Text(
                          p.name,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Stack(children: [
                          Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: p.ratio * t,
                            child: Container(
                              height: 8,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [AppColors.greenMid, AppColors.goldMid],
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ]),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 30,
                        child: Text(
                          '${p.count}',
                          style: GoogleFonts.sora(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.greenMid,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ]),
                  ],
                ),
              );
            },
          )),
        ],
      ),
    );
  }

  Widget _buildVisionSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1B4A2E), Color(0xFF0F2019)],
        ),
        border: Border.all(color: AppColors.goldMid.withOpacity(0.2), width: 1.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'VISION 2026',
            style: GoogleFonts.sora(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: AppColors.goldMid.withOpacity(0.7),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            '100 000 eleves\naccompagnes.',
            style: GoogleFonts.sora(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Etendre yikri a toutes les 13 regions\ndu Burkina Faso. Puis a l Afrique de l Ouest.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: Colors.white.withOpacity(0.5),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
          // Roadmap
          _buildRoadmapItem('2025', 'Prototype · Burkina Faso', true),
          _buildRoadmapItem('2026', '100 000 eleves · 13 regions', false),
          _buildRoadmapItem('2027', 'Expansion Afrique de l Ouest', false),
        ],
      ),
    );
  }

  Widget _buildRoadmapItem(String year, String desc, bool done) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
            color: done ? AppColors.goldMid : Colors.white.withOpacity(0.07),
            shape: BoxShape.circle,
            border: Border.all(
              color: done ? AppColors.goldMid : Colors.white.withOpacity(0.15),
              width: 1.5,
            ),
          ),
          child: Center(
            child: done
                ? const Icon(Icons.check, color: Colors.white, size: 12)
                : Container(
                    width: 6, height: 6,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white24,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            year,
            style: GoogleFonts.sora(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: done ? AppColors.goldMid : Colors.white.withOpacity(0.3),
            ),
          ),
          Text(
            desc,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: done ? Colors.white.withOpacity(0.8) : Colors.white.withOpacity(0.35),
            ),
          ),
        ]),
      ]),
    );
  }
}

class _StatCard {
  final String value;
  final String label;
  final String emoji;
  final Color color;
  const _StatCard(this.value, this.label, this.emoji, this.color);
}

class _ImpactMetric {
  final String value;
  final String label;
  final IconData icon;
  final double progress;
  const _ImpactMetric(this.value, this.label, this.icon, this.progress);
}

class _ProvinceData {
  final String name;
  final int count;
  final double ratio;
  const _ProvinceData(this.name, this.count, this.ratio);
}
