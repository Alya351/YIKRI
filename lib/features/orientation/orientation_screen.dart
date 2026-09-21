import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

// ─── Modèles ──────────────────────────────────────────────────────────────────

class Serie {
  final String code;
  final String nom;
  final String description;
  final List<String> matieresPrincipales;
  final Map<String, double> coefficients; // matiere -> coeff
  final String debouche;
  final String emoji;

  const Serie({
    required this.code,
    required this.nom,
    required this.description,
    required this.matieresPrincipales,
    required this.coefficients,
    required this.debouche,
    required this.emoji,
  });
}

class Filiere {
  final String nom;
  final String universite;
  final String ville;
  final List<String> seriesCompatibles;
  final double moyenneMin;
  final String duree;
  final String debouche;
  final String emoji;
  final String type; // 'public' | 'prive' | 'grandes_ecoles'

  const Filiere({
    required this.nom,
    required this.universite,
    required this.ville,
    required this.seriesCompatibles,
    required this.moyenneMin,
    required this.duree,
    required this.debouche,
    required this.emoji,
    required this.type,
  });
}

// ─── Données Burkina Faso ─────────────────────────────────────────────────────

const List<Serie> _series = [
  Serie(
    code: 'D',
    nom: 'Terminale D',
    description: 'Sciences de la vie et de la Terre + Mathématiques',
    matieresPrincipales: ['Maths', 'SVT', 'Physique-Chimie', 'Français'],
    coefficients: {
      'Maths': 5,
      'SVT': 5,
      'Physique-Chimie': 4,
      'Français': 3,
      'Anglais': 2,
      'Histoire-Géo': 2,
      'Philosophie': 2,
      'EPS': 1,
    },
    debouche: 'Médecine, Pharmacie, Sciences, Agronomie, Environnement',
    emoji: '🧬',
  ),
  Serie(
    code: 'C',
    nom: 'Terminale C',
    description: 'Mathématiques + Sciences Physiques',
    matieresPrincipales: ['Maths', 'Physique-Chimie', 'SVT', 'Français'],
    coefficients: {
      'Maths': 7,
      'Physique-Chimie': 6,
      'SVT': 3,
      'Français': 3,
      'Anglais': 2,
      'Histoire-Géo': 1,
      'Philosophie': 2,
      'EPS': 1,
    },
    debouche: 'Ingénierie, Informatique, Génie civil, Physique, Chimie',
    emoji: '⚗️',
  ),
  Serie(
    code: 'A',
    nom: 'Terminale A',
    description: 'Lettres, Philosophie et Sciences Humaines',
    matieresPrincipales: ['Français', 'Philosophie', 'Histoire-Géo', 'Langues'],
    coefficients: {
      'Français': 6,
      'Philosophie': 5,
      'Histoire-Géo': 4,
      'Anglais': 4,
      'Maths': 2,
      'SVT': 1,
      'Physique-Chimie': 1,
      'EPS': 1,
    },
    debouche: 'Droit, Journalisme, Lettres, Sciences Humaines, Diplomatie',
    emoji: '📚',
  ),
];

const List<Filiere> _filieres = [
  // ── UJKZ ──
  Filiere(
    nom: 'Médecine Générale',
    universite: 'Université Joseph Ki-Zerbo (UJKZ)',
    ville: 'Ouagadougou',
    seriesCompatibles: ['D'],
    moyenneMin: 14.0,
    duree: '7 ans',
    debouche: 'Médecin généraliste, spécialiste, chercheur',
    emoji: '🏥',
    type: 'public',
  ),
  Filiere(
    nom: 'Pharmacie',
    universite: 'Université Joseph Ki-Zerbo (UJKZ)',
    ville: 'Ouagadougou',
    seriesCompatibles: ['D'],
    moyenneMin: 13.5,
    duree: '6 ans',
    debouche: 'Pharmacien, chercheur, industrie pharmaceutique',
    emoji: '💊',
    type: 'public',
  ),
  Filiere(
    nom: 'Génie Électrique',
    universite: 'UFR Sciences et Technologies (UJKZ)',
    ville: 'Ouagadougou',
    seriesCompatibles: ['C'],
    moyenneMin: 12.0,
    duree: '3 ans (Licence)',
    debouche: 'Électricien industriel, technicien, ingénieur',
    emoji: '⚡',
    type: 'public',
  ),
  Filiere(
    nom: 'Mathématiques et Informatique',
    universite: 'UFR Sciences et Technologies (UJKZ)',
    ville: 'Ouagadougou',
    seriesCompatibles: ['C', 'D'],
    moyenneMin: 12.0,
    duree: '3 ans (Licence)',
    debouche: 'Développeur, analyste, enseignant, chercheur',
    emoji: '🔢',
    type: 'public',
  ),
  Filiere(
    nom: 'Sciences de la Vie et de la Terre',
    universite: 'UFR Sciences de la Vie et de la Terre (UJKZ)',
    ville: 'Ouagadougou',
    seriesCompatibles: ['D'],
    moyenneMin: 11.0,
    duree: '3 ans (Licence)',
    debouche: 'Biologiste, environnement, enseignant, recherche',
    emoji: '🌿',
    type: 'public',
  ),
  Filiere(
    nom: 'Droit Privé',
    universite: 'UFR Sciences Juridiques et Politiques (UJKZ)',
    ville: 'Ouagadougou',
    seriesCompatibles: ['A'],
    moyenneMin: 11.0,
    duree: '3 ans (Licence)',
    debouche: 'Avocat, notaire, magistrat, conseiller juridique',
    emoji: '⚖️',
    type: 'public',
  ),
  Filiere(
    nom: 'Administration et Gestion',
    universite: 'UFR Sciences Économiques et Gestion (UJKZ)',
    ville: 'Ouagadougou',
    seriesCompatibles: ['A'],
    moyenneMin: 11.0,
    duree: '3 ans (Licence)',
    debouche: 'Gestionnaire, administrateur, RH, finance',
    emoji: '🏢',
    type: 'public',
  ),
  Filiere(
    nom: 'Sciences Économiques',
    universite: 'UFR Sciences Économiques et Gestion (UJKZ)',
    ville: 'Ouagadougou',
    seriesCompatibles: ['C'],
    moyenneMin: 11.0,
    duree: '3 ans (Licence)',
    debouche: 'Économiste, analyste, banque, administration',
    emoji: '📈',
    type: 'public',
  ),

  // ── 2iE ──
  Filiere(
    nom: 'Génie Informatique',
    universite: 'Institut International d\'Ingénierie (2iE)',
    ville: 'Ouagadougou',
    seriesCompatibles: ['C', 'D'],
    moyenneMin: 13.0,
    duree: '5 ans',
    debouche: 'Ingénieur logiciel, développeur, chef de projet IT',
    emoji: '💻',
    type: 'grandes_ecoles',
  ),
  Filiere(
    nom: 'Génie Civil et Hydraulique',
    universite: 'Institut International d\'Ingénierie (2iE)',
    ville: 'Ouagadougou',
    seriesCompatibles: ['C', 'D'],
    moyenneMin: 12.5,
    duree: '5 ans',
    debouche: 'Ingénieur BTP, hydraulicien, urbaniste',
    emoji: '🏗️',
    type: 'grandes_ecoles',
  ),
  Filiere(
    nom: 'Énergie Renouvelable',
    universite: 'Institut International d\'Ingénierie (2iE)',
    ville: 'Ouagadougou',
    seriesCompatibles: ['C', 'D'],
    moyenneMin: 12.0,
    duree: '5 ans',
    debouche: 'Ingénieur énergie, solaire, développement durable',
    emoji: '☀️',
    type: 'grandes_ecoles',
  ),

  // ── ISGE-BF ──
  Filiere(
    nom: 'Réseaux Informatiques et Télécommunications',
    universite: 'Institut Supérieur de Génie Électrique du Burkina (ISGE-BF)',
    ville: 'Ouagadougou',
    seriesCompatibles: ['C', 'D'],
    moyenneMin: 13.0,
    duree: '5 ans',
    debouche: 'Ingénieur réseaux, télécoms, cybersécurité, FAI',
    emoji: '📡',
    type: 'grandes_ecoles',
  ),
  Filiere(
    nom: 'Maintenance Industrielle',
    universite: 'Institut Supérieur de Génie Électrique du Burkina (ISGE-BF)',
    ville: 'Ouagadougou',
    seriesCompatibles: ['C', 'D'],
    moyenneMin: 12.5,
    duree: '5 ans',
    debouche: 'Technicien maintenance, industrie, mines, énergie',
    emoji: '🔧',
    type: 'grandes_ecoles',
  ),
  Filiere(
    nom: 'Électricité Industrielle',
    universite: 'Institut Supérieur de Génie Électrique du Burkina (ISGE-BF)',
    ville: 'Ouagadougou',
    seriesCompatibles: ['C', 'D'],
    moyenneMin: 12.0,
    duree: '5 ans',
    debouche: 'Électricien industriel, automaticien, énergéticien',
    emoji: '🔌',
    type: 'grandes_ecoles',
  ),

  // ── IMG ──
  Filiere(
    nom: 'Génie Minier',
    universite: 'Institut des Mines et Géologie (IMG)',
    ville: 'Ouagadougou',
    seriesCompatibles: ['C', 'D'],
    moyenneMin: 12.0,
    duree: '5 ans',
    debouche: 'Ingénieur minier, géologue, exploitation minière',
    emoji: '⛏️',
    type: 'grandes_ecoles',
  ),

  // ── UNB Bobo ──
  Filiere(
    nom: 'Médecine',
    universite: 'Université Nazi Boni (UNB)',
    ville: 'Bobo-Dioulasso',
    seriesCompatibles: ['D'],
    moyenneMin: 13.5,
    duree: '7 ans',
    debouche: 'Médecin, spécialiste, santé publique',
    emoji: '🏥',
    type: 'public',
  ),
  Filiere(
    nom: 'Agronomie',
    universite: 'Université Nazi Boni (UNB)',
    ville: 'Bobo-Dioulasso',
    seriesCompatibles: ['D', 'C'],
    moyenneMin: 11.5,
    duree: '5 ans',
    debouche: 'Agronome, développement rural, ONG, recherche',
    emoji: '🌾',
    type: 'public',
  ),
];

// ─── Écran principal ──────────────────────────────────────────────────────────

class OrientationScreen extends StatefulWidget {
  final String classe;
  final String prenom;

  const OrientationScreen({
    super.key,
    this.classe = 'Terminale D',
    this.prenom = 'Aminata',
  });

  @override
  State<OrientationScreen> createState() => _OrientationScreenState();
}

class _OrientationScreenState extends State<OrientationScreen>
    with SingleTickerProviderStateMixin {
  int _etape = 0; // 0=notes, 1=resultats, 2=filieres
  late AnimationController _controller;
  late Animation<double> _fadeAnim;

  // Notes saisies par l'élève
  final Map<String, TextEditingController> _noteControllers = {};
  final Map<String, double> _notes = {};

  // Résultats calculés
  Serie? _serieSuggeree;
  List<Serie> _seriesCompatibles = [];
  List<Filiere> _filieresCompatibles = [];

  // Filtre filières
  String _filtreType = 'tous';
  String _filtreVille = 'toutes';
  Serie? _serieSelectee;

  final List<Map<String, dynamic>> _matieres = [
    {'nom': 'Maths', 'emoji': '📐'},
    {'nom': 'Français', 'emoji': '✍️'},
    {'nom': 'SVT', 'emoji': '🌿'},
    {'nom': 'Physique-Chimie', 'emoji': '⚗️'},
    {'nom': 'Histoire-Géo', 'emoji': '🗺️'},
    {'nom': 'Anglais', 'emoji': '🌍'},
    {'nom': 'Philosophie', 'emoji': '💭'},
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();

    for (final m in _matieres) {
      _noteControllers[m['nom']] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final c in _noteControllers.values) {
      c.dispose();
    }
    _controller.dispose();
    super.dispose();
  }

  // ─── Calcul orientation ───────────────────────────────────────────────────────

  void _calculerOrientation() {
    // Lire les notes
    _notes.clear();
    for (final m in _matieres) {
      final val = double.tryParse(
              _noteControllers[m['nom']]!.text.replaceAll(',', '.')) ??
          0.0;
      _notes[m['nom']] = val.clamp(0, 20);
    }

    // Calculer le score pour chaque série
    Map<String, double> scores = {};
    for (final serie in _series) {
      double total = 0;
      double totalCoeff = 0;
      serie.coefficients.forEach((matiere, coeff) {
        final note = _notes[matiere] ?? 0;
        total += note * coeff;
        totalCoeff += coeff;
      });
      scores[serie.code] = totalCoeff > 0 ? total / totalCoeff : 0;
    }

    // Trier les séries par score
    final sorted = _series.toList()
      ..sort((a, b) => (scores[b.code] ?? 0).compareTo(scores[a.code] ?? 0));

    // Séries avec score >= 10
    _seriesCompatibles =
        sorted.where((s) => (scores[s.code] ?? 0) >= 10).toList();

    // Série principale suggérée — protection crash si liste vide
    if (sorted.isEmpty) return;
    _serieSuggeree = sorted.first;
    _serieSelectee = _serieSuggeree;

    // Filières compatibles
    _calculerFilieres(_serieSuggeree!);

    _changerEtape(1);
  }

  void _calculerFilieres(Serie serie) {
    final moyenne = _moyenneGenerale();
    _filieresCompatibles = _filieres
        .where((f) =>
            f.seriesCompatibles.contains(serie.code) &&
            moyenne >= f.moyenneMin - 2)
        .toList();
    _filieresCompatibles
        .sort((a, b) => b.moyenneMin.compareTo(a.moyenneMin));
  }

  double _moyenneGenerale() {
    if (_notes.isEmpty) return 0;
    double total = 0;
    int count = 0;
    _notes.forEach((_, note) {
      if (note > 0) {
        total += note;
        count++;
      }
    });
    return count > 0 ? total / count : 0;
  }

  void _changerEtape(int etape) {
    _controller.reset();
    setState(() => _etape = etape);
    _controller.forward();
  }

  // ─── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Column(
          children: [
            _buildHeader(),
            _buildProgressSteps(),
            Expanded(
              child: _etape == 0
                  ? _buildEtapeNotes()
                  : _etape == 1
                      ? _buildEtapeResultats()
                      : _buildEtapeFilieres(),
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
        bottom: 18,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (_etape > 0) {
                _changerEtape(_etape - 1);
              } else {
                Navigator.pop(context);
              }
            },
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
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mon Orientation',
                style: TextStyle(fontFamily: 'Sora', 
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                'Burkina Faso · ${widget.prenom}',
                style: TextStyle(fontFamily: 'PlusJakartaSans', 
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.4),
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.goldMid.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text('🧭', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }

  // ─── Étapes ───────────────────────────────────────────────────────────────────

  Widget _buildProgressSteps() {
    final steps = ['Notes', 'Séries', 'Filières'];
    return Container(
      color: AppColors.dark2,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: List.generate(steps.length, (i) {
          final isDone = i < _etape;
          final isActive = i == _etape;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: isDone
                                  ? AppColors.greenMid
                                  : isActive
                                      ? AppColors.goldMid
                                      : Colors.white.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: isDone
                                  ? const Icon(Icons.check,
                                      size: 12, color: Colors.white)
                                  : Text(
                                      '${i + 1}',
                                      style: TextStyle(fontFamily: 'Sora', 
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: isActive
                                            ? Colors.white
                                            : Colors.white38,
                                      ),
                                    ),
                            ),
                          ),
                          if (i < steps.length - 1)
                            Expanded(
                              child: Container(
                                height: 2,
                                color: isDone
                                    ? AppColors.greenMid
                                    : Colors.white.withOpacity(0.1),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          steps[i],
                          style: TextStyle(fontFamily: 'PlusJakartaSans', 
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isActive
                                ? AppColors.goldMid
                                : isDone
                                    ? AppColors.greenMid
                                    : Colors.white38,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ─── Étape 1 : Saisie des notes ──────────────────────────────────────────────

  Widget _buildEtapeNotes() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSageHint(
                  'Entre tes notes moyennes de l\'année (ou du dernier trimestre). Je vais analyser ton profil et te suggérer la meilleure orientation.',
                ),
                const SizedBox(height: 18),
                Text(
                  'MES NOTES MOYENNES',
                  style: TextStyle(fontFamily: 'PlusJakartaSans', 
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text3,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 10),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 2.4,
                  ),
                  itemCount: _matieres.length,
                  itemBuilder: (context, i) {
                    final m = _matieres[i];
                    return _buildNoteField(m['nom'], m['emoji']);
                  },
                ),
                const SizedBox(height: 16),
                _buildConseils(),
              ],
            ),
          ),
        ),
        _buildBoutonSuivant(
          'Analyser mon profil →',
          _calculerOrientation,
        ),
      ],
    );
  }

  Widget _buildNoteField(String matiere, String emoji) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  matiere,
                  style: TextStyle(fontFamily: 'PlusJakartaSans', 
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
                TextField(
                  controller: _noteControllers[matiere],
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(fontFamily: 'Sora', 
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.green,
                  ),
                  decoration: InputDecoration(
                    hintText: '/20',
                    hintStyle: TextStyle(fontFamily: 'PlusJakartaSans', 
                      fontSize: 12,
                      color: AppColors.text3,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConseils() {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.goldLight,
        border: Border.all(color: AppColors.gold.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '💡 Conseils',
            style: TextStyle(fontFamily: 'PlusJakartaSans', 
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(height: 6),
          ...[
            'Entre 0 si tu n\'as pas la matière',
            'Utilise tes moyennes du dernier bulletin',
            'Pas besoin de remplir toutes les cases',
          ].map((c) => Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 4,
                      margin: const EdgeInsets.only(right: 8, top: 1),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.gold,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        c,
                        style: TextStyle(fontFamily: 'PlusJakartaSans', 
                          fontSize: 11,
                          color: AppColors.gold,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  // ─── Étape 2 : Résultats séries ───────────────────────────────────────────────

  Widget _buildEtapeResultats() {
    final moyenne = _moyenneGenerale();

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Résumé
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.dark,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.goldMid, AppColors.gold],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            _serieSuggeree?.emoji ?? '🎯',
                            style: const TextStyle(fontSize: 26),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Profil analysé',
                              style: TextStyle(fontFamily: 'PlusJakartaSans', 
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.goldMid,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _serieSuggeree?.nom ?? 'Non déterminé',
                              style: TextStyle(fontFamily: 'Sora', 
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Moyenne générale : ${moyenne.toStringAsFixed(1)}/20',
                              style: TextStyle(fontFamily: 'PlusJakartaSans', 
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Message Le Sage
                _buildSageHint(
                  _getSageMessage(moyenne),
                ),

                const SizedBox(height: 18),

                Text(
                  'SÉRIES RECOMMANDÉES',
                  style: TextStyle(fontFamily: 'PlusJakartaSans', 
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text3,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 10),

                // Séries
                ..._series.map((serie) {
                  final score = _calculerScoreSerie(serie);
                  final isTop = serie.code == _serieSuggeree?.code;
                  final isCompatible = _seriesCompatibles.contains(serie);
                  return _buildSerieCard(serie, score, isTop, isCompatible);
                }),

                const SizedBox(height: 16),

                // Radar des notes
                _buildRadarNotes(),
              ],
            ),
          ),
        ),
        _buildBoutonSuivant(
          'Voir les filières et universités →',
          () => _changerEtape(2),
        ),
      ],
    );
  }

  double _calculerScoreSerie(Serie serie) {
    double total = 0;
    double totalCoeff = 0;
    serie.coefficients.forEach((matiere, coeff) {
      final note = _notes[matiere] ?? 0;
      total += note * coeff;
      totalCoeff += coeff;
    });
    return totalCoeff > 0 ? (total / totalCoeff).clamp(0, 20) : 0;
  }

  String _getSageMessage(double moyenne) {
    if (moyenne >= 15) {
      return 'Excellent profil, ${widget.prenom} ! Avec cette moyenne, tu as accès aux filières les plus sélectives du Burkina. Vise les grandes écoles comme le 2iE ou la médecine.';
    } else if (moyenne >= 13) {
      return 'Très bon profil ! Tu as de bonnes chances dans la plupart des filières. Je te recommande de viser les filières scientifiques ou médicales selon ta série.';
    } else if (moyenne >= 11) {
      return 'Bon profil, ${widget.prenom}. Tu as accès à de nombreuses filières. Concentre-toi sur tes points forts pour maximiser tes chances d\'admission.';
    } else {
      return 'Ne te décourage pas, ${widget.prenom}. Plusieurs filières sont accessibles avec ce profil. L\'important est de choisir selon ta passion et de travailler régulièrement.';
    }
  }

  Widget _buildSerieCard(
      Serie serie, double score, bool isTop, bool isCompatible) {
    final pct = score / 20;
    Color barColor;
    if (score >= 14)
      barColor = AppColors.greenMid;
    else if (score >= 11)
      barColor = AppColors.goldMid;
    else
      barColor = AppColors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(
          color: isTop ? AppColors.greenMid : AppColors.border,
          width: isTop ? 2 : 1.5,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isTop ? AppColors.greenLight : AppColors.background,
                  borderRadius: BorderRadius.circular(11),
                ),
                child:
                    Center(child: Text(serie.emoji, style: const TextStyle(fontSize: 18))),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          serie.nom,
                          style: TextStyle(fontFamily: 'Sora', 
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.text,
                          ),
                        ),
                        if (isTop) ...[
                          const SizedBox(width: 7),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.greenLight,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              'RECOMMANDÉE',
                              style: TextStyle(fontFamily: 'PlusJakartaSans', 
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                                color: AppColors.green,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      serie.description,
                      style: TextStyle(fontFamily: 'PlusJakartaSans', 
                        fontSize: 11,
                        color: AppColors.text3,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${score.toStringAsFixed(1)}/20',
                style: TextStyle(fontFamily: 'Sora', 
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: barColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
              minHeight: 5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.work_outline, size: 12, color: AppColors.text3),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  serie.debouche,
                  style: TextStyle(fontFamily: 'PlusJakartaSans', 
                    fontSize: 11,
                    color: AppColors.text3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 5,
            children: serie.matieresPrincipales.map((m) {
              final note = _notes[m] ?? 0;
              Color bg =
                  note >= 14 ? AppColors.greenLight : AppColors.background;
              Color tc = note >= 14 ? AppColors.green : AppColors.text3;
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: bg,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  '$m${note > 0 ? " ${note.toStringAsFixed(0)}" : ""}',
                  style: TextStyle(fontFamily: 'PlusJakartaSans', 
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: tc,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRadarNotes() {
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
            'MES NOTES',
            style: TextStyle(fontFamily: 'PlusJakartaSans', 
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.text3,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          ..._matieres.map((m) {
            final note = _notes[m['nom']] ?? 0;
            if (note == 0) return const SizedBox.shrink();
            Color barColor;
            if (note >= 14)
              barColor = AppColors.greenMid;
            else if (note >= 10)
              barColor = AppColors.goldMid;
            else
              barColor = AppColors.red;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Text(m['emoji'], style: const TextStyle(fontSize: 13)),
                  const SizedBox(width: 7),
                  SizedBox(
                    width: 90,
                    child: Text(
                      m['nom'],
                      style: TextStyle(fontFamily: 'PlusJakartaSans', 
                        fontSize: 11,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: note / 20,
                        backgroundColor: AppColors.border,
                        valueColor: AlwaysStoppedAnimation<Color>(barColor),
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 36,
                    child: Text(
                      '${note.toStringAsFixed(0)}/20',
                      style: TextStyle(fontFamily: 'Sora', 
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: barColor,
                      ),
                      textAlign: TextAlign.right,
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

  // ─── Étape 3 : Filières et universités ───────────────────────────────────────

  Widget _buildEtapeFilieres() {
    final filieresAffichees = _filieresCompatibles.where((f) {
      final typeOk = _filtreType == 'tous' || f.type == _filtreType;
      final villeOk = _filtreVille == 'toutes' || f.ville.contains(_filtreVille);
      final serieOk = _serieSelectee == null ||
          f.seriesCompatibles.contains(_serieSelectee!.code);
      return typeOk && villeOk && serieOk;
    }).toList();

    return Column(
      children: [
        _buildFilieresFilters(),
        Expanded(
          child: filieresAffichees.isEmpty
              ? _buildFiliereEmpty()
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
                  itemCount: filieresAffichees.length,
                  itemBuilder: (context, i) =>
                      _buildFiliereCard(filieresAffichees[i]),
                ),
        ),
      ],
    );
  }

  Widget _buildFilieresFilters() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      child: Column(
        children: [
          // Sélecteur de série
          Row(
            children: [
              Text(
                'Série :',
                style: TextStyle(fontFamily: 'PlusJakartaSans', 
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text2,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(
                        'Toutes',
                        _serieSelectee == null,
                        () => setState(() => _serieSelectee = null),
                      ),
                      ..._series.map((s) => _buildFilterChip(
                            s.code,
                            _serieSelectee?.code == s.code,
                            () => setState(() {
                              _serieSelectee = s;
                              _calculerFilieres(s);
                            }),
                          )),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Filtres type + ville
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('Tous', _filtreType == 'tous',
                          () => setState(() => _filtreType = 'tous')),
                      _buildFilterChip('Public', _filtreType == 'public',
                          () => setState(() => _filtreType = 'public')),
                      _buildFilterChip(
                          'Grandes écoles',
                          _filtreType == 'grandes_ecoles',
                          () => setState(
                              () => _filtreType = 'grandes_ecoles')),
                      _buildFilterChip('Privé', _filtreType == 'prive',
                          () => setState(() => _filtreType = 'prive')),
                      const SizedBox(width: 10),
                      _buildFilterChip(
                          'Ouagadougou',
                          _filtreVille == 'Ouagadougou',
                          () => setState(() => _filtreVille =
                              _filtreVille == 'Ouagadougou'
                                  ? 'toutes'
                                  : 'Ouagadougou')),
                      _buildFilterChip(
                          'Bobo',
                          _filtreVille == 'Bobo',
                          () => setState(() => _filtreVille =
                              _filtreVille == 'Bobo' ? 'toutes' : 'Bobo')),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
        decoration: BoxDecoration(
          color: isActive ? AppColors.green : AppColors.background,
          border: Border.all(
            color: isActive ? AppColors.green : AppColors.border,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(fontFamily: 'PlusJakartaSans', 
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : AppColors.text2,
          ),
        ),
      ),
    );
  }

  Widget _buildFiliereCard(Filiere filiere) {
    final moyenne = _moyenneGenerale();
    final accessible = moyenne >= filiere.moyenneMin - 1;
    final facile = moyenne >= filiere.moyenneMin + 1;

    Color statusColor;
    String statusLabel;
    Color statusBg;

    if (facile) {
      statusColor = AppColors.green;
      statusBg = AppColors.greenLight;
      statusLabel = 'Accessible';
    } else if (accessible) {
      statusColor = AppColors.gold;
      statusBg = AppColors.goldLight;
      statusLabel = 'Limite';
    } else {
      statusColor = AppColors.red;
      statusBg = AppColors.redLight;
      statusLabel = 'Difficile';
    }

    String typeLabel;
    switch (filiere.type) {
      case 'grandes_ecoles':
        typeLabel = 'Grande école';
        break;
      case 'prive':
        typeLabel = 'Privé';
        break;
      default:
        typeLabel = 'Public';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border, width: 1.5),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child:
                      Text(filiere.emoji, style: const TextStyle(fontSize: 20)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      filiere.nom,
                      style: TextStyle(fontFamily: 'Sora', 
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      filiere.universite,
                      style: TextStyle(fontFamily: 'PlusJakartaSans', 
                        fontSize: 11,
                        color: AppColors.greenMid,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(fontFamily: 'PlusJakartaSans', 
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 10),
          // Infos
          Row(
            children: [
              _buildInfoChip(Icons.location_on_outlined, filiere.ville),
              const SizedBox(width: 10),
              _buildInfoChip(Icons.schedule_outlined, filiere.duree),
              const SizedBox(width: 10),
              _buildInfoChip(Icons.school_outlined, typeLabel),
            ],
          ),
          const SizedBox(height: 8),
          // Séries compatibles
          Row(
            children: [
              Text(
                'Séries : ',
                style: TextStyle(fontFamily: 'PlusJakartaSans', 
                  fontSize: 11,
                  color: AppColors.text3,
                ),
              ),
              ...filiere.seriesCompatibles.map((s) => Container(
                    margin: const EdgeInsets.only(right: 5),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.greenLight,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      'Term. $s',
                      style: TextStyle(fontFamily: 'PlusJakartaSans', 
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.green,
                      ),
                    ),
                  )),
              const Spacer(),
              Text(
                'Moy. min : ${filiere.moyenneMin}/20',
                style: TextStyle(fontFamily: 'Sora', 
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Débouchés
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.work_outline,
                    size: 13, color: AppColors.text3),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    filiere.debouche,
                    style: TextStyle(fontFamily: 'PlusJakartaSans', 
                      fontSize: 11,
                      color: AppColors.text2,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.text3),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(fontFamily: 'PlusJakartaSans', 
            fontSize: 11,
            color: AppColors.text2,
          ),
        ),
      ],
    );
  }

  Widget _buildFiliereEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🔍', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(
            'Aucune filière trouvée',
            style: TextStyle(fontFamily: 'Sora', 
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Essaie un autre filtre',
            style: TextStyle(fontFamily: 'PlusJakartaSans', 
              fontSize: 13,
              color: AppColors.text3,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Widgets communs ─────────────────────────────────────────────────────────

  Widget _buildSageHint(String text) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.dark,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.goldMid, AppColors.gold],
              ),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Center(
              child: Text('🧙', style: TextStyle(fontSize: 14)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LE SAGE',
                  style: TextStyle(fontFamily: 'PlusJakartaSans', 
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppColors.goldMid,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  text,
                  style: TextStyle(fontFamily: 'PlusJakartaSans', 
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.82),
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoutonSuivant(String label, VoidCallback onTap) {
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.only(
        top: 12,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.green,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
          ),
          child: Text(
            label,
            style: TextStyle(fontFamily: 'PlusJakartaSans', 
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}