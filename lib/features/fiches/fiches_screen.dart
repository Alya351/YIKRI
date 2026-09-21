import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';

class FichesScreen extends StatefulWidget {
  final String classe;
  const FichesScreen({super.key, this.classe = 'Terminale D'});

  @override
  State<FichesScreen> createState() => _FichesScreenState();
}

class _FichesScreenState extends State<FichesScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  String _selectedMatiere = 'Toutes';
  String? _ficheOuverte;

  List<String> get _matieresFiltres {
    final s = widget.classe;
    if (s.contains('A')) return ['Toutes', 'Francais', 'Maths'];
    if (s.contains('C')) return ['Toutes', 'Maths', 'Physique', 'Francais'];
    return ['Toutes', 'Maths', 'SVT', 'Physique', 'Francais'];
  }

  final List<_Fiche> _fiches = [
    _Fiche(
      id: 'maths1',
      titre: 'Equations du 2nd degre',
      matiere: 'Maths',
      emoji: '📐',
      duree: '3 min',
      contenu: [
        _FicheSection('Forme generale', 'ax² + bx + c = 0\noù a ≠ 0'),
        _FicheSection('Discriminant', 'Δ = b² - 4ac\n\n• Δ > 0 → 2 solutions\n• Δ = 0 → 1 solution double\n• Δ < 0 → pas de solution reelle'),
        _FicheSection('Solutions', 'x₁ = (-b + √Δ) / 2a\nx₂ = (-b - √Δ) / 2a'),
        _FicheSection('Exemple', 'x² - 5x + 6 = 0\na=1, b=-5, c=6\nΔ = 25 - 24 = 1\nx₁ = 3, x₂ = 2'),
      ],
    ),
    _Fiche(
      id: 'maths2',
      titre: 'Fonctions derivees',
      matiere: 'Maths',
      emoji: '📈',
      duree: '4 min',
      contenu: [
        _FicheSection('Derivees usuelles', 'f(x) = xⁿ → f\'(x) = nxⁿ⁻¹\nf(x) = √x → f\'(x) = 1/2√x\nf(x) = 1/x → f\'(x) = -1/x²\nf(x) = eˣ → f\'(x) = eˣ'),
        _FicheSection('Regles de calcul', '(u+v)\' = u\' + v\'\n(uv)\' = u\'v + uv\'\n(u/v)\' = (u\'v - uv\') / v²'),
        _FicheSection('Variations', 'f\'(x) > 0 → f croissante\nf\'(x) < 0 → f decroissante\nf\'(x) = 0 → extremum local'),
      ],
    ),
    _Fiche(
      id: 'svt1',
      titre: 'La cellule',
      matiere: 'SVT',
      emoji: '🔬',
      duree: '3 min',
      contenu: [
        _FicheSection('Definition', 'Unite structurale et fonctionnelle du vivant. Tout etre vivant est compose d au moins une cellule.'),
        _FicheSection('Structure cellulaire', '• Membrane plasmique\n• Cytoplasme\n• Noyau (eucaryotes)\n• Mitochondries\n• Ribosomes'),
        _FicheSection('Types de cellules', 'Procaryotes : pas de noyau (bacteries)\nEucaryotes : noyau present (animaux, plantes)'),
        _FicheSection('Fonctions', '• Nutrition\n• Respiration\n• Reproduction\n• Relation avec l environnement'),
      ],
    ),
    _Fiche(
      id: 'svt2',
      titre: 'Photosynthese',
      matiere: 'SVT',
      emoji: '🌿',
      duree: '3 min',
      contenu: [
        _FicheSection('Definition', 'Processus par lequel les plantes fabriquent leur nourriture en utilisant la lumiere solaire.'),
        _FicheSection('Equation bilan', '6CO₂ + 6H₂O + lumiere → C₆H₁₂O₆ + 6O₂'),
        _FicheSection('Lieu', 'Se deroule dans les chloroplastes grace a la chlorophylle.'),
        _FicheSection('2 phases', 'Phase lumineuse : capture de l energie solaire\nCycle de Calvin : fabrication du glucose'),
      ],
    ),
    _Fiche(
      id: 'phy1',
      titre: 'Lois de Newton',
      matiere: 'Physique',
      emoji: '⚡',
      duree: '3 min',
      contenu: [
        _FicheSection('1ere loi - Inertie', 'Un corps reste au repos ou en MRU si la somme des forces est nulle.\nΣF = 0'),
        _FicheSection('2eme loi - Fondamentale', 'La somme des forces = masse x acceleration\nΣF = m × a\n\nUnites : F en Newton (N), m en kg, a en m/s²'),
        _FicheSection('3eme loi - Action-Reaction', 'Si A exerce F sur B, alors B exerce -F sur A.\nForces egales, opposees, meme droite.'),
        _FicheSection('Application', 'Un objet de 2 kg soumis a F = 10 N :\na = F/m = 10/2 = 5 m/s²'),
      ],
    ),
    _Fiche(
      id: 'phy2',
      titre: 'Electricite - Loi d Ohm',
      matiere: 'Physique',
      emoji: '🔌',
      duree: '2 min',
      contenu: [
        _FicheSection('Loi d Ohm', 'U = R × I\n\nU : tension (Volts)\nR : resistance (Ohms)\nI : intensite (Amperes)'),
        _FicheSection('En serie', 'R_total = R₁ + R₂ + R₃\nI identique dans chaque composant'),
        _FicheSection('En parallele', '1/R_total = 1/R₁ + 1/R₂\nU identique aux bornes de chaque composant'),
      ],
    ),
    _Fiche(
      id: 'fr1',
      titre: 'Methode de la dissertation',
      matiere: 'Francais',
      emoji: '✍️',
      duree: '4 min',
      contenu: [
        _FicheSection('Structure generale', '1. Introduction\n2. Developpement (3 parties)\n3. Conclusion'),
        _FicheSection('Introduction', '• Accroche (citation, question)\n• Presentation du sujet\n• Problematique\n• Annonce du plan'),
        _FicheSection('Developpement', 'Partie 1 : These\nPartie 2 : Antithese\nPartie 3 : Synthese\n\nChaque partie : argument + exemple + transition'),
        _FicheSection('Conclusion', '• Bilan des idees\n• Reponse a la problematique\n• Ouverture sur un sujet plus large'),
      ],
    ),
    _Fiche(
      id: 'fr2',
      titre: 'Les figures de style',
      matiere: 'Francais',
      emoji: '📚',
      duree: '3 min',
      contenu: [
        _FicheSection('Comparaison', 'Compare deux elements avec un outil de comparaison.\nEx : "Il est fort comme un lion"'),
        _FicheSection('Metaphore', 'Comparaison sans outil.\nEx : "C est un lion" (pour un homme fort)'),
        _FicheSection('Hyperbole', 'Exageration pour renforcer.\nEx : "Je t ai dit mille fois"'),
        _FicheSection('Personnification', 'Attribuer des caracteristiques humaines a un objet.\nEx : "Le vent chantait"'),
        _FicheSection('Antithese', 'Opposition de deux idees.\nEx : "L homme nait libre et partout il est dans les fers"'),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<_Fiche> get _fichesFiltrees {
    final s = widget.classe;
    List<_Fiche> base;
    if (s.contains('A')) {
      base = _fiches.where((f) => ['Francais', 'Maths'].contains(f.matiere)).toList();
    } else if (s.contains('C')) {
      base = _fiches.where((f) => ['Maths', 'Physique', 'Francais'].contains(f.matiere)).toList();
    } else {
      base = _fiches; // Terminale D voit tout
    }
    if (_selectedMatiere == 'Toutes') return base;
    return base.where((f) => f.matiere == _selectedMatiere).toList();
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
            _buildMatiereFilter(),
            Expanded(child: _buildFichesList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: AppColors.dark2,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 14,
        left: 16, right: 16, bottom: 16,
      ),
      child: Row(children: [
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
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Fiches de revision',
              style: GoogleFonts.sora(
                  fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
          Text('${_fiches.length} fiches disponibles',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 11, color: Colors.white.withOpacity(0.4))),
        ]),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.goldMid.withOpacity(0.15),
            border: Border.all(color: AppColors.goldMid.withOpacity(0.25)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text('📖 Revise vite',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.goldMid)),
        ),
      ]),
    );
  }

  Widget _buildMatiereFilter() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _matieresFiltres.map((m) {
            final isActive = _selectedMatiere == m;
            return GestureDetector(
              onTap: () => setState(() => _selectedMatiere = m),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.green : AppColors.background,
                  border: Border.all(
                    color: isActive ? AppColors.green : AppColors.border,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(m,
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 12, fontWeight: FontWeight.w600,
                        color: isActive ? Colors.white : AppColors.text2)),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildFichesList() {
    final fiches = _fichesFiltrees;
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
      itemCount: fiches.length,
      itemBuilder: (context, i) => _buildFicheCard(fiches[i]),
    );
  }

  Widget _buildFicheCard(_Fiche fiche) {
    final isOpen = _ficheOuverte == fiche.id;
    final matiereColor = _matiereColor(fiche.matiere);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(
          color: isOpen ? matiereColor.withOpacity(0.4) : AppColors.border,
          width: isOpen ? 2 : 1.5,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          // Header fiche
          GestureDetector(
            onTap: () => setState(() =>
                _ficheOuverte = isOpen ? null : fiche.id),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(children: [
                Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                    color: matiereColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(child: Text(fiche.emoji,
                      style: const TextStyle(fontSize: 20))),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(fiche.titre,
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 14, fontWeight: FontWeight.w700,
                            color: AppColors.text)),
                    const SizedBox(height: 3),
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: matiereColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(fiche.matiere,
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 9, fontWeight: FontWeight.w700,
                                color: matiereColor)),
                      ),
                      const SizedBox(width: 6),
                      Text('⏱ ${fiche.duree}',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 10, color: AppColors.text3)),
                    ]),
                  ],
                )),
                AnimatedRotation(
                  turns: isOpen ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(Icons.keyboard_arrow_down_rounded,
                      color: isOpen ? matiereColor : AppColors.text3, size: 22),
                ),
              ]),
            ),
          ),

          // Contenu expandable
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _buildContenu(fiche, matiereColor),
            crossFadeState: isOpen
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }

  Widget _buildContenu(_Fiche fiche, Color color) {
    return Column(
      children: [
        const Divider(height: 1, color: AppColors.border),
        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: fiche.contenu.map((section) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(
                      width: 4, height: 14,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Text(section.titre,
                        style: GoogleFonts.sora(
                            fontSize: 12, fontWeight: FontWeight.w700,
                            color: color)),
                  ]),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(section.contenu,
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 12, color: AppColors.text, height: 1.6)),
                  ),
                ],
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }

  Color _matiereColor(String matiere) {
    switch (matiere) {
      case 'Maths': return AppColors.goldMid;
      case 'SVT': return AppColors.greenMid;
      case 'Physique': return const Color(0xFF5B8DEF);
      case 'Francais': return AppColors.red;
      default: return AppColors.greenMid;
    }
  }
}

class _Fiche {
  final String id;
  final String titre;
  final String matiere;
  final String emoji;
  final String duree;
  final List<_FicheSection> contenu;
  const _Fiche({
    required this.id, required this.titre, required this.matiere,
    required this.emoji, required this.duree, required this.contenu,
  });
}

class _FicheSection {
  final String titre;
  final String contenu;
  const _FicheSection(this.titre, this.contenu);
}