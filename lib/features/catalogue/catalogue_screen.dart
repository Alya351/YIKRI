import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/niveau_helper.dart';
import '../../core/services/app_service.dart';
import '../cours/cours_screen.dart';
import '../../core/services/paiement_service.dart';

class CatalogueScreen extends StatefulWidget {
  final String classe;
  const CatalogueScreen({super.key, this.classe = 'Terminale D'});

  @override
  State<CatalogueScreen> createState() => _CatalogueScreenState();
}

class _CatalogueScreenState extends State<CatalogueScreen>
    with SingleTickerProviderStateMixin {
  int _filtreActif = 0;
  bool _loading = true;
  String _recherche = '';
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  final TextEditingController _searchController = TextEditingController();

  List<String> get _filtres {
    if (NiveauHelper.isCollege(widget.classe)) return ['Tous', 'Maths', 'SVT', 'Français', 'Histoire'];
    if (NiveauHelper.isSeconde(widget.classe)) return ['Tous', 'Maths', 'Physique', 'SVT', 'Français'];
    final s = NiveauHelper.getSerie(widget.classe);
    if (s == 'A') return ['Tous', 'Philo', 'Français', 'Histoire', 'Anglais'];
    if (s == 'C') return ['Tous', 'Maths', 'Physique', 'Chimie', 'Français'];
    return ['Tous', 'Maths', 'SVT', 'Physique', 'Français'];
  }

  List<Map<String, dynamic>> get _cours {
    final classe = widget.classe;
    final serie = NiveauHelper.getSerie(classe);
    if (NiveauHelper.isCollege(classe)) return [
      {'matiere': 'MATHS', 'niveau': classe, 'titre': 'Arithmétique et fractions', 'enseignant': 'Prof. Kaboré Ibrahim', 'verifie': true, 'note': 4.7, 'eleves': 342, 'format': 'PDF + Audio', 'prix': 150, 'gratuit': false},
      {'matiere': 'FRANÇAIS', 'niveau': classe, 'titre': 'Grammaire et expression écrite', 'enseignant': 'Prof. Sawadogo Aline', 'verifie': true, 'note': 4.5, 'eleves': 289, 'format': 'PDF', 'prix': 0, 'gratuit': true},
      {'matiere': 'SVT', 'niveau': classe, 'titre': 'La cellule — Introduction aux sciences du vivant', 'enseignant': 'Prof. Ouédraogo Fatima', 'verifie': true, 'note': 4.6, 'eleves': 198, 'format': 'Vidéo', 'prix': 150, 'gratuit': false},
      {'matiere': 'HISTOIRE', 'niveau': classe, 'titre': 'Histoire du Burkina Faso', 'enseignant': 'Prof. Kaboré Adama', 'verifie': true, 'note': 4.8, 'eleves': 312, 'format': 'PDF + Audio', 'prix': 0, 'gratuit': true},
      {'matiere': 'MATHS', 'niveau': classe, 'titre': 'Géométrie — Triangles et cercles', 'enseignant': 'Prof. Kaboré Ibrahim', 'verifie': false, 'note': 4.3, 'eleves': 156, 'format': 'PDF', 'prix': 150, 'gratuit': false},
    ];
    if (NiveauHelper.isSeconde(classe)) return [
      {'matiere': 'MATHS', 'niveau': classe, 'titre': 'Fonctions et représentations graphiques', 'enseignant': 'Prof. Kaboré Ibrahim', 'verifie': true, 'note': 4.8, 'eleves': 267, 'format': 'PDF + Audio', 'prix': 200, 'gratuit': false},
      {'matiere': 'PHYSIQUE', 'niveau': classe, 'titre': 'Mécanique — Introduction aux forces', 'enseignant': 'Prof. Traoré Moussa', 'verifie': true, 'note': 4.6, 'eleves': 198, 'format': 'PDF', 'prix': 0, 'gratuit': true},
      {'matiere': 'SVT', 'niveau': classe, 'titre': 'Organisation du vivant', 'enseignant': 'Prof. Ouédraogo Fatima', 'verifie': true, 'note': 4.5, 'eleves': 234, 'format': 'Vidéo', 'prix': 200, 'gratuit': false},
      {'matiere': 'FRANÇAIS', 'niveau': classe, 'titre': 'Lecture analytique et dissertation', 'enseignant': 'Prof. Sawadogo Aline', 'verifie': true, 'note': 4.7, 'eleves': 189, 'format': 'PDF + Audio', 'prix': 150, 'gratuit': false},
    ];
    final communs = [
      {'matiere': 'FRANÇAIS', 'niveau': widget.classe, 'titre': 'Techniques de dissertation et commentaire', 'enseignant': 'Prof. Sawadogo Aline', 'verifie': true, 'note': 4.6, 'eleves': 312, 'format': 'PDF + Audio', 'prix': 200, 'gratuit': false},
      {'matiere': 'HISTOIRE-GEO', 'niveau': widget.classe, 'titre': 'Géographie du Burkina Faso et Afrique', 'enseignant': 'Prof. Ouédraogo Paul', 'verifie': true, 'note': 4.4, 'eleves': 278, 'format': 'PDF', 'prix': 0, 'gratuit': true},
      {'matiere': 'ANGLAIS', 'niveau': widget.classe, 'titre': 'Anglais — Expression et compréhension', 'enseignant': 'Prof. Compaoré Sarah', 'verifie': true, 'note': 4.3, 'eleves': 198, 'format': 'Audio', 'prix': 150, 'gratuit': false},
    ];
    if (serie == 'A') {
      return [
        {'matiere': 'PHILO', 'niveau': widget.classe, 'titre': 'La liberté et le déterminisme', 'enseignant': 'Prof. Zongo Aristide', 'verifie': true, 'note': 4.7, 'eleves': 145, 'format': 'PDF + Audio', 'prix': 200, 'gratuit': false},
        {'matiere': 'FRANÇAIS', 'niveau': widget.classe, 'titre': 'Les figures de style — Maîtrise complète', 'enseignant': 'Prof. Sawadogo Aline', 'verifie': true, 'note': 4.8, 'eleves': 234, 'format': 'PDF + Audio', 'prix': 200, 'gratuit': false},
        {'matiere': 'HISTOIRE', 'niveau': widget.classe, 'titre': "L'Afrique de l'Ouest au XXème siècle", 'enseignant': 'Prof. Kaboré Adama', 'verifie': true, 'note': 4.5, 'eleves': 178, 'format': 'PDF', 'prix': 150, 'gratuit': false},
        {'matiere': 'PHILO', 'niveau': widget.classe, 'titre': "La conscience et l'inconscient", 'enseignant': 'Prof. Zongo Aristide', 'verifie': false, 'note': 4.3, 'eleves': 98, 'format': 'PDF', 'prix': 0, 'gratuit': true},
        ...communs,
      ];
    }
    if (serie == 'C') {
      return [
        {'matiere': 'MATHS', 'niveau': widget.classe, 'titre': 'Fonctions logarithmes et exponentielles', 'enseignant': 'Prof. Kaboré Ibrahim', 'verifie': true, 'note': 4.9, 'eleves': 287, 'format': 'PDF + Audio', 'prix': 200, 'gratuit': false},
        {'matiere': 'PHYSIQUE', 'niveau': widget.classe, 'titre': 'Électricité — Lois des circuits', 'enseignant': 'Prof. Traoré Moussa', 'verifie': true, 'note': 4.7, 'eleves': 198, 'format': 'PDF + Audio', 'prix': 200, 'gratuit': false},
        {'matiere': 'MATHS', 'niveau': widget.classe, 'titre': 'Intégrales et primitives — Méthodes', 'enseignant': 'Prof. Kaboré Ibrahim', 'verifie': true, 'note': 4.8, 'eleves': 312, 'format': 'PDF + Audio', 'prix': 200, 'gratuit': false},
        {'matiere': 'CHIMIE', 'niveau': widget.classe, 'titre': 'Réactions chimiques et équilibres', 'enseignant': 'Prof. Sawadogo Brice', 'verifie': false, 'note': 4.4, 'eleves': 134, 'format': 'PDF', 'prix': 0, 'gratuit': true},
        {'matiere': 'PHYSIQUE', 'niveau': widget.classe, 'titre': 'Mécanique — Lois de Newton avancées', 'enseignant': 'Prof. Traoré Moussa', 'verifie': true, 'note': 4.6, 'eleves': 167, 'format': 'Vidéo', 'prix': 150, 'gratuit': false},
        ...communs,
      ];
    }
    // Terminale D par défaut
    return [
      {'matiere': 'MATHS', 'niveau': widget.classe, 'titre': 'Équations du second degré — Méthodes complètes', 'enseignant': 'Prof. Kaboré Ibrahim', 'verifie': true, 'note': 4.8, 'eleves': 234, 'format': 'PDF + Audio', 'prix': 200, 'gratuit': false},
      {'matiere': 'SVT', 'niveau': widget.classe, 'titre': 'La cellule et ses fonctions biologiques', 'enseignant': 'Prof. Ouédraogo Fatima', 'verifie': true, 'note': 4.5, 'eleves': 189, 'format': 'Vidéo', 'prix': 200, 'gratuit': false},
      {'matiere': 'MATHS', 'niveau': widget.classe, 'titre': 'Fonctions dérivées et applications', 'enseignant': 'Prof. Kaboré Ibrahim', 'verifie': true, 'note': 4.7, 'eleves': 312, 'format': 'PDF + Audio', 'prix': 200, 'gratuit': false},
      {'matiere': 'SVT', 'niveau': widget.classe, 'titre': 'La photosynthèse — Mécanismes détaillés', 'enseignant': 'Prof. Ouédraogo Fatima', 'verifie': true, 'note': 4.6, 'eleves': 201, 'format': 'Vidéo', 'prix': 200, 'gratuit': false},
      {'matiere': 'PHYSIQUE', 'niveau': widget.classe, 'titre': 'Lois de Newton — Exercices corrigés', 'enseignant': 'Prof. Traoré Moussa', 'verifie': false, 'note': 4.3, 'eleves': 98, 'format': 'PDF', 'prix': 0, 'gratuit': true},
      {'matiere': 'SVT', 'niveau': widget.classe, 'titre': 'Génétique et hérédité — Terminale D', 'enseignant': 'Prof. Compaoré Jean', 'verifie': true, 'note': 4.4, 'eleves': 156, 'format': 'PDF + Audio', 'prix': 150, 'gratuit': false},
      ...communs,
    ];
  }

  List<Map<String, dynamic>> get _coursFiltres {
    return _cours.where((c) {
      final filtreOk = _filtreActif == 0 ||
          c['matiere'].toString().toLowerCase() ==
              _filtres[_filtreActif].toLowerCase() ||
          c['matiere'].toString().toLowerCase().contains(
              _filtres[_filtreActif].toLowerCase().substring(0, 3));
      final rechercheOk = _recherche.isEmpty ||
          c['titre'].toString().toLowerCase().contains(
              _recherche.toLowerCase()) ||
          c['enseignant'].toString().toLowerCase().contains(
              _recherche.toLowerCase());
      return filtreOk && rechercheOk;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();
    // Simuler chargement
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _loading = false);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
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
              child: _coursFiltres.isEmpty
                  ? _buildEmpty()
                  : ListView.builder(
                      padding: const EdgeInsets.all(13),
                      itemCount: _coursFiltres.length,
                      itemBuilder: (context, index) {
                        return _buildCoursCard(_coursFiltres[index]);
                      },
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
          Text(
            'Catalogue',
            style: GoogleFonts.sora(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 11),
          // Barre de recherche
          Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border.all(color: AppColors.border, width: 1.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _recherche = val),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppColors.text,
              ),
              decoration: InputDecoration(
                hintText: 'Rechercher un cours...',
                hintStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: AppColors.text3,
                ),
                prefixIcon: const Icon(Icons.search,
                    color: AppColors.text3, size: 18),
                suffixIcon: _recherche.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          setState(() => _recherche = '');
                          _searchController.clear();
                        },
                        child: const Icon(Icons.close,
                            color: AppColors.text3, size: 16),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 13, vertical: 11),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Filtres
          SizedBox(
            height: 34,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _filtres.length,
              itemBuilder: (context, index) {
                final isActive = _filtreActif == index;
                return GestureDetector(
                  onTap: () => setState(() => _filtreActif = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 7),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.green : AppColors.background,
                      border: Border.all(
                        color:
                            isActive ? AppColors.green : AppColors.border,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _filtres[index],
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isActive ? Colors.white : AppColors.text2,
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


  Widget _buildShimmerCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(height: 5, decoration: BoxDecoration(
          color: AppColors.border, borderRadius: BorderRadius.circular(18),
        )),
        const SizedBox(height: 12),
        Row(children: [
          Container(width: 60, height: 20, decoration: BoxDecoration(
            color: AppColors.background, borderRadius: BorderRadius.circular(5),
          )),
          const Spacer(),
          Container(width: 50, height: 20, decoration: BoxDecoration(
            color: AppColors.background, borderRadius: BorderRadius.circular(5),
          )),
        ]),
        const SizedBox(height: 10),
        Container(height: 16, width: double.infinity, decoration: BoxDecoration(
          color: AppColors.background, borderRadius: BorderRadius.circular(5),
        )),
        const SizedBox(height: 6),
        Container(height: 12, width: 180, decoration: BoxDecoration(
          color: AppColors.background, borderRadius: BorderRadius.circular(5),
        )),
      ]),
    );
  }

  Color _getMatiereColor(String m) {
    final mu = m.toUpperCase();
    if (mu.contains('MATHS')) return AppColors.goldMid;
    if (mu.contains('SVT')) return AppColors.greenMid;
    if (mu.contains('PHYSIQUE')) return const Color(0xFF5B8DEF);
    if (mu.contains('PHILO')) return const Color(0xFF9B59B6);
    if (mu.contains('FRAN')) return AppColors.red;
    if (mu.contains('HIST')) return const Color(0xFFE67E22);
    if (mu.contains('ANGL')) return const Color(0xFF1ABC9C);
    if (mu.contains('CHIM')) return const Color(0xFFE74C3C);
    return AppColors.greenMid;
  }

  Widget _buildCoursCard(Map<String, dynamic> cours) {
    final bool estGratuit = cours['gratuit'] == true;
    final color = _getMatiereColor(cours['matiere'].toString());

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(
          color: color.withOpacity(0.08),
          blurRadius: 16, offset: const Offset(0, 4),
        )],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bandeau coloré matière
          Container(
            height: 5,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Matière + Prix
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Text(
                        '${cours['matiere']} · ${cours['niveau']}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9, fontWeight: FontWeight.w700,
                          color: color, letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    estGratuit
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.greenLight,
                              border: Border.all(color: AppColors.greenMid.withOpacity(0.3)),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Text('GRATUIT', style: GoogleFonts.sora(
                              fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.green,
                            )),
                          )
                        : Text('${cours['prix']} FCFA', style: GoogleFonts.sora(
                            fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.text,
                          )),
                  ],
                ),
                const SizedBox(height: 8),
                Text(cours['titre'], style: GoogleFonts.plusJakartaSans(
                  fontSize: 14, fontWeight: FontWeight.w700,
                  color: AppColors.text, height: 1.35,
                )),
                const SizedBox(height: 5),
                Row(children: [
                  Text(cours['enseignant'], style: GoogleFonts.plusJakartaSans(
                    fontSize: 11, color: AppColors.text3,
                  )),
                  if (cours['verifie'] == true) ...[
                    const SizedBox(width: 5),
                    Container(
                      width: 14, height: 14,
                      decoration: const BoxDecoration(
                        color: AppColors.green, shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, size: 9, color: Colors.white),
                    ),
                  ],
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  _buildMeta('${cours['note']}', Icons.star_rounded, AppColors.goldMid),
                  const SizedBox(width: 12),
                  _buildMeta('${cours['eleves']} élèves', Icons.people_outline, AppColors.text3),
                  const SizedBox(width: 12),
                  _buildMeta('${cours['format']}', Icons.description_outlined, AppColors.text3),
                ]),
                const SizedBox(height: 12),
                if (!estGratuit)
                  Row(children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _showAchatModal(context, cours),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.green,
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                        ),
                        child: Text('${cours['prix']} FCFA', style: GoogleFonts.plusJakartaSans(
                          fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white,
                        )),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _showAchatModal(context, cours),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border, width: 1.5),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: const Icon(Icons.bookmark_border_rounded,
                            size: 20, color: AppColors.text3),
                      ),
                    ),
                  ])
                else
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _showAchatModal(context, cours),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.greenMid,
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                      ),
                      child: Text('Accéder gratuitement →', style: GoogleFonts.plusJakartaSans(
                        fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white,
                      )),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeta(String label, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            color: AppColors.text3,
          ),
        ),
      ],
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🔍', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(
            'Aucun cours trouvé',
            style: GoogleFonts.sora(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Essaie un autre filtre ou mot-clé',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: AppColors.text3,
            ),
          ),
        ],
      ),
    );
  }

  void _showAchatModal(
      BuildContext context, Map<String, dynamic> cours) {
    PaiementMobileMoneyModal.show(context, montant: cours['prix'] as int? ?? 200, description: cours['titre'] as String? ?? 'Cours', onSuccess: () async { await AppService().marquerActivite(); });
  }
}
