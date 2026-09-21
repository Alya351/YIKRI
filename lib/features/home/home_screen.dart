import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';
import '../catalogue/catalogue_screen.dart';
import '../sage/defi_screen.dart';
import '../devoirs/devoirs_screen.dart';
import '../profil/profil_screen.dart';
import '../jeu/jeu_screen.dart';
import '../classement/classement_screen.dart';
import '../stats/stats_screen.dart';
import '../sage/sage_screen.dart';
import '../../core/services/app_service.dart';
import '../../core/services/niveau_helper.dart';
import '../../core/services/offline_banner.dart';
import '../orientation/orientation_screen.dart';
import '../calendrier/calendrier_screen.dart';
import '../fiches/fiches_screen.dart';

class HomeScreen extends StatefulWidget {
  final String prenom;
  final String avatar;
  final String classe;

  const HomeScreen({
    super.key,
    this.prenom = 'Aminata',
    this.avatar = '👦',
    this.classe = 'Terminale D',
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _currentTab = 0;
  int _credits = 20;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  List<Map<String, dynamic>> get _coursEnCours {
    final c = widget.classe;
    if (NiveauHelper.isCollege(c)) return [
      {'matiere': 'MATHS', 'titre': 'Arithmétique et fractions', 'progression': 0.55},
      {'matiere': 'FRANÇAIS', 'titre': 'Grammaire et expression', 'progression': 0.40},
    ];
    if (NiveauHelper.isSeconde(c)) return [
      {'matiere': 'MATHS', 'titre': 'Fonctions et graphiques', 'progression': 0.60},
      {'matiere': 'SVT', 'titre': 'Organisation du vivant', 'progression': 0.35},
    ];
    final s = NiveauHelper.getSerie(c);
    if (s == 'A') return [
      {'matiere': 'PHILO', 'titre': 'Liberté et déterminisme', 'progression': 0.67},
      {'matiere': 'FRANÇAIS', 'titre': 'Les figures de style', 'progression': 0.30},
    ];
    if (s == 'C') return [
      {'matiere': 'MATHS', 'titre': 'Intégrales et primitives', 'progression': 0.72},
      {'matiere': 'PHYSIQUE', 'titre': 'Électricité — Lois des circuits', 'progression': 0.45},
    ];
    return [
      {'matiere': 'MATHS', 'titre': 'Fonctions dérivées', 'progression': 0.67},
      {'matiere': 'SVT', 'titre': 'Génétique et hérédité', 'progression': 0.30},
    ];
  }

  @override
  void initState() {
    super.initState();
    final profile = AppService().profile;
    if (profile != null) _credits = profile.credits;
    AppService().addListener(_onCreditsUpdate);
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();
  }

  void _onCreditsUpdate() {
    if (!mounted) return;
    final p = AppService().profile;
    if (p != null) setState(() => _credits = p.credits);
  }

  @override
  void dispose() {
    AppService().removeListener(_onCreditsUpdate);
    _controller.dispose();
    super.dispose();
  }

  // Navigation helper
  void _navigateTo(Widget screen, {bool slideUp = false}) {
    HapticFeedback.selectionClick();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (c, a, b) => screen,
        transitionsBuilder: (c, a, b, child) {
          final slide = Tween<Offset>(
            begin: slideUp ? const Offset(0, 1) : const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic));
          final fade = Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: a, curve: const Interval(0.0, 0.5)));
          return SlideTransition(
            position: slide,
            child: FadeTransition(opacity: fade, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    ).then((_) => setState(() => _currentTab = 0));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            const OfflineBanner(),
            _buildHeader(),
            Expanded(
              child: ColoredBox(
                color: AppColors.white,
                child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Zone hero sombre — Sage + citation
                    _buildHeroSection(),
                    // Contenu clair en bas
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildAccesRapidesV2(),
                          const SizedBox(height: 20),
                          _buildDefiSection(),
                          const SizedBox(height: 20),
                          _buildCoursSection(),
                          const SizedBox(height: 20),
                          if (NiveauHelper.isTerminale(widget.classe) || NiveauHelper.isPremiere(widget.classe))
                            _buildOrientationBanner(),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F2A1A), Color(0xFF1E3828)],
        ),
      ),
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
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [AppColors.greenMid, AppColors.green],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Center(
                    child: Text(widget.avatar,
                        style: const TextStyle(fontSize: 18))),
              ),
              const SizedBox(width: 10),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Bonjour, ${widget.prenom}',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
                Text('${widget.classe} · Niveau Érudit',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 11, color: Colors.white.withOpacity(0.4))),
              ]),
              const Spacer(),
              GestureDetector(
                onTap: () => _showNotifications(),
                child: Stack(children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(11)),
                  child: const Icon(Icons.notifications_outlined,
                      color: Colors.white54, size: 18),
                ),
                Positioned(
                  top: 7,
                  right: 7,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                        color: AppColors.goldMid,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.dark2, width: 1.5)),
                  ),
                ),
              ]),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14), topRight: Radius.circular(14)),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(children: [
              _buildStatItem('$_credits', 'Crédits', isGold: true),
              _buildStatDivider(),
              // FIX: classement cliquable
              _buildStatItem('#12', 'Classement', onTap: () => _navigateTo(const ClassementScreen())),
              _buildStatDivider(),
              _buildStatItem('7j', 'Série'),
              _buildStatDivider(),
              _buildStatItem('68%', 'Moyenne'),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, {bool isGold = false, VoidCallback? onTap}) {
    return Expanded(child: GestureDetector(onTap: onTap, child: Column(children: [
        Text(value,
            style: GoogleFonts.sora(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isGold ? AppColors.goldMid : Colors.white)),
        const SizedBox(height: 2),
        Text(label,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 10, color: Colors.white.withOpacity(0.35))),
      ])));
  }

  Widget _buildStatDivider() {
    return Container(
        width: 1, height: 32, color: Colors.white.withOpacity(0.07));
  }

  Widget _buildMessageSage() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F2A1A), Color(0xFF1A3825)],
        ),
        border: Border.all(color: AppColors.goldMid.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(
          color: Colors.black.withOpacity(0.15),
          blurRadius: 12, offset: const Offset(0, 4),
        )],
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.goldMid, AppColors.gold],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(
              color: AppColors.goldMid.withOpacity(0.3),
              blurRadius: 8,
            )],
          ),
          child: const Center(child: Text('🧙', style: TextStyle(fontSize: 18))),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('LE SAGE', style: GoogleFonts.plusJakartaSans(
              fontSize: 9, fontWeight: FontWeight.w700,
              color: AppColors.goldMid, letterSpacing: 0.8)),
          const SizedBox(height: 4),
          Text(_getMessageContextuel(), style: GoogleFonts.plusJakartaSans(
              fontSize: 13, color: Colors.white.withOpacity(0.85), height: 1.5)),
        ])),
      ]),
    );
  }

  Widget _buildAccesRapides() {
    return Row(children: [
      Expanded(
        child: GestureDetector(
          onTap: () => _navigateTo(CalendrierScreen(classe: widget.classe)),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F2A1A), Color(0xFF1A3825)],
              ),
              border: Border.all(color: AppColors.greenMid.withOpacity(0.25)),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(children: [
              Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                  color: AppColors.greenMid.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Center(child: Text('📅', style: TextStyle(fontSize: 16))),
              ),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Calendrier', style: GoogleFonts.sora(
                    fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                Text('BAC & Concours', style: GoogleFonts.plusJakartaSans(
                    fontSize: 10, color: Colors.white.withOpacity(0.4))),
              ])),
            ]),
          ),
        ),
      ),
      const SizedBox(width: 9),
      Expanded(
        child: GestureDetector(
          onTap: () => _navigateTo(const FichesScreen()),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFEF7E6), Color(0xFFFDF3DC)],
              ),
              border: Border.all(color: AppColors.goldMid.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(children: [
              Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                  color: AppColors.goldMid.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Center(child: Text('📖', style: TextStyle(fontSize: 16))),
              ),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Fiches', style: GoogleFonts.sora(
                    fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.text)),
                Text('Revise en 3 min', style: GoogleFonts.plusJakartaSans(
                    fontSize: 10, color: AppColors.text3)),
              ])),
            ]),
          ),
        ),
      ),
    ]);
  }

  Widget _buildLiveBandeau() {
    return GestureDetector(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => StatsNationalesScreen())),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: AppColors.greenLight,
          border: Border.all(color: AppColors.green.withOpacity(0.15)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(children: [
          Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: AppColors.greenMid)),
          const SizedBox(width: 8),
          Text('1 247 élèves actifs au Burkina Faso aujourd\'hui',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.green)),
        ]),
      ),
    );
  }

  Widget _buildSectionTitle(String title, String action, {VoidCallback? onAction}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: GoogleFonts.sora(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.text)),
        GestureDetector(
          onTap: onAction,
          child: Text(action,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.greenMid)),
        ),
      ],
    );
  }

  Widget _buildDefiCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: AppColors.dark, borderRadius: BorderRadius.circular(15)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.greenMid.withOpacity(0.15),
              border: Border.all(color: AppColors.greenMid.withOpacity(0.2)),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Text('LE SAGE',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppColors.greenMid,
                    letterSpacing: 0.5)),
          ),
          Text('Maths · ${widget.classe}',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 10, color: Colors.white.withOpacity(0.3))),
        ]),
        const SizedBox(height: 10),
        Text(
            _getDefiDuJour(),
            style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: Colors.white.withOpacity(0.82),
                height: 1.55)),
        const SizedBox(height: 13),
        ElevatedButton(
          onPressed: () => _navigateTo(DefiScreen(classe: widget.classe, prenom: widget.prenom)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.greenMid,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text('Relever le défi →',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
        ),
      ]),
    );
  }

  Widget _buildPlanRevision() {
    final jours = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    final c = widget.classe;
    final serie = NiveauHelper.getSerie(c);
    final matieres = NiveauHelper.isCollege(c)
        ? ['MAT', 'FR', 'SVT', 'HIST', 'MAT', 'FR', 'Repos']
        : NiveauHelper.isSeconde(c)
        ? ['MAT', 'PHY', 'SVT', 'FR', 'MAT', 'PHY', 'Repos']
        : serie == 'A'
        ? ['PHILO', 'FR', 'HIST', 'ANG', 'PHILO', 'FR', 'Repos']
        : serie == 'C'
        ? ['MAT', 'PHY', 'MAT', 'CHIM', 'PHY', 'MAT', 'Repos']
        : ['MAT', 'SVT', 'PHY', 'FR', 'MAT', 'SVT', 'Repos'];
    final durees = ['45m', '30m', '45m', '30m', '1h', '45m', ''];
    // Calculer le vrai jour de la semaine (1=Lun, 7=Dim)
    final todayIndex = DateTime.now().weekday - 1; // 0=Lun, 6=Dim
    final statuts = List.generate(7, (i) => i < todayIndex);
    final isToday = List.generate(7, (i) => i == todayIndex);

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border, width: 1.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text('🧙', style: TextStyle(fontSize: 13)),
          const SizedBox(width: 6),
          Text('Plan de révision · Semaine en cours',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text)),
        ]),
        const SizedBox(height: 12),
        Row(
          children: List.generate(7, (i) {
            final done = statuts[i];
            final today = isToday[i];
            final repos = matieres[i] == 'Repos';
            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: done
                      ? AppColors.greenLight
                      : today
                          ? AppColors.dark2
                          : AppColors.background,
                  border: Border.all(
                    color: done
                        ? AppColors.greenMid
                        : today
                            ? AppColors.greenMid
                            : AppColors.border,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Column(children: [
                  Text(jours[i],
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: done
                              ? AppColors.green
                              : today
                                  ? Colors.white
                                  : AppColors.text3)),
                  const SizedBox(height: 4),
                  Text(
                      done
                          ? '✓'
                          : repos
                              ? '—'
                              : matieres[i],
                      style: GoogleFonts.sora(
                          fontSize: repos ? 11 : 8,
                          fontWeight: FontWeight.w700,
                          color: done
                              ? AppColors.greenMid
                              : today
                                  ? AppColors.goldMid
                                  : AppColors.text3),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(durees[i],
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 8,
                          color: done
                              ? AppColors.green
                              : today
                                  ? Colors.white54
                                  : AppColors.text3)),
                ]),
              ),
            );
          }),
        ),
      ]),
    );
  }

  Widget _buildCoursEnCours() {
    return Row(
      children: List.generate(_coursEnCours.length, (i) {
        final cours = _coursEnCours[i];
        return Expanded(
          child: GestureDetector(
            onTap: () => _navigateTo(const CatalogueScreen()),
            child: Container(
            margin: EdgeInsets.only(right: i == 0 ? 9 : 0),
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border.all(color: AppColors.border, width: 1.5),
              borderRadius: BorderRadius.circular(13),
            ),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(cours['matiere'],
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: AppColors.green,
                      letterSpacing: 0.8)),
              const SizedBox(height: 4),
              Text(cours['titre'],
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                      height: 1.4)),
              const SizedBox(height: 9),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: cours['progression'],
                  backgroundColor: AppColors.border,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.greenMid),
                  minHeight: 3,
                ),
              ),
              const SizedBox(height: 4),
              Text('${(cours['progression'] * 100).toInt()}% complété',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 10, color: AppColors.text3)),
            ]),
          ),
          ),
        );
      }),
    );
  }

  Widget _buildRecommandations() {
    final reco = [
      {
        'matiere': 'MATHS',
        'titre': 'Équations du second degré',
        'enseignant': 'Prof. Kaboré',
        'note': '4.8'
      },
      {
        'matiere': 'PHYS',
        'titre': 'Lois de Newton',
        'enseignant': 'Prof. Traoré',
        'note': '4.6'
      },
    ];

    return Column(
      children: reco.map((cours) {
        return Container(
          margin: const EdgeInsets.only(bottom: 9),
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border.all(color: AppColors.border, width: 1.5),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                  color: AppColors.greenLight,
                  borderRadius: BorderRadius.circular(7)),
              child: Text(cours['matiere']!,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: AppColors.green)),
            ),
            const SizedBox(width: 10),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(cours['titre']!,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text)),
                  Text('${cours['enseignant']} · ★ ${cours['note']}',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 11, color: AppColors.text3)),
                ])),
            const SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('200 FCFA',
                  style: GoogleFonts.sora(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text)),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () => _navigateTo(const CatalogueScreen()),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                      color: AppColors.green,
                      borderRadius: BorderRadius.circular(8)),
                  child: Text('Voir',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ),
              ),
            ]),
          ]),
        );
      }).toList(),
    );
  }





  Widget _buildCitationSankara() {
    final citations = [
      'Ose inventer l avenir. La verite est que tout ce que l on fera, personne ne le fera a notre place. — T. Sankara',
      'L education est la cle qui ouvre toutes les portes. Un peuple qui ne lit pas est un peuple qui ne pense pas. — T. Sankara',
      'Tu ne peux pas mener une revolution sans avoir la jeunesse de ton cote. — T. Sankara',
      'Celui qui vous nourrit vous controle. Pensez-y. — T. Sankara',
      'La patrie ou la mort, nous vaincrons ! — T. Sankara',
    ];
    final idx = DateTime.now().day % citations.length;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A0F00), Color(0xFF2A1A00)],
        ),
        border: Border.all(color: AppColors.goldMid.withOpacity(0.25)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.goldMid.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text('✊', style: TextStyle(fontSize: 18)),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('CITATION DU JOUR', style: GoogleFonts.plusJakartaSans(
              fontSize: 9, fontWeight: FontWeight.w700,
              color: AppColors.goldMid, letterSpacing: 1)),
          const SizedBox(height: 6),
          Text(citations[idx], style: GoogleFonts.plusJakartaSans(
              fontSize: 12, color: Colors.white.withOpacity(0.82),
              height: 1.5, fontStyle: FontStyle.italic)),
        ])),
      ]),
    );
  }

  String _getDefiDuJour() {
    final c = widget.classe;
    if (NiveauHelper.isCollege(c)) return 'Calcule : 144 ÷ 12 + 5 × 3. Montre tes calculs etape par etape.';
    if (NiveauHelper.isSeconde(c)) return 'Quelle est l aire d un cercle de rayon 5 cm ? Donne le resultat en cm².';
    final s = NiveauHelper.getSerie(c);
    if (s == 'A') return 'Disserter sur : La liberte est-elle une illusion ? Donne 3 arguments en 5 minutes.';
    if (s == 'C') return 'Calcule la derivee de f(x) = 3x³ - 2x² + 5x - 1. Reflechis avant de repondre.';
    return 'Resous : x² - 5x + 6 = 0. Reflechis avant de repondre — je suis la si tu bloques.';
  }

  String _getRappelMatiere() {
    final c = widget.classe;
    if (NiveauHelper.isCollege(c)) return 'Maths';
    if (NiveauHelper.isSeconde(c)) return 'Physique';
    final s = NiveauHelper.getSerie(c);
    if (s == 'A') return 'Philosophie';
    if (s == 'C') return 'Physique';
    return 'SVT';
  }

  String _getMessageContextuel() {
    final heure = DateTime.now().hour;
    if (heure < 10) return 'Bonjour ' + widget.prenom + ' ! Bonne seance de revision ce matin.';
    if (heure < 13) return 'Bonne matinee ' + widget.prenom + ' ! Le defi du jour t attend.';
    if (heure < 17) return 'Bon apres-midi ' + widget.prenom + ' ! C est le bon moment pour reviser.';
    if (heure < 20) return 'Bonsoir ' + widget.prenom + ' ! Une petite revision avant le diner ?';
    return 'Bonne soiree ' + widget.prenom + ' ! Revise 30 minutes avant de dormir.';
  }


  // ─── Hero section sombre (header étendu) ─────────────────────────────────────
  Widget _buildHeroSection() {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Message Sage compact
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.dark2,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.goldMid, AppColors.gold]),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(child: Text('🧙', style: TextStyle(fontSize: 16))),
              ),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('LE SAGE', style: GoogleFonts.plusJakartaSans(
                    fontSize: 8, fontWeight: FontWeight.w700,
                    color: AppColors.goldMid, letterSpacing: 0.8)),
                const SizedBox(height: 2),
                Text(_getMessageContextuel(), style: GoogleFonts.plusJakartaSans(
                    fontSize: 12, color: Colors.white.withOpacity(0.85), height: 1.4)),
              ])),
            ]),
          ),
          const SizedBox(height: 10),
          // Live + Citation sur une ligne
          Row(children: [
            GestureDetector(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => StatsNationalesScreen())),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.greenLight,
                  border: Border.all(color: AppColors.greenMid.withOpacity(0.2)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(width: 5, height: 5,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.greenMid)),
                  const SizedBox(width: 5),
                  Text('1 247 actifs · LIVE', style: GoogleFonts.plusJakartaSans(
                      fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.green)),
                ]),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(
              '✊ ' + _getCitationDuJour(),
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 10, color: AppColors.text3,
                  fontStyle: FontStyle.italic),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )),
          ]),
          const SizedBox(height: 14),
        ],
      ),
    );
  }

  String _getCitationDuJour() {
    final citations = [
      'Ose inventer l avenir. — T. Sankara',
      'L education est la cle qui ouvre toutes les portes. — T. Sankara',
      'Tu ne peux pas mener une revolution sans la jeunesse. — T. Sankara',
      'Celui qui vous nourrit vous controle. Pensez-y. — T. Sankara',
      'La patrie ou la mort, nous vaincrons ! — T. Sankara',
    ];
    return citations[DateTime.now().day % citations.length];
  }

  // ─── Accès rapides redesignés ─────────────────────────────────────────────────
  Widget _buildAccesRapidesV2() {
    final items = [
      {'emoji': '📅', 'label': 'Calendrier', 'sub': 'BAC & concours',
       'onTap': () => _navigateTo(CalendrierScreen(classe: widget.classe)),
       'color': AppColors.greenMid},
      {'emoji': '📖', 'label': 'Fiches', 'sub': 'Révise en 3 min',
       'onTap': () => _navigateTo(FichesScreen(classe: widget.classe)),
       'color': AppColors.goldMid},
      {'emoji': '🏆', 'label': 'Classement', 'sub': 'Tu es #12',
       'onTap': () => _navigateTo(const ClassementScreen()),
       'color': AppColors.red},
    ];
    return Row(
      children: items.map((item) {
        final color = item['color'] as Color;
        return Expanded(
          child: GestureDetector(
            onTap: item['onTap'] as VoidCallback,
            child: Container(
              margin: EdgeInsets.only(
                right: item != items.last ? 8 : 0,
              ),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
                boxShadow: [BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8, offset: const Offset(0, 2),
                )],
              ),
              child: Column(children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(child: Text(item['emoji'] as String,
                      style: const TextStyle(fontSize: 18))),
                ),
                const SizedBox(height: 8),
                Text(item['label'] as String, style: GoogleFonts.sora(
                    fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.text)),
                const SizedBox(height: 2),
                Text(item['sub'] as String, style: GoogleFonts.plusJakartaSans(
                    fontSize: 9, color: AppColors.text3), textAlign: TextAlign.center),
              ]),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ─── Section défi + plan ─────────────────────────────────────────────────────
  Widget _buildDefiSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _buildSectionTitle('Défi du jour', '+5 crédits'),
      const SizedBox(height: 10),
      _buildDefiCard(),
      const SizedBox(height: 20),
      _buildSectionTitle('Plan de révision', 'Voir tout',
          onAction: () => _navigateTo(DevoirsScreen())),
      const SizedBox(height: 10),
      _buildPlanRevision(),
    ]);
  }

  // ─── Section cours ────────────────────────────────────────────────────────────
  Widget _buildCoursSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _buildSectionTitle('En cours', 'Voir tout',
          onAction: () => _navigateTo(CatalogueScreen(classe: widget.classe))),
      const SizedBox(height: 10),
      _buildCoursEnCours(),
      const SizedBox(height: 20),
      _buildSectionTitle('Recommandés', 'Catalogue',
          onAction: () => _navigateTo(CatalogueScreen(classe: widget.classe))),
      const SizedBox(height: 10),
      _buildRecommandations(),
    ]);
  }

  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final notifs = <Map<String, dynamic>>[
          {'icon': '🎯', 'titre': 'Defi du jour disponible', 'desc': 'Resous le defi du Sage et gagne +5 credits', 'time': 'Il y a 5 min', 'lu': false},
          {'icon': '📚', 'titre': 'Nouveau cours disponible', 'desc': 'Les fonctions derivees - Terminale C et D', 'time': 'Il y a 1h', 'lu': false},
          {'icon': '🏆', 'titre': 'Tu es passe au rang Erudit', 'desc': 'Continue comme ca, tu progresses bien !', 'time': 'Hier', 'lu': true},
          {'icon': '📅', 'titre': 'Rappel revision', 'desc': _getRappelMatiere() + ' prevu aujourd hui - 30 minutes', 'time': 'Hier', 'lu': true},
        ];
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Text('Notifications',
                      style: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.text)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: AppColors.goldLight, borderRadius: BorderRadius.circular(6)),
                    child: Text('2 nouvelles', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.gold)),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.border),
            ...notifs.map((n) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: n['lu'] as bool ? AppColors.white : AppColors.greenLight.withOpacity(0.3),
                border: const Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(n['icon'] as String, style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(n['titre'] as String, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.text)),
                      const SizedBox(height: 2),
                      Text(n['desc'] as String, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.text3, height: 1.4)),
                      const SizedBox(height: 3),
                      Text(n['time'] as String, style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.text3)),
                    ],
                  )),
                  if (!(n['lu'] as bool))
                    Container(width: 7, height: 7, margin: const EdgeInsets.only(top: 4),
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.greenMid)),
                ],
              ),
            )),
            SizedBox(height: MediaQuery.of(ctx).padding.bottom + 8),
          ],
        );
      },
    );
  }

  Widget _buildOrientationBanner() {
    return GestureDetector(
      onTap: () => _navigateTo(OrientationScreen(
        prenom: widget.prenom,
        classe: widget.classe,
      )),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppColors.dark,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.goldMid, AppColors.gold],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Center(child: Text('🧭', style: TextStyle(fontSize: 22))),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mon Orientation',
                    style: GoogleFonts.sora(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Séries · Filières · Universités du Burkina',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.45),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.goldMid.withOpacity(0.15),
                border: Border.all(color: AppColors.goldMid.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Text(
                'Découvrir →',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.goldMid,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    final items = [
      {'icon': Icons.home_outlined, 'label': 'Accueil'},
      {'icon': Icons.menu_book_outlined, 'label': 'Cours'},
      {'icon': Icons.auto_awesome_outlined, 'label': 'Le Sage'},
      {'icon': Icons.sports_esports_outlined, 'label': 'Jeu'},
      {'icon': Icons.person_outline, 'label': 'Profil'},
    ];

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      padding: EdgeInsets.only(
        top: 10,
        bottom: MediaQuery.of(context).padding.bottom + 10,
        left: 6,
        right: 6,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final isActive = _currentTab == index;
          final isSage = index == 2;
          return GestureDetector(
            onTap: () {
              setState(() => _currentTab = index);
              switch (index) {
                case 1:
                  _navigateTo(CatalogueScreen(classe: widget.classe));
                  break;
                case 2:
                  _navigateTo(SageScreen(
                    prenom: widget.prenom,
                    classe: widget.classe,
                  ));
                  break;
                case 3:
                  _navigateTo(JeuScreen(classe: widget.classe), slideUp: true);
                  break;
                case 4:
                  _navigateTo(ProfilScreen(
                    prenom: widget.prenom,
                    avatar: widget.avatar,
                    classe: widget.classe,
                  ));
                  break;
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                isSage
                    ? Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.goldMid, AppColors.gold],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: const Center(
                          child: Text('🧙', style: TextStyle(fontSize: 16)),
                        ),
                      )
                    : Icon(items[index]['icon'] as IconData,
                        size: 22,
                        color: isActive ? AppColors.green : AppColors.text3),
                const SizedBox(height: 3),
                Text(
                  items[index]['label'] as String,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: isSage
                        ? AppColors.goldMid
                        : isActive
                            ? AppColors.green
                            : AppColors.text3,
                  ),
                ),
                if (isActive && !isSage)
                  Container(
                    margin: const EdgeInsets.only(top: 3),
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: AppColors.green),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
