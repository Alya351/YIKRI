import 'package:flutter/material.dart';
import '../../core/services/app_service.dart';
import '../../core/theme/app_theme.dart';
import '../enseignant/enseignant_screen.dart';
import 'avatar_screen.dart';

class RegisterScreen extends StatefulWidget {
  final int profileIndex;
  const RegisterScreen({super.key, required this.profileIndex});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _prenomController = TextEditingController();
  final _nomController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedClasse = '6ème';
  String _selectedMatiere = 'Mathématiques';
  bool _obscurePassword = true;

  final List<String> _classes = [
    '6ème',
    '5ème',
    '4ème',
    '3ème',
    '2nde',
    '1ère A',
    '1ère C',
    '1ère D',
    'Terminale A',
    'Terminale C',
    'Terminale D',
  ];
  final List<String> _matieres = [
    'Mathématiques',
    'SVT',
    'Physique-Chimie',
    'Français',
    'Histoire-Géo',
    'Philosophie',
    'Anglais',
  ];

  // Titre affiché selon le profil
  String get _profileTitle =>
      ['Élève', 'Enseignant', 'Parent'][widget.profileIndex];

  // Message du Sage selon le profil
  String get _sageHint {
    switch (widget.profileIndex) {
      case 1:
        return 'En tant qu\'enseignant, tu pourras publier tes cours et suivre la progression de tes élèves.';
      case 2:
        return 'En tant que parent, tu pourras suivre en temps réel la progression scolaire de ton enfant.';
      default:
        return 'Le Sage va te préparer un plan de révision adapté à ta classe dès ton inscription.';
    }
  }

  @override
  void dispose() {
    _prenomController.dispose();
    _nomController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (_prenomController.text.isEmpty ||
        _nomController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Remplis tous les champs pour continuer',
            style: TextStyle(fontFamily: 'PlusJakartaSans')),
        backgroundColor: AppColors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
      return;
    }

    if (widget.profileIndex == 1) {
      await AppService().saveProfile(UserProfile(
        prenom: _prenomController.text.trim(),
        nom: _nomController.text.trim(),
        avatar: '🎓',
        classe: 'Enseignant',
        role: 'enseignant',
        matiere: _selectedMatiere,
        creditsInfo: CreditsInfo(dateInscription: DateTime.now()),
      ));
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const EnseignantScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 400),
        ),
        (route) => false,
      );
      return;
    }

    Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => AvatarScreen(
        prenom: _prenomController.text,
        nom: _nomController.text,
        profileIndex: widget.profileIndex,
        classe: widget.profileIndex == 0
            ? _selectedClasse
            : widget.profileIndex == 1
                ? 'Enseignant'
                : 'Parent',
        matiere: widget.profileIndex == 1 ? _selectedMatiere : '',
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          SlideTransition(
        position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
            .animate(animation),
        child: child,
      ),
      transitionDuration: const Duration(milliseconds: 400),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSageHint(_sageHint),
                  const SizedBox(height: 16),
                  _buildField(
                      label: 'PRÉNOM',
                      hint: 'Aminata',
                      controller: _prenomController),
                  _buildField(
                      label: 'NOM',
                      hint: 'Ouédraogo',
                      controller: _nomController),
                  _buildField(
                      label: 'NUMÉRO DE TÉLÉPHONE',
                      hint: '+226 XX XX XX XX',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone),
                  _buildPasswordField(),
                  // Classe uniquement pour les élèves
                  if (widget.profileIndex == 0) _buildClasseField(),
                  if (widget.profileIndex == 1) _buildMatiereField(),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: _onSubmit, child: const Text('Continuer →')),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text('Retour',
                          style: TextStyle(fontFamily: 'PlusJakartaSans', 
                              fontSize: 13, color: AppColors.text3)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
            Text('Créer mon compte',
                style: TextStyle(fontFamily: 'Sora', 
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
            Text(widget.profileIndex == 1
                ? '$_profileTitle · Profil professionnel'
                : '$_profileTitle · Étape 1/2',
                style: TextStyle(fontFamily: 'PlusJakartaSans', 
                    fontSize: 11, color: Colors.white.withOpacity(0.4))),
          ]),
          const Spacer(),
          Row(
            children: List.generate(
                widget.profileIndex == 1 ? 1 : 2,
                (index) => Container(
                      margin: const EdgeInsets.only(left: 4),
                      width: 24,
                      height: 4,
                      decoration: BoxDecoration(
                        color: index == 0
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

  Widget _buildField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: TextStyle(fontFamily: 'PlusJakartaSans', 
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.text2,
                letterSpacing: 0.5)),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style:
              TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 13, color: AppColors.text),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontFamily: 'PlusJakartaSans', 
                fontSize: 13, color: AppColors.text3),
            filled: true,
            fillColor: AppColors.white,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide:
                    const BorderSide(color: AppColors.border, width: 1.5)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide:
                    const BorderSide(color: AppColors.border, width: 1.5)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide:
                    const BorderSide(color: AppColors.greenMid, width: 1.5)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
          ),
        ),
      ]),
    );
  }

  Widget _buildPasswordField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('MOT DE PASSE',
            style: TextStyle(fontFamily: 'PlusJakartaSans', 
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.text2,
                letterSpacing: 0.5)),
        const SizedBox(height: 5),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          style:
              TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 13, color: AppColors.text),
          decoration: InputDecoration(
            hintText: '••••••••',
            hintStyle: TextStyle(fontFamily: 'PlusJakartaSans', 
                fontSize: 13, color: AppColors.text3),
            filled: true,
            fillColor: AppColors.white,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide:
                    const BorderSide(color: AppColors.border, width: 1.5)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide:
                    const BorderSide(color: AppColors.border, width: 1.5)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide:
                    const BorderSide(color: AppColors.greenMid, width: 1.5)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
            suffixIcon: GestureDetector(
              onTap: () => setState(() => _obscurePassword = !_obscurePassword),
              child: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.text3,
                  size: 18),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildClasseField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('MA CLASSE',
            style: TextStyle(fontFamily: 'PlusJakartaSans', 
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.text2,
                letterSpacing: 0.5)),
        const SizedBox(height: 5),
        DropdownButtonFormField<String>(
          value: _selectedClasse,
          style:
              TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 13, color: AppColors.text),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.white,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide:
                    const BorderSide(color: AppColors.border, width: 1.5)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide:
                    const BorderSide(color: AppColors.border, width: 1.5)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide:
                    const BorderSide(color: AppColors.greenMid, width: 1.5)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
          ),
          items: _classes
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
          onChanged: (val) {
            if (val != null) setState(() => _selectedClasse = val);
          },
        ),
      ]),
    );
  }

  Widget _buildMatiereField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('MA MATIÈRE PRINCIPALE',
            style: TextStyle(fontFamily: 'PlusJakartaSans',
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.text2,
                letterSpacing: 0.5)),
        const SizedBox(height: 5),
        DropdownButtonFormField<String>(
          value: _selectedMatiere,
          style:
              TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 13, color: AppColors.text),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.white,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide:
                    const BorderSide(color: AppColors.border, width: 1.5)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide:
                    const BorderSide(color: AppColors.border, width: 1.5)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide:
                    const BorderSide(color: AppColors.greenMid, width: 1.5)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
          ),
          items: _matieres
              .map((m) => DropdownMenuItem(value: m, child: Text(m)))
              .toList(),
          onChanged: (val) {
            if (val != null) setState(() => _selectedMatiere = val);
          },
        ),
      ]),
    );
  }

  Widget _buildSageHint(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.greenLight,
        border: Border.all(color: AppColors.green.withOpacity(0.15)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('🧙', style: TextStyle(fontSize: 14)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text,
              style: TextStyle(fontFamily: 'PlusJakartaSans', 
                  fontSize: 12, color: AppColors.green, height: 1.5)),
        ),
      ]),
    );
  }
}
