import 'package:flutter/material.dart';
import '../../core/services/app_service.dart';
import '../../core/theme/app_theme.dart';
import '../classement/classement_screen.dart';
import '../profil/profil_screen.dart';
import 'classe_connectee_screen.dart';
import 'publier_cours_screen.dart';

class EnseignantScreen extends StatefulWidget {
  const EnseignantScreen({super.key});

  @override
  State<EnseignantScreen> createState() => _EnseignantScreenState();
}

class _EnseignantScreenState extends State<EnseignantScreen>
    with SingleTickerProviderStateMixin {
  int _currentTab = 0;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> _cours = [
    {
      'titre': 'Équations du second degré',
      'matiere': 'MATHS',
      'eleves': 234,
      'note': 4.8,
      'revenus': 47200,
    },
    {
      'titre': 'Fonctions et dérivées',
      'matiere': 'MATHS',
      'eleves': 189,
      'note': 4.6,
      'revenus': 37800,
    },
    {
      'titre': 'Trigonométrie avancée',
      'matiere': 'MATHS',
      'eleves': 98,
      'note': 4.4,
      'revenus': 19600,
    },
  ];

  UserProfile? get _profile => AppService().profile;
  String get _prenom => _profile?.prenom.isNotEmpty == true ? _profile!.prenom : 'Kaboré';
  String get _nom => _profile?.nom.isNotEmpty == true ? _profile!.nom : 'Ibrahim';
  String get _nomComplet => 'Prof. $_prenom $_nom';
  String get _matiere => _profile?.matiere.isNotEmpty == true ? _profile!.matiere : 'Mathématiques';
  String get _avatar => _profile?.avatar.isNotEmpty == true ? _profile!.avatar : '🎓';

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

  Future<void> _ouvrirPublication() async {
    final cours = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => PublierCoursScreen()),
    );
    if (!mounted) return;
    if (cours == null) {
      setState(() => _currentTab = 0);
      return;
    }

    setState(() {
      _currentTab = 0;
      _cours.insert(0, cours);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Cours publié avec succès',
            style: TextStyle(fontFamily: 'PlusJakartaSans')),
        backgroundColor: AppColors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
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
                    // Bandeau national
                    _buildLiveBandeau(),
                    const SizedBox(height: 14),

                    // Insight Le Sage
                    _buildSageInsight(),
                    const SizedBox(height: 14),

                    // Mes cours
                    _buildSectionTitle('Mes cours publiés', '${_cours.length} cours'),
                    const SizedBox(height: 9),
                    ..._cours.map(_buildCoursCard),

                    const SizedBox(height: 14),

                    // Bouton publier
                    _buildPublierBtn(),
                    const SizedBox(height: 20),
                  ],
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
      color: AppColors.dark2,
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
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.goldMid, AppColors.gold],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Center(
                  child: Center(child: Text('KI', style: TextStyle(fontFamily: 'Sora', fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white))),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _nomComplet,
                    style: TextStyle(fontFamily: 'PlusJakartaSans', 
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        '$_matiere · ',
                        style: TextStyle(fontFamily: 'PlusJakartaSans', 
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.4),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.greenMid.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          '✓ Vérifié',
                          style: TextStyle(fontFamily: 'PlusJakartaSans', 
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppColors.greenMid,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              Stack(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(11),
                    ),
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
                        border: Border.all(
                            color: AppColors.dark2, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Stats
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              border: Border.all(
                  color: Colors.white.withOpacity(0.08)),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                _buildStat('521', 'Élèves'),
                _buildStatDiv(),
                _buildStat('104 600', 'FCFA', isGold: true),
                _buildStatDiv(),
                _buildStat('4.6', 'Note moy.'),
                _buildStatDiv(),
                _buildStat('#3', 'Classement'),
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
            style: TextStyle(fontFamily: 'Sora', 
              fontSize: val.length > 5 ? 13 : 17,
              fontWeight: FontWeight.w700,
              color: isGold ? AppColors.goldMid : Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontFamily: 'PlusJakartaSans', 
              fontSize: 10,
              color: Colors.white.withOpacity(0.35),
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

  Widget _buildLiveBandeau() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.greenLight,
        border: Border.all(
            color: AppColors.green.withOpacity(0.15)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
                shape: BoxShape.circle, color: AppColors.greenMid),
          ),
          const SizedBox(width: 8),
          Text(
            '1 247 élèves actifs au Burkina Faso aujourd\'hui',
            style: TextStyle(fontFamily: 'PlusJakartaSans', 
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSageInsight() {
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
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.goldMid, AppColors.gold],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Center(
                child: Text('🧙', style: TextStyle(fontSize: 15))),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LE SAGE DÉTECTE',
                  style: TextStyle(fontFamily: 'PlusJakartaSans', 
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.goldMid,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '67% de vos élèves bloquent sur les équations du 2nd degré depuis 3 jours.',
                  style: TextStyle(fontFamily: 'PlusJakartaSans', 
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.82),
                    height: 1.55,
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ClasseConnecteeScreen()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.greenMid.withOpacity(0.15),
                      border: Border.all(
                          color: AppColors.greenMid.withOpacity(0.25)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Assigner un cours correctif →',
                      style: TextStyle(fontFamily: 'PlusJakartaSans', 
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
    );
  }

  Widget _buildSectionTitle(String title, String sub) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: TextStyle(fontFamily: 'Sora', 
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.text)),
        Text(sub,
            style: TextStyle(fontFamily: 'PlusJakartaSans', 
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.greenMid)),
      ],
    );
  }

  Widget _buildCoursCard(Map<String, dynamic> cours) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border, width: 1.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.greenLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        cours['matiere'],
                        style: TextStyle(fontFamily: 'PlusJakartaSans', 
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AppColors.green,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  cours['titre'],
                  style: TextStyle(fontFamily: 'PlusJakartaSans', 
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                if (cours['format'] != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${cours['format']} · ${cours['fichier'] ?? 'fichier joint'}',
                    style: TextStyle(fontFamily: 'PlusJakartaSans',
                        fontSize: 10, color: AppColors.text3),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      '👥 ${cours['eleves']} élèves',
                      style: TextStyle(fontFamily: 'PlusJakartaSans', 
                          fontSize: 11, color: AppColors.text3),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      (cours['note'] as num) > 0
                          ? '★ ${cours['note']}'
                          : 'Nouveau',
                      style: TextStyle(fontFamily: 'PlusJakartaSans', 
                          fontSize: 11, color: AppColors.goldMid),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${cours['revenus']} FCFA',
                style: TextStyle(fontFamily: 'Sora', 
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.green,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  border: Border.all(
                      color: AppColors.border, width: 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Voir →',
                  style: TextStyle(fontFamily: 'PlusJakartaSans', 
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text2,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPublierBtn() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          _ouvrirPublication();
        },
        icon: const Icon(Icons.add, size: 18),
        label: Text(
          'Publier un nouveau cours',
          style: TextStyle(fontFamily: 'PlusJakartaSans', 
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.green,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(13)),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    final items = [
      {'icon': Icons.dashboard_outlined, 'label': 'Tableau'},
      {'icon': Icons.menu_book_outlined, 'label': 'Cours'},
      {'icon': Icons.class_outlined, 'label': 'Classes'},
      {'icon': Icons.leaderboard_outlined, 'label': 'Classement'},
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
          return GestureDetector(
            onTap: () {
              setState(() => _currentTab = index);
              if (index == 1) {
                _ouvrirPublication();
              } else if (index == 2) {
                Navigator.push(context, MaterialPageRoute(builder: (_) => ClasseConnecteeScreen())).then((_) => setState(() => _currentTab = 0));
              } else if (index == 3) {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ClassementScreen())).then((_) => setState(() => _currentTab = 0));
              } else if (index == 4) {
                Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilScreen(prenom: _prenom, nom: _nom, avatar: 'KI', classe: 'Enseignant'))).then((_) => setState(() => _currentTab = 0));
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(items[index]['icon'] as IconData,
                    size: 22,
                    color: isActive ? AppColors.green : AppColors.text3),
                const SizedBox(height: 3),
                Text(items[index]['label'] as String,
                    style: TextStyle(fontFamily: 'PlusJakartaSans', 
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                      color: isActive ? AppColors.green : AppColors.text3,
                    )),
                if (isActive)
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
