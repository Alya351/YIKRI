import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../auth/register_screen.dart';
import '../auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  int _selectedProfile = -1;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<Map<String, dynamic>> _profiles = [
    {
      'icon': '📚',
      'title': 'Élève',
      'subtitle': 'Apprends et progresse',
      'index': 0
    },
    {
      'icon': '🎓',
      'title': 'Enseignant',
      'subtitle': 'Publie tes cours',
      'index': 1
    },
    {
      'icon': '👨‍👧',
      'title': 'Parent',
      'subtitle': 'Suis la progression',
      'index': 2
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onContinue() {
    if (_selectedProfile == -1) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Choisis ton profil pour continuer',
            style: TextStyle(fontFamily: 'PlusJakartaSans')),
        backgroundColor: AppColors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
      return;
    }
    final destination = RegisterScreen(profileIndex: _selectedProfile);
    Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (c, a, b) => destination,
      transitionsBuilder: (c, a, b, child) => SlideTransition(
        position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
            .animate(a),
        child: child,
      ),
      transitionDuration: const Duration(milliseconds: 400),
    ));
  }

  void _goToLogin() {
    // FIX: était un TODO vide
    Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (c, a, b) => const LoginScreen(),
      transitionsBuilder: (c, a, b, child) => SlideTransition(
        position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
            .animate(a),
        child: child,
      ),
      transitionDuration: const Duration(milliseconds: 400),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark2,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
          children: [
            // Glow background
            Positioned(
              top: -50, right: -50,
              child: Container(
                width: 250, height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    AppColors.goldMid.withOpacity(0.12),
                    Colors.transparent,
                  ]),
                ),
              ),
            ),
            Positioned(
              bottom: 100, left: -80,
              child: Container(
                width: 200, height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    AppColors.greenMid.withOpacity(0.1),
                    Colors.transparent,
                  ]),
                ),
              ),
            ),
            Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFFF0F5F2), Color(0xFFFFFFFF)],
                        ),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                      ),
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Container(
                              width: 4, height: 20,
                              decoration: BoxDecoration(
                                color: AppColors.greenMid,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text('Je suis...',
                                style: TextStyle(fontFamily: 'Sora', 
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.text)),
                          ]),
                          const SizedBox(height: 16),
                          ...(_profiles.map((p) => _buildProfileChoice(
                                icon: p['icon'],
                                title: p['title'],
                                subtitle: p['subtitle'],
                                index: p['index'],
                              ))),
                          const Spacer(),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _onContinue,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.green,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 4,
                                shadowColor: AppColors.greenMid.withOpacity(0.4),
                              ),
                              child: Text('Commencer →',
                                  style: TextStyle(fontFamily: 'Sora', 
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  )),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Center(
                            child: GestureDetector(
                              onTap: _goToLogin,
                              child: RichText(
                                text: TextSpan(children: [
                                  TextSpan(
                                    text: 'Déjà un compte ? ',
                                    style: TextStyle(fontFamily: 'PlusJakartaSans', 
                                        fontSize: 13, color: AppColors.text3),
                                  ),
                                  TextSpan(
                                    text: 'Se connecter',
                                    style: TextStyle(fontFamily: 'PlusJakartaSans', 
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.greenMid),
                                  ),
                                ]),
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
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: AppColors.dark2,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 24,
        left: 20,
        right: 20,
        bottom: 24,
      ),
      child: Column(
        children: [
          RichText(
            text: TextSpan(children: [
              TextSpan(
                  text: 'yi',
                  style: TextStyle(fontFamily: 'Sora', 
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -1)),
              TextSpan(
                  text: 'k',
                  style: TextStyle(fontFamily: 'Sora', 
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: AppColors.goldMid,
                      letterSpacing: -1)),
              TextSpan(
                  text: 'ri',
                  style: TextStyle(fontFamily: 'Sora', 
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -1)),
            ]),
          ),
          const SizedBox(height: 4),
          Text('Apprendre partout · Progresser toujours',
              style: TextStyle(fontFamily: 'PlusJakartaSans', 
                  fontSize: 11, color: Colors.white.withOpacity(0.35))),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.greenMid.withOpacity(0.15),
              border: Border.all(color: AppColors.greenMid.withOpacity(0.25)),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: AppColors.greenMid)),
              const SizedBox(width: 6),
              Text('LE SAGE',
                  style: TextStyle(fontFamily: 'PlusJakartaSans', 
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.greenMid,
                      letterSpacing: 0.5)),
            ]),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(14),
                bottomLeft: Radius.circular(14),
                bottomRight: Radius.circular(14),
              ),
            ),
            child: Text(
              'Bonjour ! Je suis Le Sage, ton mentor sur yikri. Dis-moi — tu es élève, enseignant ou parent ?',
              style: TextStyle(fontFamily: 'PlusJakartaSans', 
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.82),
                  height: 1.65),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileChoice(
      {required String icon,
      required String title,
      required String subtitle,
      required int index}) {
    final isSelected = _selectedProfile == index;
    final colors = [
      [AppColors.greenMid, AppColors.greenLight],
      [AppColors.goldMid, AppColors.goldLight],
      [const Color(0xFF5B8DEF), const Color(0xFFEEF3FF)],
    ];
    final c = colors[index];

    return GestureDetector(
      onTap: () => setState(() => _selectedProfile = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? c[1] : AppColors.white,
          border: Border.all(
              color: isSelected ? c[0] : AppColors.border,
              width: isSelected ? 2 : 1.5),
          borderRadius: BorderRadius.circular(18),
          boxShadow: isSelected ? [BoxShadow(
            color: c[0].withOpacity(0.15),
            blurRadius: 12, offset: const Offset(0, 4),
          )] : [BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8, offset: const Offset(0, 2),
          )],
        ),
        child: Row(children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: isSelected ? c[0] : AppColors.background,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(child: Text(icon, style: const TextStyle(fontSize: 24))),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontFamily: 'Sora', 
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? c[0] : AppColors.text)),
              const SizedBox(height: 3),
              Text(subtitle, style: TextStyle(fontFamily: 'PlusJakartaSans', 
                  fontSize: 12, color: AppColors.text3)),
            ],
          )),
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 24, height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? c[0] : Colors.transparent,
              border: Border.all(
                  color: isSelected ? c[0] : AppColors.border, width: 2),
            ),
            child: isSelected
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : null,
          ),
        ]),
      ),
    );
  }
}
