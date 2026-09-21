import 'dart:async';
import '../../core/services/app_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';

// ─── Modèles ──────────────────────────────────────────────────────────────────

class Chapitre {
  final String titre;
  final String duree;
  final String type; // 'texte' | 'exemple' | 'exercice' | 'resume'
  final String contenu;
  final bool debloque;
  bool lu;

  Chapitre({
    required this.titre,
    required this.duree,
    required this.type,
    required this.contenu,
    this.debloque = true,
    this.lu = false,
  });
}

class QuizQuestion {
  final String question;
  final List<String> options;
  final int bonne;
  int? reponseSelectionnee;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.bonne,
    this.reponseSelectionnee,
  });
}

// ─── Écran principal ──────────────────────────────────────────────────────────

class CoursScreen extends StatefulWidget {
  final String matiere;
  final String niveau;
  final String titre;
  final String enseignant;
  final String format; // 'PDF + Audio' | 'PDF' | 'Vidéo'
  final double progression;

  const CoursScreen({
    super.key,
    this.matiere = 'MATHS',
    this.niveau = 'TERM D',
    this.titre = 'Équations du second degré — Méthodes complètes',
    this.enseignant = 'Prof. Kaboré Ibrahim',
    this.format = 'PDF + Audio',
    this.progression = 0.0,
  });

  @override
  State<CoursScreen> createState() => _CoursScreenState();
}

class _CoursScreenState extends State<CoursScreen>
    with SingleTickerProviderStateMixin {
  int _chapitreActif = 0;
  bool _audioEnLecture = false;
  int _audioPosition = 0; // en secondes
  int _audioDuree = 480; // 8 minutes
  Timer? _audioTimer;
  bool _notesOuvertes = false;
  final TextEditingController _notesController = TextEditingController();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;
  bool _quizOuvert = false;
  int _quizScore = 0;
  bool _quizTermine = false;

  final List<Chapitre> _chapitres = [
    Chapitre(
      titre: 'Introduction',
      duree: '3 min',
      type: 'texte',
      contenu: '''Une équation du second degré est une équation de la forme :

ax² + bx + c = 0

où a, b et c sont des réels avec a ≠ 0.

Exemples du quotidien : la trajectoire d'un ballon de football, le calcul d'une surface de terrain, ou encore la résistance d'un matériau — toutes ces situations font appel aux équations du second degré.

Dans ce cours, tu vas maîtriser trois méthodes pour résoudre ces équations, et comprendre pourquoi elles fonctionnent.''',
      lu: true,
    ),
    Chapitre(
      titre: 'Le discriminant',
      duree: '8 min',
      type: 'texte',
      contenu:
          '''Le discriminant est la clé qui te permet de savoir combien de solutions une équation possède avant même de les calculer.

On le note Δ (delta) et on le calcule ainsi :

Δ = b² - 4ac

Trois cas possibles :

• Si Δ > 0 : l'équation a deux solutions distinctes
• Si Δ = 0 : l'équation a une solution double (racine double)
• Si Δ < 0 : l'équation n'a pas de solution réelle

Pourquoi ça marche ? Le discriminant est lié à la géométrie : il représente la façon dont la parabole y = ax² + bx + c coupe l'axe des abscisses.''',
    ),
    Chapitre(
      titre: 'Méthode 1 — Formule',
      duree: '10 min',
      type: 'exemple',
      contenu: '''Quand Δ > 0, les deux solutions sont :

x₁ = (-b + √Δ) / 2a
x₂ = (-b - √Δ) / 2a

Appliquons cela sur un exemple concret :

Résoudre x² - 5x + 6 = 0

Ici : a = 1, b = -5, c = 6

Étape 1 — Calculer Δ :
Δ = (-5)² - 4 × 1 × 6 = 25 - 24 = 1

Étape 2 — Calculer les solutions :
x₁ = (5 + √1) / 2 = (5 + 1) / 2 = 3
x₂ = (5 - 1) / 2 = 4 / 2 = 2

Vérification : (x-2)(x-3) = x² - 5x + 6 ✓

Les solutions sont x = 2 et x = 3.''',
    ),
    Chapitre(
      titre: 'Méthode 2 — Factorisation',
      duree: '8 min',
      type: 'exemple',
      contenu:
          '''La factorisation est souvent plus rapide quand les racines sont entières.

Principe : on cherche deux nombres p et q tels que :
• p + q = -b/a  (somme des racines)
• p × q = c/a   (produit des racines)

Ce sont les relations de Viète.

Exemple : x² - 7x + 12 = 0
On cherche p et q tels que p + q = 7 et p × q = 12

Essais : 3 + 4 = 7 ✓ et 3 × 4 = 12 ✓

Donc x² - 7x + 12 = (x - 3)(x - 4)

Solutions : x = 3 et x = 4

Astuce du Sage : Cette méthode marche en 2 secondes quand les racines sont des entiers. Entraîne-toi à reconnaître les paires (1,12), (2,6), (3,4) pour les petits produits.''',
    ),
    Chapitre(
      titre: 'Méthode 3 — Complétion du carré',
      duree: '7 min',
      type: 'texte',
      contenu:
          '''Cette méthode est la plus générale et permet de comprendre l'origine de la formule du discriminant.

On transforme ax² + bx + c en faisant apparaître un carré parfait :

ax² + bx + c = a(x + b/2a)² - Δ/4a

Exemple : x² + 4x + 1 = 0
(x + 2)² - 4 + 1 = 0
(x + 2)² = 3
x + 2 = ±√3
x = -2 ± √3

Cette méthode est utile pour :
• Trouver le sommet d'une parabole
• Résoudre sans calculer Δ explicitement
• Comprendre les transformations graphiques''',
      debloque: false,
    ),
    Chapitre(
      titre: 'Quiz de vérification',
      duree: '5 min',
      type: 'exercice',
      contenu: 'quiz',
      debloque: false,
    ),
    Chapitre(
      titre: 'Résumé & Fiches',
      duree: '2 min',
      type: 'resume',
      contenu: '''Points clés à retenir :

1. Toujours commencer par calculer Δ = b² - 4ac

2. Si Δ > 0 → deux solutions : x = (-b ± √Δ) / 2a
   Si Δ = 0 → une solution : x = -b / 2a
   Si Δ < 0 → pas de solution réelle

3. Factorisation rapide : cherche p, q avec p+q = -b/a et p×q = c/a

4. Vérifie toujours ta réponse en remplaçant dans l'équation

Formules à mémoriser :
• Δ = b² - 4ac
• x = (-b ± √Δ) / 2a
• Somme des racines : x₁ + x₂ = -b/a
• Produit des racines : x₁ × x₂ = c/a''',
      debloque: false,
    ),
  ];

  final List<QuizQuestion> _quiz = [
    QuizQuestion(
      question: 'Quel est le discriminant de x² - 3x + 2 = 0 ?',
      options: ['1', '5', '17', '-1'],
      bonne: 0,
    ),
    QuizQuestion(
      question: 'Combien de solutions réelles pour Δ = -4 ?',
      options: ['0', '1', '2', '3'],
      bonne: 0,
    ),
    QuizQuestion(
      question: 'Les solutions de x² - 5x + 6 = 0 sont :',
      options: ['x=1 et x=6', 'x=2 et x=3', 'x=-2 et x=-3', 'x=3 et x=6'],
      bonne: 1,
    ),
    QuizQuestion(
      question: 'Le produit des racines de 2x² + 3x - 5 = 0 vaut :',
      options: ['-5/2', '3/2', '5/2', '-3/2'],
      bonne: 0,
    ),
  ];

  // Calcul de la progression
  double get _progressionActuelle {
    final lus = _chapitres.where((c) => c.lu).length;
    return lus / _chapitres.length;
  }

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _fadeController.forward();

    // Marquer le premier chapitre comme lu après 3 secondes
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _chapitres[0].lu = true);
        _sauvegarderProgression();
      }
    });
  }

  void _sauvegarderProgression() {
    final coursId = widget.titre.replaceAll(' ', '_').toLowerCase();
    AppService().updateProgression(coursId, _progressionActuelle);
    if (_progressionActuelle >= 1.0) {
      AppService().updateCredits(10); // bonus cours terminé
    }
  }

  @override
  void dispose() {
    _sauvegarderProgression();
    _audioTimer?.cancel();
    _notesController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  // ─── Audio simulé ────────────────────────────────────────────────────────────

  void _toggleAudio() {
    if (_audioEnLecture) {
      _audioTimer?.cancel();
      setState(() => _audioEnLecture = false);
    } else {
      setState(() => _audioEnLecture = true);
      _audioTimer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (_audioPosition >= _audioDuree) {
          t.cancel();
          setState(() {
            _audioEnLecture = false;
            _audioPosition = 0;
          });
        } else {
          setState(() => _audioPosition++);
        }
      });
    }
  }

  String _formatDuree(int secondes) {
    final m = secondes ~/ 60;
    final s = secondes % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  // ─── Navigation chapitre ─────────────────────────────────────────────────────

  void _allerChapitre(int index) {
    if (!_chapitres[index].debloque) {
      _showDeblocageModal();
      return;
    }
    _fadeController.reset();
    setState(() {
      _chapitreActif = index;
      _quizOuvert = false;
      _quizTermine = false;
      _audioPosition = 0;
      _audioEnLecture = false;
      _audioTimer?.cancel();
    });
    _fadeController.forward();

    // Marquer comme lu après 5 secondes
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && _chapitreActif == index) {
        setState(() => _chapitres[index].lu = true);
      }
    });
  }

  void _showDeblocageModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        padding: EdgeInsets.only(
          top: 20,
          left: 20,
          right: 20,
          bottom: MediaQuery.of(ctx).padding.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text('🔒', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 12),
            Text(
              'Chapitre verrouillé',
              style: GoogleFonts.sora(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Lis les chapitres précédents pour débloquer la suite.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppColors.text3,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Continuer ma lecture'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Quiz ────────────────────────────────────────────────────────────────────

  void _repondreQuiz(int questionIndex, int reponseIndex) {
    if (_quiz[questionIndex].reponseSelectionnee != null) return;
    setState(() {
      _quiz[questionIndex].reponseSelectionnee = reponseIndex;
      if (reponseIndex == _quiz[questionIndex].bonne) {
        _quizScore++;
      }
      // Vérifier si quiz terminé
      if (_quiz.every((q) => q.reponseSelectionnee != null)) {
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) setState(() => _quizTermine = true);
        });
      }
    });
  }

  // ─── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(),
          _buildProgressBar(),
          Expanded(
            child: Row(
              children: [
                // Sidebar chapitres (desktop-like mais scrollable)
                _buildSidebarChapitres(),
                // Contenu principal
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: _buildContenu(),
                  ),
                ),
              ],
            ),
          ),
          // Lecteur audio si format PDF+Audio
          if (widget.format.contains('Audio')) _buildAudioPlayer(),
        ],
      ),
    );
  }

  // ─── Header ──────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      color: AppColors.dark2,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 14,
        right: 14,
        bottom: 14,
      ),
      child: Row(
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
              child:
                  const Icon(Icons.arrow_back, color: Colors.white54, size: 16),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.titre,
                  style: GoogleFonts.sora(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${widget.matiere} · ${widget.enseignant}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    color: Colors.white.withOpacity(0.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Bouton Notes
          GestureDetector(
            onTap: () => _ouvrirNotes(),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: _notesOuvertes
                    ? AppColors.goldMid.withOpacity(0.2)
                    : Colors.white.withOpacity(0.07),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.edit_note_outlined,
                color: _notesOuvertes ? AppColors.goldMid : Colors.white54,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 6),
          // Progression
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.greenMid.withOpacity(0.15),
              border: Border.all(color: AppColors.greenMid.withOpacity(0.25)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${(_progressionActuelle * 100).toInt()}%',
              style: GoogleFonts.sora(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.greenMid,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Barre de progression ─────────────────────────────────────────────────────

  Widget _buildProgressBar() {
    return Container(
      color: AppColors.dark2,
      padding: const EdgeInsets.only(bottom: 0),
      child: ClipRRect(
        child: LinearProgressIndicator(
          value: _progressionActuelle,
          backgroundColor: Colors.white.withOpacity(0.07),
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.greenMid),
          minHeight: 3,
        ),
      ),
    );
  }

  // ─── Sidebar ──────────────────────────────────────────────────────────────────

  Widget _buildSidebarChapitres() {
    return Container(
      width: 72,
      color: AppColors.white,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              'PLAN',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 8,
                fontWeight: FontWeight.w700,
                color: AppColors.text3,
                letterSpacing: 0.8,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: _chapitres.length,
              itemBuilder: (context, index) {
                final ch = _chapitres[index];
                final isActive = _chapitreActif == index;
                final isLocked = !ch.debloque;

                return GestureDetector(
                  onTap: () => _allerChapitre(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    decoration: BoxDecoration(
                      color:
                          isActive ? AppColors.greenLight : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color:
                            isActive ? AppColors.greenMid : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        // Icône type
                        Text(
                          isLocked
                              ? '🔒'
                              : ch.lu
                                  ? '✓'
                                  : _typeIcon(ch.type),
                          style: TextStyle(
                            fontSize: 14,
                            color: ch.lu
                                ? AppColors.greenMid
                                : isLocked
                                    ? AppColors.text3
                                    : AppColors.text2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${index + 1}',
                          style: GoogleFonts.sora(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: isActive ? AppColors.green : AppColors.text3,
                          ),
                        ),
                      ],
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

  String _typeIcon(String type) {
    switch (type) {
      case 'texte':
        return '📖';
      case 'exemple':
        return '✏️';
      case 'exercice':
        return '🎯';
      case 'resume':
        return '📋';
      default:
        return '📄';
    }
  }

  // ─── Contenu ──────────────────────────────────────────────────────────────────

  Widget _buildContenu() {
    final ch = _chapitres[_chapitreActif];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête du chapitre
          _buildChapitreHeader(ch),
          const SizedBox(height: 14),

          // Contenu selon le type
          if (ch.contenu == 'quiz') _buildQuiz() else _buildTexteContenu(ch),

          const SizedBox(height: 16),

          // Navigation prev/next
          _buildNavigation(),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildChapitreHeader(Chapitre ch) {
    final Map<String, Color> typeColors = {
      'texte': AppColors.greenMid,
      'exemple': AppColors.goldMid,
      'exercice': AppColors.red,
      'resume': AppColors.green,
    };
    final Map<String, String> typeLabels = {
      'texte': 'COURS',
      'exemple': 'EXEMPLE',
      'exercice': 'EXERCICE',
      'resume': 'RÉSUMÉ',
    };

    final color = typeColors[ch.type] ?? AppColors.text3;
    final label = typeLabels[ch.type] ?? ch.type.toUpperCase();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: color,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${_chapitreActif + 1} / ${_chapitres.length}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                color: AppColors.text3,
              ),
            ),
            const Spacer(),
            Row(
              children: [
                const Icon(Icons.access_time_outlined,
                    size: 12, color: AppColors.text3),
                const SizedBox(width: 3),
                Text(
                  ch.duree,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: AppColors.text3,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          ch.titre,
          style: GoogleFonts.sora(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
            height: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildTexteContenu(Chapitre ch) {
    // Diviser le contenu en paragraphes
    final paragraphes = ch.contenu.split('\n\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: paragraphes.map((para) {
        // Formules (lignes contenant =, ±, √, etc.)
        final isFormule = para.contains('=') &&
            (para.contains('x') || para.contains('Δ') || para.contains('√'));
        final isTitre = para.length < 60 &&
            !para.contains(' ') == false &&
            (para.startsWith('•') ||
                RegExp(r'^[A-ZÉÈÊÀa-z]').hasMatch(para.trim()));

        if (para.trim().startsWith('•')) {
          // Liste à puces
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 5,
                  height: 5,
                  margin: const EdgeInsets.only(top: 7, right: 8, left: 4),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.greenMid,
                  ),
                ),
                Expanded(
                  child: Text(
                    para.trim().substring(1).trim(),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: AppColors.text,
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // Détection "Astuce du Sage"
        if (para.contains('Astuce du Sage')) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: AppColors.goldLight,
                border: Border.all(color: AppColors.goldMid.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🧙', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      para.replaceFirst('Astuce du Sage : ', '').trim(),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: AppColors.gold,
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Formule mathématique
        if (isFormule && para.trim().length < 80) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.dark,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                para.trim(),
                style: GoogleFonts.sourceCodePro(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.greenMid,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        // Paragraphe normal
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            para.trim(),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: AppColors.text,
              height: 1.7,
            ),
          ),
        );
      }).toList(),
    );
  }

  // ─── Quiz ────────────────────────────────────────────────────────────────────

  Widget _buildQuiz() {
    if (_quizTermine) {
      return _buildQuizResultat();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: AppColors.dark,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Text('🎯', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Teste tes connaissances — ${_quiz.length} questions, pas de chrono.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        ...List.generate(_quiz.length, (qi) {
          return _buildQuizQuestion(qi);
        }),
      ],
    );
  }

  Widget _buildQuizQuestion(int qi) {
    final q = _quiz[qi];
    final answered = q.reponseSelectionnee != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border, width: 1.5),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Q${qi + 1}',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: AppColors.text3,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            q.question,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          ...List.generate(q.options.length, (oi) {
            final isSelected = q.reponseSelectionnee == oi;
            final isBonne = oi == q.bonne;

            Color bg = AppColors.background;
            Color border = AppColors.border;
            Color text = AppColors.text;

            if (answered) {
              if (isSelected && isBonne) {
                bg = AppColors.greenLight;
                border = AppColors.greenMid;
                text = AppColors.green;
              } else if (isSelected && !isBonne) {
                bg = AppColors.redLight;
                border = AppColors.red;
                text = AppColors.red;
              } else if (!isSelected && isBonne) {
                bg = AppColors.greenLight;
                border = AppColors.greenMid.withOpacity(0.4);
                text = AppColors.green;
              }
            } else if (isSelected) {
              bg = AppColors.greenLight;
              border = AppColors.greenMid;
            }

            return GestureDetector(
              onTap: () => _repondreQuiz(qi, oi),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 7),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                  color: bg,
                  border: Border.all(color: border, width: 1.5),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Row(
                  children: [
                    Text(
                      ['A', 'B', 'C', 'D'][oi],
                      style: GoogleFonts.sora(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: text,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        q.options[oi],
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: text,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                    if (answered && isBonne)
                      const Icon(Icons.check_circle,
                          size: 16, color: AppColors.greenMid),
                    if (answered && isSelected && !isBonne)
                      const Icon(Icons.cancel, size: 16, color: AppColors.red),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildQuizResultat() {
    final pct = _quizScore / _quiz.length;
    final reussi = pct >= 0.75;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: reussi ? AppColors.greenLight : AppColors.goldLight,
        border: Border.all(
          color: reussi
              ? AppColors.greenMid.withOpacity(0.3)
              : AppColors.goldMid.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            reussi ? '🏆' : '💪',
            style: const TextStyle(fontSize: 48),
          ),
          const SizedBox(height: 12),
          Text(
            reussi ? 'Excellent travail !' : 'Continue à pratiquer !',
            style: GoogleFonts.sora(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: reussi ? AppColors.green : AppColors.gold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$_quizScore / ${_quiz.length} bonnes réponses',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: reussi ? AppColors.greenMid : AppColors.goldMid,
            ),
          ),
          const SizedBox(height: 16),
          if (reussi)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.green,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, color: AppColors.goldMid, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    '+5 crédits débloqués !',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              setState(() {
                for (final q in _quiz) {
                  q.reponseSelectionnee = null;
                }
                _quizScore = 0;
                _quizTermine = false;
              });
            },
            child: Text(
              'Recommencer le quiz',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: AppColors.text3,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Navigation prev/next ─────────────────────────────────────────────────────

  Widget _buildNavigation() {
    final hasPrev = _chapitreActif > 0;
    final hasNext = _chapitreActif < _chapitres.length - 1;

    return Row(
      children: [
        if (hasPrev)
          Expanded(
            child: GestureDetector(
              onTap: () => _allerChapitre(_chapitreActif - 1),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  border: Border.all(color: AppColors.border, width: 1.5),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.arrow_back_ios,
                        size: 12, color: AppColors.text3),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _chapitres[_chapitreActif - 1].titre,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: AppColors.text2,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (hasPrev && hasNext) const SizedBox(width: 8),
        if (hasNext)
          Expanded(
            child: GestureDetector(
              onTap: () => _allerChapitre(_chapitreActif + 1),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                decoration: BoxDecoration(
                  color: _chapitres[_chapitreActif + 1].debloque
                      ? AppColors.green
                      : AppColors.white,
                  border: Border.all(
                    color: _chapitres[_chapitreActif + 1].debloque
                        ? AppColors.green
                        : AppColors.border,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        _chapitres[_chapitreActif + 1].titre,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: _chapitres[_chapitreActif + 1].debloque
                              ? Colors.white
                              : AppColors.text3,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      _chapitres[_chapitreActif + 1].debloque
                          ? Icons.arrow_forward_ios
                          : Icons.lock_outline,
                      size: 12,
                      color: _chapitres[_chapitreActif + 1].debloque
                          ? Colors.white
                          : AppColors.text3,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ─── Lecteur audio ────────────────────────────────────────────────────────────

  Widget _buildAudioPlayer() {
    final pct = _audioDuree > 0 ? _audioPosition / _audioDuree : 0.0;

    return Container(
      color: AppColors.dark2,
      padding: EdgeInsets.only(
        top: 12,
        left: 14,
        right: 14,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Barre de progression audio
          Row(
            children: [
              Text(
                _formatDuree(_audioPosition),
                style: GoogleFonts.sora(
                  fontSize: 10,
                  color: Colors.white.withOpacity(0.4),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    final box = context.findRenderObject() as RenderBox;
                    final dx = details.localPosition.dx / box.size.width;
                    setState(() {
                      _audioPosition =
                          (dx * _audioDuree).clamp(0, _audioDuree).toInt();
                    });
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: pct.clamp(0.0, 1.0),
                      backgroundColor: Colors.white.withOpacity(0.1),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.greenMid),
                      minHeight: 4,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _formatDuree(_audioDuree),
                style: GoogleFonts.sora(
                  fontSize: 10,
                  color: Colors.white.withOpacity(0.4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Contrôles
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Reculer 15s
              GestureDetector(
                onTap: () => setState(() => _audioPosition =
                    (_audioPosition - 15).clamp(0, _audioDuree)),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.replay_10,
                      color: Colors.white54, size: 16),
                ),
              ),
              const SizedBox(width: 12),
              // Lecture/Pause
              GestureDetector(
                onTap: _toggleAudio,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: AppColors.greenMid,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _audioEnLecture ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Avancer 15s
              GestureDetector(
                onTap: () => setState(() => _audioPosition =
                    (_audioPosition + 15).clamp(0, _audioDuree)),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.forward_10,
                      color: Colors.white54, size: 16),
                ),
              ),
              const Spacer(),
              // Vitesse
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '1×',
                  style: GoogleFonts.sora(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white54,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Audio : ${_chapitres[_chapitreActif].titre}',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              color: Colors.white.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Notes ────────────────────────────────────────────────────────────────────

  void _ouvrirNotes() {
    setState(() => _notesOuvertes = !_notesOuvertes);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          ),
          padding: EdgeInsets.only(
            top: 20,
            left: 18,
            right: 18,
            bottom: MediaQuery.of(ctx).padding.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('📝', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text(
                    'Mes notes',
                    style: GoogleFonts.sora(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _chapitres[_chapitreActif].titre,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: AppColors.text3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  border: Border.all(color: AppColors.border, width: 1.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _notesController,
                  maxLines: 6,
                  autofocus: true,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: AppColors.text,
                    height: 1.6,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Écris tes notes ici...',
                    hintStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: AppColors.text3,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(13),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    setState(() => _notesOuvertes = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Notes sauvegardées ✓',
                          style: GoogleFonts.plusJakartaSans(),
                        ),
                        backgroundColor: AppColors.green,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  },
                  child: const Text('Sauvegarder'),
                ),
              ),
            ],
          ),
        ),
      ),
    ).then((_) => setState(() => _notesOuvertes = false));
  }
}
