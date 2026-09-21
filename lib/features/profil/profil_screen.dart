import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../examen/mode_examen_screen.dart';
import '../../core/services/app_service.dart';
import '../../core/services/niveau_helper.dart';
import '../impact/impact_screen.dart';
import '../onboarding/onboarding_screen.dart';
import '../auth/avatar_screen.dart';
import '../auth/login_screen.dart';

class ProfilScreen extends StatefulWidget {
  final String prenom;
  final String nom;
  final String avatar;
  final String classe;

  const ProfilScreen({
    super.key,
    this.prenom = 'Aminata',
    this.nom = 'Ouédraogo',
    this.avatar = '👦',
    this.classe = 'Terminale D',
  });

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  bool _codeGenere = false;
  bool _notificationsEnabled = true;

  List<Map<String, dynamic>> get _badges {
    if (widget.classe == 'Enseignant') return [
      {'emoji': '📚', 'label': '1er cours', 'won': true},
      {'emoji': '👥', 'label': '100 eleves', 'won': true},
      {'emoji': '⭐', 'label': 'Note 4.5+', 'won': true},
      {'emoji': '💰', 'label': '50k FCFA', 'won': true},
      {'emoji': '🏆', 'label': 'Top Prof', 'won': false},
      {'emoji': '🎓', 'label': '500 eleves', 'won': false},
      {'emoji': '💎', 'label': '5 cours', 'won': false},
      {'emoji': '🚀', 'label': 'Certifie+', 'won': false},
    ];
    return [
      {'emoji': '🔥', 'label': '7 jours', 'won': true},
      {'emoji': '⭐', 'label': '20 credits', 'won': true},
      {'emoji': '🎯', 'label': '100% QCM', 'won': true},
      {'emoji': '🏆', 'label': 'Top 10', 'won': false},
      {'emoji': '🧙', 'label': 'Niv. Sage', 'won': false},
      {'emoji': '💎', 'label': '30 cours', 'won': false},
      {'emoji': '📚', 'label': '10 cours', 'won': true},
      {'emoji': '🚀', 'label': 'Serie 30j', 'won': false},
    ];
  }

  List<Map<String, dynamic>> get _progressions {
    final c = widget.classe;
    if (NiveauHelper.isCollege(c)) return [
      {'matiere': 'Mathématiques', 'pct': 0.72, 'couleur': AppColors.greenMid},
      {'matiere': 'Français', 'pct': 0.68, 'couleur': AppColors.goldMid},
      {'matiere': 'SVT', 'pct': 0.60, 'couleur': AppColors.greenMid},
      {'matiere': 'Histoire-Géo', 'pct': 0.75, 'couleur': AppColors.goldMid},
    ];
    if (NiveauHelper.isSeconde(c)) return [
      {'matiere': 'Mathématiques', 'pct': 0.70, 'couleur': AppColors.greenMid},
      {'matiere': 'Physique', 'pct': 0.62, 'couleur': AppColors.goldMid},
      {'matiere': 'SVT', 'pct': 0.68, 'couleur': AppColors.greenMid},
      {'matiere': 'Français', 'pct': 0.74, 'couleur': AppColors.goldMid},
    ];
    final s = NiveauHelper.getSerie(c);
    if (s == 'A') return [
      {'matiere': 'Philosophie', 'pct': 0.78, 'couleur': AppColors.greenMid},
      {'matiere': 'Français', 'pct': 0.82, 'couleur': AppColors.goldMid},
      {'matiere': 'Histoire-Géo', 'pct': 0.65, 'couleur': AppColors.greenMid},
      {'matiere': 'Anglais', 'pct': 0.70, 'couleur': AppColors.goldMid},
    ];
    if (s == 'C') return [
      {'matiere': 'Mathématiques', 'pct': 0.85, 'couleur': AppColors.greenMid},
      {'matiere': 'Physique', 'pct': 0.72, 'couleur': AppColors.goldMid},
      {'matiere': 'Chimie', 'pct': 0.60, 'couleur': AppColors.red},
      {'matiere': 'Français', 'pct': 0.68, 'couleur': AppColors.greenMid},
    ];
    return [
      {'matiere': 'Mathématiques', 'pct': 0.78, 'couleur': AppColors.greenMid},
      {'matiere': 'SVT', 'pct': 0.65, 'couleur': AppColors.goldMid},
      {'matiere': 'Physique-Chimie', 'pct': 0.52, 'couleur': AppColors.red},
      {'matiere': 'Français', 'pct': 0.70, 'couleur': AppColors.greenMid},
    ];
  }

  int _credits = 20;
  bool _notificationsActives = true;
  bool _modeExamen = false;

  @override
  void initState() {
    super.initState();
    // Charger les vrais crédits
    final profile = AppService().profile;
    if (profile != null) _credits = profile.credits;
    AppService().addListener(_onServiceUpdate);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();
  }

  void _onServiceUpdate() {
    if (!mounted) return;
    final profile = AppService().profile;
    if (profile != null) setState(() => _credits = profile.credits);
  }

  @override
  void dispose() {
    AppService().removeListener(_onServiceUpdate);
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBadges(),
                    const SizedBox(height: 14),
                    if (widget.classe != 'Enseignant') _buildProgression(),
                    const SizedBox(height: 14),
                    if (widget.classe != 'Enseignant') _buildHistoriqueProgression(),
                    const SizedBox(height: 14),
                    _buildInfoCompte(),
                    const SizedBox(height: 14),
                    if (widget.classe != 'Enseignant') _buildCodeParent(),
                    if (widget.classe != 'Enseignant') const SizedBox(height: 14),
                    _buildParametres(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A1F12), Color(0xFF1E3828)],
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 16,
        right: 16,
        bottom: 0,
      ),
      child: Column(
        children: [
          // Bouton retour + titre
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
              const SizedBox(width: 10),
              Text(
                'Mon Profil',
                style: GoogleFonts.sora(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              // Bouton paramètres
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(Icons.settings_outlined,
                    color: Colors.white54, size: 16),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Avatar + infos
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.greenMid, AppColors.green],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: Text(widget.avatar,
                      style: const TextStyle(fontSize: 26)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.classe == 'Enseignant' ? 'Prof. Kabore Ibrahim' : '${widget.prenom} ${widget.nom}',
                      style: GoogleFonts.sora(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      widget.classe == 'Enseignant' ? 'Enseignant certifie · yikri depuis Jan 2025' : '${widget.classe} · yikri depuis Jan 2025',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.4),
                      ),
                    ),
                  ],
                ),
              ),
              // Badge niveau
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.goldMid.withOpacity(0.15),
                  border: Border.all(
                      color: AppColors.goldMid.withOpacity(0.25)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text(
                      widget.classe == 'Enseignant' ? 'CERTIFIE' : 'ÉRUDIT',
                      style: GoogleFonts.sora(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.goldMid,
                      ),
                    ),
                    Text(
                      'NIVEAU',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 8,
                        color: Colors.white.withOpacity(0.35),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Stats bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              border:
                  Border.all(color: Colors.white.withOpacity(0.08)),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                _buildStat('$_credits', 'Crédits', isGold: true),
                _buildStatDiv(),
                _buildStat('#12', 'Rang'),
                _buildStatDiv(),
                _buildStat('8', 'Cours'),
                _buildStatDiv(),
                _buildStat('68%', 'Moyenne'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String val, String label, {bool isGold = false}) {
    return Expanded(
      child: Column(
        children: [
          Text(
            val,
            style: GoogleFonts.sora(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: isGold ? AppColors.goldMid : Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              color: Colors.white.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDiv() {
    return Container(
        width: 1,
        height: 30,
        color: Colors.white.withOpacity(0.07));
  }

  Widget _buildBadges() {
    final gained = _badges.where((b) => b['won'] == true).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Mes badges',
              style: GoogleFonts.sora(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
            Text(
              '$gained / ${_badges.length} débloqués',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.greenMid,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.1,
          ),
          itemCount: _badges.length,
          itemBuilder: (context, index) {
            final badge = _badges[index];
            final won = badge['won'] as bool;
            return AnimatedOpacity(
              opacity: won ? 1.0 : 0.4,
              duration: const Duration(milliseconds: 300),
              child: Container(
                decoration: BoxDecoration(
                  color: won ? AppColors.goldLight : AppColors.white,
                  border: Border.all(
                    color: won
                        ? AppColors.goldMid.withOpacity(0.3)
                        : AppColors.border,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(badge['emoji'],
                        style: const TextStyle(fontSize: 22)),
                    const SizedBox(height: 4),
                    Text(
                      badge['label'],
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: won ? AppColors.gold : AppColors.text3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

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
            'PROGRESSION PAR MATIÈRE',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.text3,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          ..._progressions.map((p) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        p['matiere'],
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                      ),
                      Text(
                        '${(p['pct'] * 100).toInt()}%',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: p['couleur'],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: p['pct'],
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          p['couleur']),
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


  Widget _buildHistoriqueProgression() {
    final semaines = [
      {'sem': 'Sem 1', 'score': 0.52},
      {'sem': 'Sem 2', 'score': 0.58},
      {'sem': 'Sem 3', 'score': 0.61},
      {'sem': 'Sem 4', 'score': 0.68},
      {'sem': 'Sem 5', 'score': 0.72},
      {'sem': 'Sem 6', 'score': 0.78},
    ];
    final maxScore = 0.78;

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
          Row(children: [
            Text('EVOLUTION SUR 6 SEMAINES',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 10, fontWeight: FontWeight.w700,
                    color: AppColors.text3, letterSpacing: 0.8)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.greenLight,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text('+26% ce mois',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 9, fontWeight: FontWeight.w700,
                      color: AppColors.green)),
            ),
          ]),
          const SizedBox(height: 16),
          SizedBox(
            height: 80,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: semaines.map((s) {
                final pct = s['score'] as double;
                final isLast = s['sem'] == 'Sem 6';
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (isLast)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.greenMid,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text('${(pct * 100).toInt()}%',
                                style: GoogleFonts.sora(
                                    fontSize: 9, fontWeight: FontWeight.w700,
                                    color: Colors.white)),
                          ),
                        const SizedBox(height: 4),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeOutCubic,
                          height: 60 * (pct / maxScore),
                          decoration: BoxDecoration(
                            color: isLast ? AppColors.greenMid : AppColors.greenMid.withOpacity(0.25 + pct * 0.5),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(s['sem'] as String,
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 8, color: AppColors.text3)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.greenLight,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Row(children: [
              const Text('🧙', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 8),
              Expanded(child: Text(
                'Tu as progresse de 26% en 6 semaines. Continue comme ca !',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 11, color: AppColors.green, fontWeight: FontWeight.w500),
              )),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCompte() {
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
            'MON COMPTE',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.text3,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),
          _buildInfoRow('Classe active', widget.classe),
          GestureDetector(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ModeExamenScreen()),
              );
              setState(() {
                _modeExamen = AppService().modeExamenActif;
              });
            },
            child: _buildInfoRowSwitch('Mode Examen', AppService().modeExamenActif),
          ),
          _buildInfoRow('Cours achetés', '8 cours'),
          _buildInfoRow('Crédits', '$_credits crédits'),
          _buildInfoRowLast('Série actuelle', '7 jours 🔥'),
        ],
      ),
    );
  }

  Widget _buildInfoRowSwitch(String label, bool value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.text2)),
          Row(children: [
            Text(value ? 'Actif' : 'Inactif',
              style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700,
                color: value ? AppColors.goldMid : AppColors.text3)),
            const SizedBox(width: 8),
            Switch(
              value: value,
              onChanged: null,
              activeColor: AppColors.goldMid,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value,
      {Color? valueColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: const BoxDecoration(
        border: Border(
            bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 13, color: AppColors.text)),
          Text(value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: valueColor ?? AppColors.text2,
              )),
        ],
      ),
    );
  }

  Widget _buildInfoRowLast(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 9),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 13, color: AppColors.text)),
          Text(value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.text2,
              )),
        ],
      ),
    );
  }

  Widget _buildCodeParent() {
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
            'CODE DE LIAISON PARENT',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.text3,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Génère un code unique à partager avec ton parent. Il est valable 24h.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: AppColors.text3,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          if (_codeGenere)
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.greenLight,
                border: Border.all(
                    color: AppColors.greenMid.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'YK-4829-BF',
                    style: GoogleFonts.sora(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.green,
                      letterSpacing: 2,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        'Valable 24h',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.greenMid,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Code copié !',
                                style: GoogleFonts.plusJakartaSans(),
                              ),
                              backgroundColor: AppColors.green,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(10)),
                            ),
                          );
                        },
                        child: const Icon(Icons.copy,
                            size: 16, color: AppColors.greenMid),
                      ),
                    ],
                  ),
                ],
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => setState(() => _codeGenere = true),
                icon: const Icon(Icons.generating_tokens_outlined,
                    size: 16),
                label: Text(
                  'Générer un code',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.green,
                  side: const BorderSide(
                      color: AppColors.green, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildParametres() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border, width: 1.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          // 1. Notifications
          _buildParamItem(
            icon: Icons.notifications_outlined,
            label: 'Notifications',
            trailing: Switch(
              value: _notificationsEnabled,
              onChanged: (val) => setState(() => _notificationsEnabled = val),
              activeColor: AppColors.greenMid,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onTap: () => setState(() => _notificationsEnabled = !_notificationsEnabled),
            showChevron: false,
            isLast: false,
          ),

          // 2. Modifier mot de passe
          _buildParamItem(
            icon: Icons.lock_outline,
            label: 'Modifier le mot de passe',
            onTap: _showChangerMotDePasse,
            isLast: false,
          ),

          // 3. Changer avatar
          _buildParamItem(
            icon: Icons.face_outlined,
            label: 'Changer d\'avatar',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AvatarScreen(
                    prenom: widget.prenom,
                    profileIndex: 0,
                  ),
                ),
              );
            },
            isLast: false,
          ),

          // 4. Impact yikri
          _buildParamItem(
            icon: Icons.bar_chart_rounded,
            label: 'Impact yikri',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ImpactScreen())),
            isLast: false,
          ),

          // 5. Aide et support
          _buildParamItem(
            icon: Icons.help_outline,
            label: 'Aide et support',
            onTap: _showAideSupport,
            isLast: false,
          ),

          // 5. Déconnexion
          _buildParamItem(
            icon: Icons.logout,
            label: 'Se déconnecter',
            onTap: _confirmerDeconnexion,
            isRed: true,
            showChevron: false,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildParamItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Widget? trailing,
    bool isRed = false,
    bool showChevron = true,
    required bool isLast,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : const Border(
                  bottom: BorderSide(color: AppColors.border, width: 1)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18,
                color: isRed ? AppColors.red : AppColors.text2),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isRed ? AppColors.red : AppColors.text,
              ),
            ),
            const Spacer(),
            if (trailing != null) trailing
            else if (showChevron)
              const Icon(Icons.chevron_right, size: 18, color: AppColors.text3),
          ],
        ),
      ),
    );
  }

  void _showChangerMotDePasse() {
    final ancienCtrl = TextEditingController();
    final nouveauCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    bool obscure1 = true, obscure2 = true, obscure3 = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 40,
          ),
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36, height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text('Modifier le mot de passe',
                  style: GoogleFonts.sora(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text)),
              const SizedBox(height: 18),
              _buildPasswordField(
                controller: ancienCtrl,
                label: 'Mot de passe actuel',
                obscure: obscure1,
                onToggle: () => setModalState(() => obscure1 = !obscure1),
              ),
              const SizedBox(height: 12),
              _buildPasswordField(
                controller: nouveauCtrl,
                label: 'Nouveau mot de passe',
                obscure: obscure2,
                onToggle: () => setModalState(() => obscure2 = !obscure2),
              ),
              const SizedBox(height: 12),
              _buildPasswordField(
                controller: confirmCtrl,
                label: 'Confirmer le nouveau mot de passe',
                obscure: obscure3,
                onToggle: () => setModalState(() => obscure3 = !obscure3),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (nouveauCtrl.text != confirmCtrl.text) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Les mots de passe ne correspondent pas',
                            style: GoogleFonts.plusJakartaSans()),
                        backgroundColor: AppColors.red,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ));
                      return;
                    }
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Mot de passe modifié avec succès',
                          style: GoogleFonts.plusJakartaSans()),
                      backgroundColor: AppColors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.greenMid,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Enregistrer',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.text),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.plusJakartaSans(
            fontSize: 12, color: AppColors.text3),
        filled: true,
        fillColor: AppColors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: AppColors.border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: AppColors.greenMid, width: 1.5),
        ),
        suffixIcon: GestureDetector(
          onTap: onToggle,
          child: Icon(
            obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            size: 18,
            color: AppColors.text3,
          ),
        ),
      ),
    );
  }

  void _showAideSupport() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Aide et support',
            style: GoogleFonts.sora(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.text)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAideItem(Icons.email_outlined, 'support@yikri.bf'),
            const SizedBox(height: 12),
            _buildAideItem(Icons.phone_outlined, '+226 25 XX XX XX'),
            const SizedBox(height: 12),
            _buildAideItem(Icons.chat_bubble_outline, 'WhatsApp disponible'),
            const SizedBox(height: 14),
            Text(
              'Disponible du lundi au vendredi, 8h–18h (heure de Ouagadougou)',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 11, color: AppColors.text3, height: 1.5),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Fermer',
                style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700, color: AppColors.greenMid)),
          ),
        ],
      ),
    );
  }

  Widget _buildAideItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.greenMid),
        const SizedBox(width: 10),
        Text(text,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 13, color: AppColors.text)),
      ],
    );
  }

  void _confirmerDeconnexion() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Se déconnecter ?',
            style: GoogleFonts.sora(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.text)),
        content: Text(
          'Tu devras te reconnecter pour accéder à ton compte yikri.',
          style: GoogleFonts.plusJakartaSans(
              fontSize: 13, color: AppColors.text3, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Annuler',
                style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600, color: AppColors.text3)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await AppService().clearProfile();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  PageRouteBuilder(
                    pageBuilder: (c, a, b) => const OnboardingScreen(),
                    transitionsBuilder: (c, a, b, child) => FadeTransition(opacity: a, child: child),
                    transitionDuration: const Duration(milliseconds: 500),
                  ),
                  (route) => false,
                );
              }
            },
            child: Text('Déconnecter',
                style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700, color: AppColors.red)),
          ),
        ],
      ),
    );
  }
}