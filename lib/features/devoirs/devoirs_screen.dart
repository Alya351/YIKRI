import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../sage/defi_screen.dart';

class DevoirsScreen extends StatefulWidget {
  const DevoirsScreen({super.key});

  @override
  State<DevoirsScreen> createState() => _DevoirsScreenState();
}

class _DevoirsScreenState extends State<DevoirsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> _devoirsUrgents = [
    {
      'matiere': 'MATHS',
      'titre': 'Exercices — Équations du second degré',
      'deadline': 'Dans 3h',
      'duree': '45 min',
      'isSage': false,
    },
  ];

  final List<Map<String, dynamic>> _devoirsSemaine = [
    {
      'matiere': 'FRANÇAIS',
      'titre': 'Dissertation — L\'éducation en Afrique',
      'enseignant': 'Prof. Traoré',
      'jour': 'Lun',
      'isSage': false,
      'icon': '📄',
    },
    {
      'matiere': 'SVT',
      'titre': 'Plan de révision SVT',
      'enseignant': 'Le Sage',
      'jour': 'Mar',
      'isSage': true,
      'icon': '🧙',
    },
    {
      'matiere': 'PHYSIQUE',
      'titre': 'TP Physique — Lois de Newton',
      'enseignant': 'Prof. Kaboré',
      'jour': 'Jeu',
      'isSage': false,
      'icon': '🔬',
    },
    {
      'matiere': 'MATHS',
      'titre': 'Défi Sage — Fonctions dérivées',
      'enseignant': 'Le Sage',
      'jour': 'Ven',
      'isSage': true,
      'icon': '🧙',
    },
  ];

  final List<Map<String, dynamic>> _devoirsTermines = [
    {
      'titre': 'QCM Maths — Fonctions',
      'score': '85%',
      'credits': '+3 crédits',
    },
    {
      'titre': 'Défi SVT — La cellule',
      'score': 'Réussi',
      'credits': '+5 crédits',
    },
    {
      'titre': 'Dissertation Français',
      'score': '14/20',
      'credits': '+2 crédits',
    },
  ];

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
  }

  @override
  void dispose() {
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
                padding: const EdgeInsets.all(13),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Urgents
                    _buildSectionLabel('⚡ URGENT', AppColors.red),
                    const SizedBox(height: 8),
                    ..._devoirsUrgents.map(_buildUrgentCard),

                    const SizedBox(height: 14),

                    // Cette semaine
                    _buildSectionLabel('CETTE SEMAINE', AppColors.text3),
                    const SizedBox(height: 8),
                    ..._devoirsSemaine.map(_buildSemaineRow),

                    const SizedBox(height: 14),

                    // Terminés
                    _buildSectionLabel('TERMINÉS', AppColors.text3),
                    const SizedBox(height: 8),
                    ..._devoirsTermines.map(_buildTermineRow),

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
      color: AppColors.white,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 14,
        left: 16,
        right: 16,
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
            'Devoirs',
            style: GoogleFonts.sora(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          const Spacer(),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.greenLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_devoirsUrgents.length + _devoirsSemaine.length} à faire',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label, Color color) {
    return Text(
      label,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildUrgentCard(Map<String, dynamic> devoir) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.red, width: 1.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.redLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  devoir['matiere'],
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppColors.red,
                  ),
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  const Icon(Icons.access_time,
                      size: 12, color: AppColors.red),
                  const SizedBox(width: 4),
                  Text(
                    devoir['deadline'],
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            devoir['titre'],
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Durée estimée : ${devoir['duree']}',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: AppColors.text3,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const DefiScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.red,
                padding: const EdgeInsets.symmetric(vertical: 11),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11)),
              ),
              child: Text(
                'Commencer maintenant →',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSemaineRow(Map<String, dynamic> devoir) {
    final isSage = devoir['isSage'] as bool;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(
          color: isSage
              ? AppColors.greenMid.withOpacity(0.3)
              : AppColors.border,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          // Icône
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isSage ? AppColors.greenLight : AppColors.background,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Center(
              child: Text(
                devoir['icon'],
                style: const TextStyle(fontSize: 17),
              ),
            ),
          ),
          const SizedBox(width: 11),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      devoir['titre'],
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
                    if (isSage) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.greenLight,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          'LE SAGE',
                          style: GoogleFonts.plusJakartaSans(
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
                  '${devoir['matiere']} · ${devoir['enseignant']}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: AppColors.text3,
                  ),
                ),
              ],
            ),
          ),
          // Jour deadline
          Text(
            devoir['jour'],
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.text3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermineRow(Map<String, dynamic> devoir) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border, width: 1.5),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          // Checkmark
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.greenLight,
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(Icons.check,
                size: 14, color: AppColors.greenMid),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  devoir['titre'],
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.text2,
                  ),
                ),
                Text(
                  'Score : ${devoir['score']} · ${devoir['credits']}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.greenMid,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}