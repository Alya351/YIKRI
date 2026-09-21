import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';

class CalendrierScreen extends StatefulWidget {
  final String classe;
  const CalendrierScreen({super.key, this.classe = 'Terminale D'});

  @override
  State<CalendrierScreen> createState() => _CalendrierScreenState();
}

class _CalendrierScreenState extends State<CalendrierScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  int _selectedCategory = 0;
  final List<String> _categories = ['BAC', 'Controles', 'Concours'];

  // Événements BAC Burkina Faso
  List<_Examen> get _examens => [
    _Examen(
      titre: 'BAC - Epreuve de Philosophie',
      date: DateTime(2026, 6, 2),
      matiere: 'Philosophie',
      emoji: '💭',
      type: 'BAC',
      duree: '4h',
      serie: 'Toutes series',
      couleur: AppColors.greenMid,
    ),
    _Examen(
      titre: 'BAC - Epreuve de Francais',
      date: DateTime(2026, 6, 3),
      matiere: 'Francais',
      emoji: '✍️',
      type: 'BAC',
      duree: '4h',
      serie: 'Toutes series',
      couleur: AppColors.greenMid,
    ),
    _Examen(
      titre: 'BAC - Mathematiques',
      date: DateTime(2026, 6, 4),
      matiere: 'Maths',
      emoji: '📐',
      type: 'BAC',
      duree: '4h',
      serie: 'C, D',
      couleur: AppColors.goldMid,
    ),
    _Examen(
      titre: 'BAC - Sciences de la Vie',
      date: DateTime(2026, 6, 5),
      matiere: 'SVT',
      emoji: '🌿',
      type: 'BAC',
      duree: '3h',
      serie: 'D',
      couleur: AppColors.goldMid,
    ),
    _Examen(
      titre: 'BAC - Physique Chimie',
      date: DateTime(2026, 6, 6),
      matiere: 'Physique',
      emoji: '⚗️',
      type: 'BAC',
      duree: '3h',
      serie: 'C, D',
      couleur: AppColors.goldMid,
    ),
    _Examen(
      titre: 'BAC - Histoire Geographie',
      date: DateTime(2026, 6, 9),
      matiere: 'Histoire-Geo',
      emoji: '🗺️',
      type: 'BAC',
      duree: '4h',
      serie: 'Toutes series',
      couleur: AppColors.greenMid,
    ),
    _Examen(
      titre: 'BAC - Anglais',
      date: DateTime(2026, 6, 10),
      matiere: 'Anglais',
      emoji: '🌍',
      type: 'BAC',
      duree: '2h',
      serie: 'Toutes series',
      couleur: AppColors.greenMid,
    ),
    _Examen(
      titre: 'Resultats BAC session 1',
      date: DateTime(2026, 7, 5),
      matiere: 'Resultats',
      emoji: '🏆',
      type: 'BAC',
      duree: '',
      serie: 'Toutes series',
      couleur: AppColors.goldMid,
    ),
    _Examen(
      titre: 'Concours entree 2iE',
      date: DateTime(2026, 7, 15),
      matiere: 'Concours',
      emoji: '🏗️',
      type: 'Concours',
      duree: '6h',
      serie: 'C, D',
      couleur: AppColors.red,
    ),
    _Examen(
      titre: 'Concours entree ISGE-BF',
      date: DateTime(2026, 7, 18),
      matiere: 'Concours',
      emoji: '📡',
      type: 'Concours',
      duree: '4h',
      serie: 'C, D',
      couleur: AppColors.red,
    ),
    _Examen(
      titre: 'Concours entree IMG',
      date: DateTime(2026, 7, 20),
      matiere: 'Concours',
      emoji: '⛏️',
      type: 'Concours',
      duree: '4h',
      serie: 'C, D',
      couleur: AppColors.red,
    ),
    _Examen(
      titre: 'Controle de Maths - T1',
      date: DateTime(2026, 6, 15),
      matiere: 'Maths',
      emoji: '📐',
      type: 'Controles',
      duree: '2h',
      serie: widget.classe,
      couleur: AppColors.goldMid,
    ),
    _Examen(
      titre: 'Controle de SVT - T1',
      date: DateTime(2026, 6, 17),
      matiere: 'SVT',
      emoji: '🌿',
      type: 'Controles',
      duree: '1h30',
      serie: widget.classe,
      couleur: AppColors.greenMid,
    ),
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
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int _joursRestants(DateTime date) {
    final now = DateTime.now();
    return date.difference(DateTime(now.year, now.month, now.day)).inDays;
  }

  List<_Examen> get _filtres {
    final cat = _categories[_selectedCategory];
    return _examens.where((e) => e.type == cat).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  _Examen? get _prochainExamen {
    final bac = _examens
        .where((e) => e.type == 'BAC' && _joursRestants(e.date) >= 0)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    return bac.isNotEmpty ? bac.first : null;
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
            _buildCountdown(),
            _buildCategories(),
            Expanded(child: _buildList()),
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
        left: 16,
        right: 16,
        bottom: 16,
      ),
      child: Row(
        children: [
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
            Text('Calendrier des examens',
                style: GoogleFonts.sora(
                    fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
            Text('Burkina Faso · ${widget.classe}',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 11, color: Colors.white.withOpacity(0.4))),
          ]),
          const Spacer(),
          const Text('📅', style: TextStyle(fontSize: 22)),
        ],
      ),
    );
  }

  Widget _buildCountdown() {
    final prochain = _prochainExamen;
    if (prochain == null) return const SizedBox.shrink();
    final jours = _joursRestants(prochain.date);
    final details = [
      _formatDate(prochain.date),
      if (prochain.duree.isNotEmpty) prochain.duree,
    ].join(' · ');

    return Container(
      margin: const EdgeInsets.all(14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.dark,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          // Compte à rebours
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.goldMid, AppColors.gold],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$jours',
                  style: GoogleFonts.sora(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1,
                  ),
                ),
                Text(
                  jours == 1 ? 'jour' : 'jours',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.goldMid.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text('PROCHAIN EXAMEN',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 8, fontWeight: FontWeight.w700,
                          color: AppColors.goldMid, letterSpacing: 0.5)),
                ),
                const SizedBox(height: 6),
                Text(
                  prochain.titre,
                  style: GoogleFonts.sora(
                    fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  details,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11, color: Colors.white.withOpacity(0.45),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
      child: Row(
        children: List.generate(_categories.length, (i) {
          final isActive = _selectedCategory == i;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              decoration: BoxDecoration(
                color: isActive ? AppColors.green : AppColors.background,
                border: Border.all(
                  color: isActive ? AppColors.green : AppColors.border,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _categories[i],
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.white : AppColors.text2,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildList() {
    final liste = _filtres;
    if (liste.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('📭', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 12),
            Text('Aucun evenement', style: GoogleFonts.sora(
                fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.text)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 24),
      itemCount: liste.length,
      itemBuilder: (context, i) => _buildExamenCard(liste[i]),
    );
  }

  Widget _buildExamenCard(_Examen e) {
    final jours = _joursRestants(e.date);
    final passe = jours < 0;

    Color statusColor;
    String statusLabel;
    Color statusBg;

    if (passe) {
      statusColor = AppColors.text3;
      statusBg = AppColors.background;
      statusLabel = 'Termine';
    } else if (jours == 0) {
      statusColor = AppColors.red;
      statusBg = AppColors.redLight;
      statusLabel = "Aujourd'hui !";
    } else if (jours <= 7) {
      statusColor = AppColors.red;
      statusBg = AppColors.redLight;
      statusLabel = '$jours jours';
    } else if (jours <= 30) {
      statusColor = AppColors.gold;
      statusBg = AppColors.goldLight;
      statusLabel = '$jours jours';
    } else {
      statusColor = AppColors.green;
      statusBg = AppColors.greenLight;
      statusLabel = '$jours jours';
    }

    return Opacity(
      opacity: passe ? 0.5 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(
            color: jours <= 7 && !passe ? e.couleur.withOpacity(0.3) : AppColors.border,
            width: jours <= 7 && !passe ? 2 : 1.5,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(
                color: e.couleur.withOpacity(0.1),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Center(child: Text(e.emoji, style: const TextStyle(fontSize: 22))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(e.titre,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.text)),
                  const SizedBox(height: 3),
                  Row(children: [
                    Text(_formatDate(e.date),
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 11, color: AppColors.text3)),
                    if (e.duree.isNotEmpty) ...[
                      Text(' · ', style: GoogleFonts.plusJakartaSans(
                          fontSize: 11, color: AppColors.text3)),
                      Text(e.duree, style: GoogleFonts.plusJakartaSans(
                          fontSize: 11, color: AppColors.text3)),
                    ],
                  ]),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: e.couleur.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(e.serie,
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 9, fontWeight: FontWeight.w700,
                            color: e.couleur)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: statusBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(statusLabel,
                  style: GoogleFonts.sora(
                      fontSize: 11, fontWeight: FontWeight.w700, color: statusColor)),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    final mois = ['Jan', 'Fev', 'Mar', 'Avr', 'Mai', 'Juin',
        'Juil', 'Aout', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${d.day} ${mois[d.month - 1]} ${d.year}';
  }
}

class _Examen {
  final String titre;
  final DateTime date;
  final String matiere;
  final String emoji;
  final String type;
  final String duree;
  final String serie;
  final Color couleur;

  const _Examen({
    required this.titre,
    required this.date,
    required this.matiere,
    required this.emoji,
    required this.type,
    required this.duree,
    required this.serie,
    required this.couleur,
  });
}
