import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../home/home_screen.dart';
import '../enseignant/enseignant_screen.dart';
import '../parent/parent_screen.dart';
import '../onboarding/onboarding_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  int _selectedProfil = 0;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<Map<String, String>> _profils = [
    {'label': 'Élève', 'emoji': '📚'},
    {'label': 'Enseignant', 'emoji': '🎓'},
    {'label': 'Parent', 'emoji': '👨‍👧'},
  ];

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
    _phoneController.dispose();
    _passwordController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _seConnecter() async {
    if (_phoneController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Remplis tous les champs',
            style: TextStyle(fontFamily: 'PlusJakartaSans')),
        backgroundColor: AppColors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _isLoading = false);

    Widget destination;
    if (_selectedProfil == 1) {
      destination = EnseignantScreen();
    } else if (_selectedProfil == 2) {
      destination = ParentScreen();
    } else {
      destination = const HomeScreen(
          prenom: 'Aminata', avatar: '👦', classe: 'Terminale D');
    }

    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (c, a, b) => destination,
        transitionsBuilder: (c, a, b, child) =>
            FadeTransition(opacity: a, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
      (route) => false,
    );
  }

  void _goToInscription() {
    // FIX: allait en arrière (Navigator.pop) — maintenant va vers l'onboarding
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (c, a, b) => const OnboardingScreen(),
        transitionsBuilder: (c, a, b, child) => SlideTransition(
          position: Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero)
              .animate(a),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 400),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark2,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildHero(),
            Expanded(
              child: SlideTransition(
                position: _slideAnimation,
                child: Container(
                  color: AppColors.background,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProfilSelector(),
                        const SizedBox(height: 20),
                        _buildFieldLabel('NUMÉRO DE TÉLÉPHONE'),
                        const SizedBox(height: 5),
                        _buildPhoneField(),
                        const SizedBox(height: 14),
                        _buildFieldLabel('MOT DE PASSE'),
                        const SizedBox(height: 5),
                        _buildPasswordField(),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text('Mot de passe oublié ?',
                              style: TextStyle(fontFamily: 'PlusJakartaSans', 
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.greenMid)),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _seConnecter,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.green,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(13)),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2))
                                : Text('Se connecter',
                                    style: TextStyle(fontFamily: 'PlusJakartaSans', 
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white)),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: GestureDetector(
                            onTap: _goToInscription, // FIX: était Navigator.pop
                            child: RichText(
                              text: TextSpan(children: [
                                TextSpan(
                                  text: 'Pas encore de compte ? ',
                                  style: TextStyle(fontFamily: 'PlusJakartaSans', 
                                      fontSize: 13, color: AppColors.text3),
                                ),
                                TextSpan(
                                  text: 'S\'inscrire',
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHero() {
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
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -1)),
              TextSpan(
                  text: 'k',
                  style: TextStyle(fontFamily: 'Sora', 
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: AppColors.goldMid,
                      letterSpacing: -1)),
              TextSpan(
                  text: 'ri',
                  style: TextStyle(fontFamily: 'Sora', 
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -1)),
            ]),
          ),
          const SizedBox(height: 6),
          Text('Bon retour parmi nous 👋',
              style: TextStyle(fontFamily: 'PlusJakartaSans', 
                  fontSize: 14, color: Colors.white.withOpacity(0.5))),
        ],
      ),
    );
  }

  Widget _buildProfilSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('JE SUIS',
            style: TextStyle(fontFamily: 'PlusJakartaSans', 
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.text2,
                letterSpacing: 0.5)),
        const SizedBox(height: 8),
        Row(
          children: List.generate(_profils.length, (i) {
            final isActive = _selectedProfil == i;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedProfil = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.greenLight : AppColors.white,
                    border: Border.all(
                        color: isActive ? AppColors.greenMid : AppColors.border,
                        width: 1.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(children: [
                    Text(_profils[i]['emoji']!,
                        style: const TextStyle(fontSize: 20)),
                    const SizedBox(height: 4),
                    Text(_profils[i]['label']!,
                        style: TextStyle(fontFamily: 'PlusJakartaSans', 
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color:
                                isActive ? AppColors.green : AppColors.text2)),
                  ]),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(label,
        style: TextStyle(fontFamily: 'PlusJakartaSans', 
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppColors.text2,
            letterSpacing: 0.5));
  }

  Widget _buildPhoneField() {
    return TextField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 13, color: AppColors.text),
      decoration: InputDecoration(
        hintText: '+226 XX XX XX XX',
        hintStyle:
            TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 13, color: AppColors.text3),
        prefixIcon:
            const Icon(Icons.phone_outlined, size: 18, color: AppColors.text3),
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(11),
            borderSide: const BorderSide(color: AppColors.border, width: 1.5)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(11),
            borderSide: const BorderSide(color: AppColors.border, width: 1.5)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(11),
            borderSide:
                const BorderSide(color: AppColors.greenMid, width: 1.5)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 13, color: AppColors.text),
      decoration: InputDecoration(
        hintText: '••••••••',
        hintStyle:
            TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 13, color: AppColors.text3),
        prefixIcon:
            const Icon(Icons.lock_outline, size: 18, color: AppColors.text3),
        suffixIcon: GestureDetector(
          onTap: () => setState(() => _obscurePassword = !_obscurePassword),
          child: Icon(
              _obscurePassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              size: 18,
              color: AppColors.text3),
        ),
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(11),
            borderSide: const BorderSide(color: AppColors.border, width: 1.5)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(11),
            borderSide: const BorderSide(color: AppColors.border, width: 1.5)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(11),
            borderSide:
                const BorderSide(color: AppColors.greenMid, width: 1.5)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      ),
    );
  }
}