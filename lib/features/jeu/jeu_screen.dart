import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart';
import '../../core/services/app_service.dart';
import '../../core/services/niveau_helper.dart';

class JeuScreen extends StatefulWidget {
  final String classe;
  const JeuScreen({super.key, this.classe = 'Terminale D'});

  @override
  State<JeuScreen> createState() => _JeuScreenState();
}

class _JeuScreenState extends State<JeuScreen>
    with SingleTickerProviderStateMixin {
  int _modeActif = 0;
  int _score = 0;
  int _credits = 0;
  int _totalCredits = 0;
  int _niveau = 1;
  int _tempsRestant = 60;
  bool _questionVisible = false;
  int? _reponseSelectionnee;
  List<List<int>> _grille = [];
  Timer? _timer;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  final List<String> _modes = ['Gemmes', 'Sprint', 'Duel', 'Défi Sage'];

  final List<Color> _couleurs = [
    const Color(0xFFFF6B6B),
    const Color(0xFF4ECDC4),
    const Color(0xFFFFE66D),
    const Color(0xFFA8E6CF),
    const Color(0xFFC3A6FF),
    const Color(0xFFFFB347),
  ];

  final List<String> _emojis = ['🔴', '🔵', '🟡', '🟢', '🟣', '🟠'];

  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'Quelle est la valeur de √36 ?',
      'options': ['4', '6', '8', '9'],
      'bonne': 1,
      'credits': 2,
    },
    {
      'question': 'Combien font 7 × 8 ?',
      'options': ['54', '56', '58', '60'],
      'bonne': 1,
      'credits': 2,
    },
    {
      'question': 'Quel est le carré de 9 ?',
      'options': ['72', '81', '90', '99'],
      'bonne': 1,
      'credits': 2,
    },
    {
      'question': 'Combien de degrés dans un triangle ?',
      'options': ['90°', '180°', '270°', '360°'],
      'bonne': 1,
      'credits': 2,
    },
    {
      'question': 'Quelle est la formule de l\'aire d\'un cercle ?',
      'options': ['2πr', 'πr²', 'πd', '2πr²'],
      'bonne': 1,
      'credits': 2,
    },
  ];

  int _questionActuelle = 0;

  @override
  void initState() {
    super.initState();
    final profile = AppService().profile;
    if (profile != null) _totalCredits = profile.credits;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();
    _genererGrille();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _genererGrille() {
    final rand = Random();
    _grille = List.generate(
      5,
      (_) => List.generate(6, (_) => rand.nextInt(6)),
    );
    setState(() {});
  }

  void _demarrerSprint() {
    _timer?.cancel();
    setState(() => _tempsRestant = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_tempsRestant <= 0) {
        t.cancel();
        _afficherResultat();
      } else {
        setState(() => _tempsRestant--);
      }
    });
  }

  void _afficherResultat() {
    HapticFeedback.heavyImpact();
    Navigator.of(context).push(PageRouteBuilder(
      opaque: false,
      pageBuilder: (ctx, a, b) => _ResultatScreen(
        score: _score,
        credits: _credits,
        niveau: _niveau,
        onRejouer: () async {
          await AppService().updateCredits(_credits);
          final p = AppService().profile;
          if (p != null && mounted) setState(() => _totalCredits = p.credits);
          Navigator.of(ctx).pop();
          setState(() {
            _score = 0;
            _credits = 0;
            _niveau = 1;
            _questionVisible = false;
            _reponseSelectionnee = null;
          });
          _genererGrille();
        },
      ),
      transitionsBuilder: (ctx, a, b, child) => FadeTransition(opacity: a, child: child),
      transitionDuration: const Duration(milliseconds: 400),
    ));
  }

  void _tapperGemme(int row, int col) {
    if (_questionVisible) return;

    setState(() {
      _questionVisible = true;
      _reponseSelectionnee = null;
      _questionActuelle = Random().nextInt(_questions.length);
    });

    final rand = Random();
    for (int i = 0; i < 6; i++) {
      _grille[row][i] = rand.nextInt(6);
    }
  }

  void _repondre(int index) {
    if (_reponseSelectionnee != null) return;
    final q = _questions[_questionActuelle];
    final bonne = q['bonne'] as int;
    final correct = index == bonne;

    setState(() {
      _reponseSelectionnee = index;
      if (correct) {
        _score += 100 * _niveau;
        _credits += q['credits'] as int;
        if (_score >= _niveau * 500) _niveau++;
      }
    });

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() {
          _questionVisible = false;
          _reponseSelectionnee = null;
        });
      }
    });
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
              child: _modeActif == 2
                  ? _buildModeDuel()
                  : _modeActif == 3
                      ? _buildModeDefiSage()
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(13),
                          child: Column(
                            children: [
                              if (_modeActif == 1) _buildTimerBar(),
                              const SizedBox(height: 4),
                              _buildGrille(),
                              const SizedBox(height: 12),
                              if (_questionVisible) _buildQuestion(),
                              if (!_questionVisible) _buildTip(),
                              const SizedBox(height: 12),
                              _buildScoreBar(),
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


  Widget _buildModeDuel() {
    final adversaires = [
      {'nom': 'Kofi B.', 'classe': 'Terminale C', 'score': 1240, 'avatar': '🦊', 'statut': 'En ligne'},
      {'nom': 'Mariam S.', 'classe': 'Terminale D', 'score': 1180, 'avatar': '🦁', 'statut': 'En ligne'},
      {'nom': 'Ibrahim O.', 'classe': 'Terminale C', 'score': 980, 'avatar': '🐯', 'statut': 'Il y a 2h'},
      {'nom': 'Aïcha K.', 'classe': 'Terminale D', 'score': 870, 'avatar': '🦋', 'statut': 'Il y a 5h'},
    ];
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(14),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(color: AppColors.dark, borderRadius: BorderRadius.circular(15)),
          child: Row(children: [
            const Text('⚔️', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Mode Duel', style: GoogleFonts.sora(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
              Text('Défie un élève en temps réel — 5 questions, 60 secondes', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.white54, height: 1.4)),
            ])),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text('ADVERSAIRES DISPONIBLES', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.text3, letterSpacing: 0.8)),
        ),
        const SizedBox(height: 8),
        ...adversaires.map((a) => Container(
          margin: const EdgeInsets.fromLTRB(14, 0, 14, 8),
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(color: AppColors.white, border: Border.all(color: AppColors.border, width: 1.5), borderRadius: BorderRadius.circular(13)),
          child: Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
              child: Center(child: Text(a['avatar'] as String, style: const TextStyle(fontSize: 20))),
            ),
            const SizedBox(width: 11),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(a['nom'] as String, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.text)),
              Text('${a['classe']} · ${a['score']} pts', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.text3)),
            ])),
            Column(children: [
              Text(a['statut'] as String, style: GoogleFonts.plusJakartaSans(fontSize: 10, color: a['statut'] == 'En ligne' ? AppColors.greenMid : AppColors.text3)),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Défi envoyé à ${a['nom']} !'), backgroundColor: AppColors.greenMid, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: AppColors.greenMid, borderRadius: BorderRadius.circular(8)),
                  child: Text('Défier', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ),
            ]),
          ]),
        )),
      ],
    );
  }

  Widget _buildModeDefiSage() {
    final defis = [
      {'matiere': 'Maths', 'question': 'Résous : x² - 5x + 6 = 0', 'difficulte': 'Facile', 'credits': 3, 'emoji': '📐'},
      {'matiere': 'SVT', 'question': "Nomme les 4 bases azotées de l'ADN", 'difficulte': 'Moyen', 'credits': 5, 'emoji': '🧬'},
      {'matiere': 'Physique', 'question': 'Énonce la 2ème loi de Newton', 'difficulte': 'Moyen', 'credits': 5, 'emoji': '⚡'},
      {'matiere': 'Francais', 'question': "Qu'est-ce qu'une proposition subordonnée relative ?", 'difficulte': 'Difficile', 'credits': 8, 'emoji': '✍️'},
      {'matiere': 'Maths', 'question': "Calcule l'intégrale de 2x entre 0 et 3", 'difficulte': 'Difficile', 'credits': 8, 'emoji': 'int'},
    ];
    final couleursDiff = {'Facile': AppColors.greenMid, 'Moyen': AppColors.goldMid, 'Difficile': AppColors.red};

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(14),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(color: AppColors.dark, borderRadius: BorderRadius.circular(15)),
          child: Row(children: [
            const Text('🧙', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Défis du Sage', style: GoogleFonts.sora(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
              Text('Réponds aux questions du Sage pour gagner des crédits', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.white54, height: 1.4)),
            ])),
          ]),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            children: defis.map((d) {
              final diff = d['difficulte'] as String;
              final color = couleursDiff[diff]!;
              return GestureDetector(
                onTap: () => _showDefiSageDialog(d),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: AppColors.white, border: Border.all(color: AppColors.border, width: 1.5), borderRadius: BorderRadius.circular(13)),
                  child: Row(children: [
                    Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
                      child: Center(child: Text(d['emoji'] as String, style: const TextStyle(fontSize: 20))),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(d['matiere'] as String, style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.green, letterSpacing: 0.5)),
                      const SizedBox(height: 3),
                      Text(d['question'] as String, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.text, height: 1.4)),
                    ])),
                    const SizedBox(width: 10),
                    Column(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(5)),
                        child: Text(diff, style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w700, color: color)),
                      ),
                      const SizedBox(height: 5),
                      Text('+${d['credits']} cr.', style: GoogleFonts.sora(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.goldMid)),
                    ]),
                  ]),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  void _showDefiSageDialog(Map<String, dynamic> defi) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.dark2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [
          Text(defi['emoji'] as String, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 8),
          Text(defi['matiere'] as String, style: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
        ]),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(defi['question'] as String, style: GoogleFonts.plusJakartaSans(fontSize: 14, color: Colors.white.withOpacity(0.85), height: 1.5)),
          const SizedBox(height: 14),
          TextField(
            controller: controller,
            style: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Ta réponse...',
              hintStyle: GoogleFonts.plusJakartaSans(color: Colors.white38),
              filled: true,
              fillColor: Colors.white.withOpacity(0.07),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Annuler', style: GoogleFonts.plusJakartaSans(color: Colors.white38))),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final credits = defi['credits'] as int;
              await AppService().updateCredits(credits);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Bonne réponse ! +$credits crédits 🎉'),
                  backgroundColor: AppColors.greenMid,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.greenMid),
            child: Text('Valider', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: Colors.white)),
          ),
        ],
      ),
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
        left: 15,
        right: 15,
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
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white54,
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Match de Gemmes',
                style: GoogleFonts.sora(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.goldMid.withOpacity(0.15),
                  border: Border.all(
                    color: AppColors.goldMid.withOpacity(0.25),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$_totalCredits crédits',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.goldMid,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            padding: const EdgeInsets.all(3),
            child: Row(
              children: List.generate(_modes.length, (index) {
                final isActive = _modeActif == index;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _modeActif = index;
                        _score = 0;
                        _credits = 0;
                        _niveau = 1;
                        _questionVisible = false;
                      });
                      _timer?.cancel();
                      if (index == 1) _demarrerSprint();
                      _genererGrille();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Text(
                        _modes[index],
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isActive
                              ? AppColors.text
                              : Colors.white.withOpacity(0.35),
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

  Widget _buildTimerBar() {
    final pct = _tempsRestant / 60;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sprint · $_tempsRestant sec',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _tempsRestant < 15 ? AppColors.red : AppColors.text2,
                ),
              ),
              Text(
                '$_score pts',
                style: GoogleFonts.sora(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(
                _tempsRestant < 15 ? AppColors.red : AppColors.greenMid,
              ),
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrille() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border, width: 1.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: List.generate(_grille.length, (row) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: List.generate(_grille[row].length, (col) {
                final colorIndex = _grille[row][col];
                return Expanded(
                  child: GestureDetector(
                    onTap: () => _tapperGemme(row, col),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      height: 44,
                      decoration: BoxDecoration(
                        color: _couleurs[colorIndex],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _couleurs[colorIndex].withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _emojis[colorIndex],
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildQuestion() {
    final q = _questions[_questionActuelle];
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border, width: 1.5),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.greenMid.withOpacity(0.12),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Text(
              'QUESTION DÉBLOQUÉE · +${q['credits']} CRÉDITS',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: AppColors.greenMid,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            q['question'],
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(
              (q['options'] as List).length,
              (index) {
                final isSelected = _reponseSelectionnee == index;
                final isBonne = index == q['bonne'];
                Color bg = AppColors.background;
                Color border = AppColors.border;
                Color text = AppColors.text;

                if (_reponseSelectionnee != null) {
                  if (isSelected && isBonne) {
                    bg = AppColors.greenLight;
                    border = AppColors.greenMid;
                    text = AppColors.green;
                  } else if (isSelected && !isBonne) {
                    bg = AppColors.redLight;
                    border = AppColors.red;
                    text = AppColors.red;
                  }
                } else if (isSelected) {
                  bg = AppColors.greenLight;
                  border = AppColors.greenMid;
                }

                return Expanded(
                  child: GestureDetector(
                    onTap: () => _repondre(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: EdgeInsets.only(right: index < 3 ? 7 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: bg,
                        border: Border.all(color: border, width: 1.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        (q['options'] as List)[index],
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: text,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTip() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.greenLight,
        border: Border.all(color: AppColors.greenMid.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Text('💡', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Tap sur les gemmes pour créer des alignements et débloquer des questions !',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: AppColors.green,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreBar() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.dark,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _buildScoreItem('Niv $_niveau', 'Niveau'),
          _buildScoreDiv(),
          _buildScoreItem('+$_credits', 'Crédits', isGold: true),
          _buildScoreDiv(),
          _buildScoreItem('$_score', 'Score'),
        ],
      ),
    );
  }

  Widget _buildScoreItem(String val, String label, {bool isGold = false}) {
    return Expanded(
      child: Column(
        children: [
          Text(
            val,
            style: GoogleFonts.sora(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isGold ? AppColors.goldMid : Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              color: Colors.white.withOpacity(0.35),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreDiv() {
    return Container(
      width: 1,
      height: 36,
      color: Colors.white.withOpacity(0.08),
    );
  }
}

class _ResultatScreen extends StatefulWidget {
  final int score;
  final int credits;
  final int niveau;
  final VoidCallback onRejouer;

  const _ResultatScreen({
    required this.score,
    required this.credits,
    required this.niveau,
    required this.onRejouer,
  });

  @override
  State<_ResultatScreen> createState() => _ResultatScreenState();
}

class _ResultatScreenState extends State<_ResultatScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _confettiController;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  final List<_Confetti> _confettis = [];
  final Random _rand = Random();

  @override
  void initState() {
    super.initState();
    _mainController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 800),
    );
    _confettiController = AnimationController(
      vsync: this, duration: const Duration(seconds: 3),
    );
    _scaleAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.elasticOut),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.easeIn),
    );
    for (int i = 0; i < 40; i++) {
      _confettis.add(_Confetti(
        x: _rand.nextDouble(),
        y: -_rand.nextDouble() * 0.5,
        color: [
          AppColors.goldMid, AppColors.greenMid,
          AppColors.red, Colors.white, Colors.orange,
        ][_rand.nextInt(5)],
        size: 6 + _rand.nextDouble() * 8,
        speed: 0.3 + _rand.nextDouble() * 0.7,
      ));
    }
    _mainController.forward();
    _confettiController.forward();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  String _getMessage() {
    if (widget.score >= 100) return 'Exceptionnel !';
    if (widget.score >= 60) return 'Excellent !';
    if (widget.score >= 30) return 'Bien joue !';
    return 'Continue !';
  }

  String _getEmoji() {
    if (widget.score >= 100) return '🏆';
    if (widget.score >= 60) return '⭐';
    if (widget.score >= 30) return '🎯';
    return '💪';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.85),
      body: Stack(
        children: [
          // Confettis
          AnimatedBuilder(
            animation: _confettiController,
            builder: (context, child) {
              return CustomPaint(
                size: MediaQuery.of(context).size,
                painter: _ConfettiPainter(
                  confettis: _confettis,
                  progress: _confettiController.value,
                ),
              );
            },
          ),
          // Contenu principal
          Center(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: ScaleTransition(
                scale: _scaleAnim,
                child: Container(
                  margin: const EdgeInsets.all(24),
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF0F2A1A), Color(0xFF1E3828)],
                    ),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: AppColors.goldMid.withOpacity(0.3), width: 1.5),
                    boxShadow: [BoxShadow(
                      color: AppColors.goldMid.withOpacity(0.2),
                      blurRadius: 40, spreadRadius: 5,
                    )],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_getEmoji(), style: const TextStyle(fontSize: 64)),
                      const SizedBox(height: 12),
                      Text(
                        _getMessage(),
                        style: GoogleFonts.sora(
                          fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Score
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.goldMid.withOpacity(0.1),
                          border: Border.all(color: AppColors.goldMid.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(children: [
                          Text(
                            '${widget.score} pts',
                            style: GoogleFonts.sora(
                              fontSize: 40, fontWeight: FontWeight.w800, color: AppColors.goldMid,
                            ),
                          ),
                          Text('Score final', style: GoogleFonts.plusJakartaSans(
                            fontSize: 12, color: Colors.white.withOpacity(0.5),
                          )),
                        ]),
                      ),
                      const SizedBox(height: 16),
                      Row(children: [
                        Expanded(child: _buildStat('Niveau', '${widget.niveau}', Icons.trending_up_rounded, AppColors.greenMid)),
                        const SizedBox(width: 10),
                        Expanded(child: _buildStat('Credits', '+${widget.credits}', Icons.monetization_on_outlined, AppColors.goldMid)),
                      ]),
                      const SizedBox(height: 20),
                      // Message Sage
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(children: [
                          const Text('🧙', style: TextStyle(fontSize: 18)),
                          const SizedBox(width: 8),
                          Expanded(child: Text(
                            widget.score >= 60
                                ? 'Bravo ! Tu progresses vraiment bien. Continue comme ca !'
                                : 'Bonne partie ! Chaque essai te rapproche du succes. Rejoue !',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12, color: Colors.white.withOpacity(0.7), height: 1.4,
                            ),
                          )),
                        ]),
                      ),
                      const SizedBox(height: 20),
                      Row(children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.white.withOpacity(0.2)),
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text('Quitter', style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w600, color: Colors.white54,
                            )),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: widget.onRejouer,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.greenMid,
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text('Rejouer !', style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w700, color: Colors.white, fontSize: 15,
                            )),
                          ),
                        ),
                      ]),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        border: Border.all(color: color.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.sora(
          fontSize: 18, fontWeight: FontWeight.w700, color: color,
        )),
        Text(label, style: GoogleFonts.plusJakartaSans(
          fontSize: 10, color: Colors.white.withOpacity(0.4),
        )),
      ]),
    );
  }
}

class _Confetti {
  final double x;
  double y;
  final Color color;
  final double size;
  final double speed;
  _Confetti({required this.x, required this.y, required this.color,
      required this.size, required this.speed});
}

class _ConfettiPainter extends CustomPainter {
  final List<_Confetti> confettis;
  final double progress;

  _ConfettiPainter({required this.confettis, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final c in confettis) {
      final paint = Paint()..color = c.color.withOpacity(1 - progress * 0.5);
      final x = c.x * size.width;
      final y = (c.y + progress * c.speed * 2) * size.height;
      if (y > size.height) continue;
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(progress * c.speed * 6.28);
      canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: c.size, height: c.size * 0.5), paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => true;
}