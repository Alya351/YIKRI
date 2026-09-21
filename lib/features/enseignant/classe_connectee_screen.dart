import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';

class ClasseConnecteeScreen extends StatefulWidget {
  const ClasseConnecteeScreen({super.key});

  @override
  State<ClasseConnecteeScreen> createState() => _ClasseConnecteeScreenState();
}

class _ClasseConnecteeScreenState extends State<ClasseConnecteeScreen>
    with SingleTickerProviderStateMixin {
  int _tabActif = 0;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> _eleves = [
    {'initiales': 'AO', 'nom': 'Aminata Ouédraogo', 'niveau': 'SAGE', 'statut': 'ok', 'info': 'Défi réussi · il y a 5 min', 'couleur': 'a'},
    {'initiales': 'SK', 'nom': 'Salif Kaboré', 'niveau': 'ÉRUDIT', 'statut': 'bloque', 'info': 'Bloqué depuis 18 min', 'couleur': 'c'},
    {'initiales': 'FT', 'nom': 'Fatima Traoré', 'niveau': 'ÉRUDIT', 'statut': 'cours', 'info': 'En cours · 45% complété', 'couleur': 'b'},
    {'initiales': 'MK', 'nom': 'Moussa Kaboré', 'niveau': 'APPRENTI', 'statut': 'offline', 'info': 'Hors ligne depuis 2h', 'couleur': 'a'},
    {'initiales': 'RO', 'nom': 'Rasmata Ouédraogo', 'niveau': 'ÉRUDIT', 'statut': 'ok', 'info': 'QCM terminé · 92%', 'couleur': 'b'},
    {'initiales': 'AB', 'nom': 'Adama Bassole', 'niveau': 'APPRENTI', 'statut': 'bloque', 'info': 'Bloqué depuis 35 min', 'couleur': 'c'},
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
              child: _tabActif == 0
                  ? _buildSuiviEleves()
                  : _tabActif == 1
                      ? _buildDevoirs()
                      : _buildMessages(),
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
        children: [
          Row(
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
              const SizedBox(width: 10),
              Text(
                'Terminale D Maths',
                style: GoogleFonts.sora(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.greenLight,
                  border: Border.all(
                      color: AppColors.greenMid.withOpacity(0.2)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.greenMid),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'En direct',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(11),
            ),
            padding: const EdgeInsets.all(3),
            child: Row(
              children: [
                _buildTab('Suivi élèves', 0),
                _buildTab('Devoirs', 1),
                _buildTab('Messages', 2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isActive = _tabActif == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tabActif = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? AppColors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    )
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isActive ? AppColors.text : AppColors.text3,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuiviEleves() {
    final bloques = _eleves.where((e) => e['statut'] == 'bloque').length;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(13),
      child: Column(
        children: [
          // Insight Le Sage
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: AppColors.dark,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.goldMid, AppColors.gold],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                      child: Text('🧙', style: TextStyle(fontSize: 14))),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'LE SAGE DÉTECTE',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AppColors.goldMid,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '67% de vos élèves bloquent sur les équations du 2nd degré depuis 3 jours.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.8),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.greenMid.withOpacity(0.15),
                            border: Border.all(
                                color: AppColors.greenMid.withOpacity(0.25)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Assigner un cours correctif →',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.greenMid,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Stats rapides
          Row(
            children: [
              _buildMiniStat('${_eleves.length}', 'Élèves', AppColors.text),
              const SizedBox(width: 8),
              _buildMiniStat(
                  '$bloques', 'Bloqués', AppColors.red),
              const SizedBox(width: 8),
              _buildMiniStat(
                  '${_eleves.where((e) => e['statut'] == 'ok').length}',
                  'En avance',
                  AppColors.greenMid),
            ],
          ),

          const SizedBox(height: 12),

          // Code de classe
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 13, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border.all(color: AppColors.border, width: 1.5),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Row(
              children: [
                Text(
                  'Code : ',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 12, color: AppColors.text3),
                ),
                Text(
                  'CL-TRM-042',
                  style: GoogleFonts.sora(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.green,
                    letterSpacing: 1,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.copy, size: 15, color: AppColors.text3),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Liste élèves
          Text(
            '${_eleves.length} ÉLÈVES',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.text3,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          ..._eleves.map(_buildEleveRow),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String val, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.border, width: 1.5),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Column(
          children: [
            Text(val,
                style: GoogleFonts.sora(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: color)),
            Text(label,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 10, color: AppColors.text3)),
          ],
        ),
      ),
    );
  }

  Widget _buildEleveRow(Map<String, dynamic> eleve) {
    Color avBg, avTxt, stColor;
    switch (eleve['couleur']) {
      case 'a': avBg = const Color(0xFFFEF9E7); avTxt = const Color(0xFFB7791F); break;
      case 'b': avBg = AppColors.greenLight; avTxt = AppColors.green; break;
      default: avBg = AppColors.redLight; avTxt = AppColors.red;
    }
    switch (eleve['statut']) {
      case 'ok': stColor = AppColors.green; break;
      case 'bloque': stColor = AppColors.red; break;
      default: stColor = AppColors.text3;
    }

    final bool isSage = eleve['niveau'] == 'SAGE';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: avBg,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Center(
              child: Text(eleve['initiales'],
                  style: GoogleFonts.sora(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: avTxt)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      eleve['nom'],
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: isSage
                            ? AppColors.goldLight
                            : AppColors.greenLight,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        eleve['niveau'],
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          color: isSage ? AppColors.gold : AppColors.green,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  eleve['info'],
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: stColor,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _envoyerMessage(eleve['nom']),
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(Icons.mail_outline,
                  size: 15, color: AppColors.text3),
            ),
          ),
        ],
      ),
    );
  }

  void _envoyerMessage(String nom) {
    showDialog(
      context: context,
      builder: (ctx) {
        final ctrl = TextEditingController();
        return AlertDialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Message à $nom',
            style: GoogleFonts.sora(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.text),
          ),
          content: TextField(
            controller: ctrl,
            maxLines: 3,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 13, color: AppColors.text),
            decoration: InputDecoration(
              hintText: 'Écris ton message...',
              hintStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 13, color: AppColors.text3),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide:
                    const BorderSide(color: AppColors.border, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide:
                    const BorderSide(color: AppColors.border, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: const BorderSide(
                    color: AppColors.greenMid, width: 1.5),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Annuler',
                  style: GoogleFonts.plusJakartaSans(
                      color: AppColors.text3)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Message envoyé à $nom !',
                        style: GoogleFonts.plusJakartaSans()),
                    backgroundColor: AppColors.green,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                );
              },
              child: Text('Envoyer',
                  style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDevoirs() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📝', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text('Devoirs assignés',
              style: GoogleFonts.sora(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text)),
          const SizedBox(height: 8),
          Text('2 devoirs actifs cette semaine',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 13, color: AppColors.text3)),
        ],
      ),
    );
  }

  Widget _buildMessages() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('✉️', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text('Messagerie de classe',
              style: GoogleFonts.sora(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text)),
          const SizedBox(height: 8),
          Text('3 messages non lus',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 13, color: AppColors.text3)),
        ],
      ),
    );
  }
}