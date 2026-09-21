import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/app_service.dart';
import '../home/home_screen.dart';
import '../enseignant/enseignant_screen.dart';
import '../parent/parent_screen.dart';

class AvatarScreen extends StatefulWidget {
  final String prenom;
  final String nom;
  final int profileIndex;
  final String classe; // FIX: reçoit la classe depuis RegisterScreen
  final String matiere;

  const AvatarScreen({
    super.key,
    required this.prenom,
    this.nom = '',
    required this.profileIndex,
    this.classe = 'Terminale D',
    this.matiere = '',
  });

  @override
  State<AvatarScreen> createState() => _AvatarScreenState();
}

class _AvatarScreenState extends State<AvatarScreen>
    with SingleTickerProviderStateMixin {
  int _selectedAvatar = 0;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<Map<String, dynamic>> _avatars = [
    {'emoji': '👦', 'label': 'Garçon 1'},
    {'emoji': '👧', 'label': 'Fille 1'},
    {'emoji': '🧑', 'label': 'Neutre'},
    {'emoji': '👩', 'label': 'Femme'},
    {'emoji': '🧒', 'label': 'Enfant'},
    {'emoji': '👨', 'label': 'Homme'},
  ];

  String get _profileTitle =>
      ['Élève', 'Enseignant', 'Parent'][widget.profileIndex];

  // Message du Sage adapté au profil
  String get _sageMessage {
    switch (widget.profileIndex) {
      case 1:
        return 'Bienvenue ${widget.prenom} ! Cet avatar représentera ton profil enseignant sur yikri.';
      case 2:
        return 'Bienvenue ${widget.prenom} ! Cet avatar apparaîtra sur ton espace parent pour suivre ton enfant.';
      default:
        return 'Bienvenue ${widget.prenom} ! Choisis ton avatar — il t\'accompagnera partout sur yikri.';
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onCommencer() async {
    final avatar = _avatars[_selectedAvatar]['emoji'] as String;
    final role = ['eleve', 'enseignant', 'parent'][widget.profileIndex];

    await AppService().saveProfile(UserProfile(
      prenom: widget.prenom,
      nom: widget.nom,
      avatar: avatar,
      classe: widget.classe,
      role: role,
      matiere: widget.matiere,
      creditsInfo: CreditsInfo(dateInscription: DateTime.now()),
    ));
    if (!mounted) return;

    Widget destination;
    switch (widget.profileIndex) {
      case 1:
        // FIX: enseignant va vers EnseignantScreen
        destination = EnseignantScreen();
        break;
      case 2:
        // FIX: parent va vers ParentScreen
        destination = ParentScreen();
        break;
      default:
        // Élève va vers HomeScreen avec les vraies données
        destination = HomeScreen(
          prenom: widget.prenom,
          avatar: avatar,
          classe: widget.classe, // FIX: classe réelle transmise
        );
    }

    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => destination,
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
      (route) => false,
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
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSageWelcome(),
                      const SizedBox(height: 20),
                      _buildAvatarPreview(),
                      const SizedBox(height: 20),
                      Text('CHOISIR MON AVATAR',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text2,
                              letterSpacing: 0.5)),
                      const SizedBox(height: 10),
                      _buildAvatarGrid(),
                      const SizedBox(height: 20),
                      _buildCreditsGift(),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _onCommencer,
                          child: Text(
                            'Commencer avec Le Sage →',
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 14, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
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
      color: AppColors.dark2,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 16,
        right: 16,
        bottom: 18,
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
                  borderRadius: BorderRadius.circular(9)),
              child:
                  const Icon(Icons.arrow_back, color: Colors.white54, size: 16),
            ),
          ),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Mon avatar',
                style: GoogleFonts.sora(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
            Text('$_profileTitle · Étape 2/2',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 11, color: Colors.white.withOpacity(0.4))),
          ]),
          const Spacer(),
          Row(
            children: List.generate(
                2,
                (index) => Container(
                      margin: const EdgeInsets.only(left: 4),
                      width: 24,
                      height: 4,
                      decoration: BoxDecoration(
                        color: index == 1
                            ? AppColors.greenMid
                            : Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    )),
          ),
        ],
      ),
    );
  }

  Widget _buildSageWelcome() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: AppColors.dark, borderRadius: BorderRadius.circular(14)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [AppColors.goldMid, AppColors.gold],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(18),
          ),
          child:
              const Center(child: Text('🧙', style: TextStyle(fontSize: 16))),
        ),
        const SizedBox(width: 10),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('LE SAGE',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.goldMid,
                    letterSpacing: 0.5)),
            const SizedBox(height: 4),
            Text(_sageMessage,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.82),
                    height: 1.6)),
          ]),
        ),
      ]),
    );
  }

  Widget _buildAvatarPreview() {
    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          color: AppColors.greenLight,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.greenMid, width: 2),
          boxShadow: [
            BoxShadow(
                color: AppColors.greenMid.withOpacity(0.2),
                blurRadius: 16,
                spreadRadius: 2)
          ],
        ),
        child: Center(
          child: Text(_avatars[_selectedAvatar]['emoji'],
              style: const TextStyle(fontSize: 44)),
        ),
      ),
    );
  }

  Widget _buildAvatarGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6, crossAxisSpacing: 8, mainAxisSpacing: 8),
      itemCount: _avatars.length,
      itemBuilder: (context, index) {
        final isSelected = _selectedAvatar == index;
        return GestureDetector(
          onTap: () => setState(() => _selectedAvatar = index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.greenLight : AppColors.white,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                  color: isSelected ? AppColors.greenMid : AppColors.border,
                  width: 1.5),
            ),
            child: Center(
                child: Text(_avatars[index]['emoji'],
                    style: const TextStyle(fontSize: 24))),
          ),
        );
      },
    );
  }

  Widget _buildCreditsGift() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.goldLight,
        border: Border.all(color: AppColors.gold.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('⭐', style: TextStyle(fontSize: 20)),
        const SizedBox(width: 10),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('20 crédits de bienvenue !',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gold)),
          const SizedBox(height: 3),
          Text(
              'Plus que 10 crédits supplémentaires pour débloquer tes premières réductions sur les cours.',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 12, color: AppColors.gold, height: 1.5)),
        ])),
      ]),
    );
  }
}
