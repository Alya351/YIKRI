import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';

enum DefiStatut { enCours, echoue, reussi }

class DefiScreen extends StatefulWidget {
  final String classe;
  final String prenom;
  const DefiScreen({
    super.key,
    this.classe = 'Terminale D',
    this.prenom = 'Élève',
  });

  @override
  State<DefiScreen> createState() => _DefiScreenState();
}

class _DefiScreenState extends State<DefiScreen>
    with TickerProviderStateMixin {
  int _tentative = 1;
  int? _reponseSelectionnee;
  DefiStatut _statut = DefiStatut.enCours;
  late AnimationController _controller;
  late AnimationController _shakeController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _shakeAnimation;

  // Défis par tentative
  final List<Map<String, dynamic>> _defis = [
    {
      'question': 'Quelles sont les solutions de l\'équation x² - 5x + 6 = 0 ?',
      'options': ['x = 1 et x = 6', 'x = 2 et x = 3', 'x = -2 et x = -3', 'Pas de solution'],
      'bonne': 1,
      'indice': 'Cherche deux nombres dont le produit est 6 et la somme est 5.',
    },
    {
      'question': 'Cherche deux nombres dont le produit est 6 et la somme est 5. Ces deux nombres sont les solutions. Lesquels ?',
      'options': ['1 et 6', '2 et 3', '-1 et -6', '3 et 4'],
      'bonne': 1,
      'indice': 'Pense : 2 × 3 = 6 et 2 + 3 = 5. Est-ce que ça t\'aide ?',
    },
    {
      'question': 'Si 2 × 3 = 6 et 2 + 3 = 5, alors les solutions de x² - 5x + 6 = 0 sont :',
      'options': ['x = 1 et x = 5', 'x = 2 et x = 3', 'x = 0 et x = 6', 'x = -2 et x = -3'],
      'bonne': 1,
      'indice': '',
    },
  ];

  Map<String, dynamic> get _defiActuel =>
      _defis[(_tentative - 1).clamp(0, _defis.length - 1)];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 8).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _selectionnerReponse(int index) {
    if (_statut != DefiStatut.enCours) return;
    setState(() => _reponseSelectionnee = index);
  }

  void _valider() {
    if (_reponseSelectionnee == null) return;

    if (_reponseSelectionnee == _defiActuel['bonne']) {
      setState(() => _statut = DefiStatut.reussi);
    } else {
      _shakeController.forward(from: 0);
      setState(() => _statut = DefiStatut.echoue);
    }
  }

  void _nouveauDefi() {
    _controller.reset();
    setState(() {
      _tentative++;
      _reponseSelectionnee = null;
      _statut = DefiStatut.enCours;
    });
    _controller.forward();
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
                padding: const EdgeInsets.all(15),
                child: Column(
                  children: [
                    _buildQuestionCard(),
                    const SizedBox(height: 12),
                    if (_statut == DefiStatut.echoue) _buildSageCorrection(),
                    if (_statut == DefiStatut.reussi) _buildSageSuccess(),
                    const SizedBox(height: 12),
                    _buildActionButton(),
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
      color: AppColors.dark2,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 14,
        left: 15,
        right: 15,
        bottom: 18,
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
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(Icons.arrow_back,
                      color: Colors.white54, size: 16),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Défi du Sage',
                style: GoogleFonts.sora(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.greenMid.withOpacity(0.15),
                  border: Border.all(
                      color: AppColors.greenMid.withOpacity(0.25)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'MATHS · +5 crédits',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.greenMid,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Citation Le Sage
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              border: Border(
                  left: BorderSide(color: AppColors.greenMid, width: 2)),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
            child: Text(
              '"On n\'apprend pas en regardant — on apprend en faisant. À toi de jouer."',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: Colors.white.withOpacity(0.55),
                fontStyle: FontStyle.italic,
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Indicateur de tentative
          Row(
            children: [
              Text(
                'Tentative $_tentative',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
              const Spacer(),
              Row(
                children: List.generate(3, (i) {
                  return Container(
                    margin: const EdgeInsets.only(left: 4),
                    width: 24,
                    height: 4,
                    decoration: BoxDecoration(
                      color: i < _tentative
                          ? AppColors.greenMid
                          : Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard() {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        final shake = _statut == DefiStatut.echoue
            ? _shakeAnimation.value *
                (0.5 - _shakeController.value).sign
            : 0.0;
        return Transform.translate(
          offset: Offset(shake, 0),
          child: child,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.border, width: 1.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'QUESTION',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.text3,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _defiActuel['question'],
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 14),
            // Options
            ...List.generate(
              (_defiActuel['options'] as List).length,
              (index) => _buildOption(index),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(int index) {
    final options = _defiActuel['options'] as List;
    final bonne = _defiActuel['bonne'] as int;
    final label = ['A', 'B', 'C', 'D'][index];

    Color bgColor = AppColors.background;
    Color borderColor = AppColors.border;
    Color textColor = AppColors.text;
    Color circleColor = AppColors.border;
    Color circleTextColor = AppColors.text3;
    Widget? circleChild;

    if (_statut != DefiStatut.enCours && _reponseSelectionnee == index) {
      if (index == bonne) {
        bgColor = AppColors.greenLight;
        borderColor = AppColors.greenMid;
        textColor = AppColors.green;
        circleColor = AppColors.greenMid;
        circleTextColor = Colors.white;
        circleChild = const Icon(Icons.check, size: 11, color: Colors.white);
      } else {
        bgColor = AppColors.redLight;
        borderColor = AppColors.red;
        textColor = AppColors.red;
        circleColor = AppColors.red;
        circleTextColor = Colors.white;
        circleChild = const Icon(Icons.close, size: 11, color: Colors.white);
      }
    } else if (_reponseSelectionnee == index &&
        _statut == DefiStatut.enCours) {
      bgColor = AppColors.greenLight;
      borderColor = AppColors.greenMid;
      circleColor = AppColors.greenMid;
      circleTextColor = Colors.white;
    }

    return GestureDetector(
      onTap: () => _selectionnerReponse(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor, width: 1.5),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: circleColor == AppColors.border
                    ? Colors.transparent
                    : circleColor,
                border: Border.all(color: circleColor, width: 1.5),
              ),
              child: circleChild ??
                  Center(
                    child: Text(
                      label,
                      style: GoogleFonts.sora(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: circleTextColor,
                      ),
                    ),
                  ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                options[index],
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: textColor,
                  fontWeight: _reponseSelectionnee == index
                      ? FontWeight.w600
                      : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSageCorrection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.dark,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.goldMid, AppColors.gold],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Center(
                    child: Text('🧙', style: TextStyle(fontSize: 14))),
              ),
              const SizedBox(width: 8),
              Text(
                'LE SAGE',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.goldMid,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Ce n\'est pas la bonne réponse. ${_defiActuel['indice']} Je ne te donne pas la correction — mais je vais reformuler le défi pour t\'aider à trouver par toi-même.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: Colors.white.withOpacity(0.82),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSageSuccess() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.greenLight,
        border: Border.all(color: AppColors.greenMid.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.greenMid, AppColors.green],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Center(
                    child: Text('🧙', style: TextStyle(fontSize: 14))),
              ),
              const SizedBox(width: 8),
              Text(
                'LE SAGE',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.green,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.green,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '+5 crédits !',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Excellent ! Tu as trouvé par toi-même — c\'est exactement comme ça qu\'on apprend vraiment. Les solutions de x² - 5x + 6 = 0 sont x = 2 et x = 3. Continue comme ça.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: AppColors.green,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    if (_statut == DefiStatut.enCours) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _reponseSelectionnee != null ? _valider : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.green,
            disabledBackgroundColor: AppColors.border,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13)),
          ),
          child: Text(
            'Valider ma réponse →',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _reponseSelectionnee != null
                  ? Colors.white
                  : AppColors.text3,
            ),
          ),
        ),
      );
    }

    if (_statut == DefiStatut.echoue) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _tentative < _defis.length ? _nouveauDefi : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.dark2,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13)),
          ),
          child: Text(
            _tentative < _defis.length
                ? 'Nouveau défi reformulé →'
                : 'Voir la correction',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    // Réussi
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.green,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13)),
            ),
            child: Text(
              'Retour à l\'accueil',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              setState(() {
                _tentative = 1;
                _reponseSelectionnee = null;
                _statut = DefiStatut.enCours;
              });
              _controller.reset();
              _controller.forward();
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: AppColors.border, width: 1.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13)),
            ),
            child: Text(
              'Nouveau défi',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.text2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}