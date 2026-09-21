import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'notification_service.dart';

// ─── Opérateurs Mobile Money ──────────────────────────────────────────────────

class Operateur {
  final String nom;
  final String emoji;
  final String ussd;
  final Color couleur;
  const Operateur({required this.nom, required this.emoji, required this.ussd, required this.couleur});
}

const List<Operateur> operateurs = [
  Operateur(nom: 'Orange Money', emoji: '🟠', ussd: '*144#', couleur: Color(0xFFFF6B00)),
  Operateur(nom: 'Moov Money', emoji: '🔵', ussd: '*555#', couleur: Color(0xFF0057A8)),
  Operateur(nom: 'Telecel Money', emoji: '🔴', ussd: '*303#', couleur: Color(0xFFE00000)),
  Operateur(nom: 'Sank Money', emoji: '🟢', ussd: '*800#', couleur: Color(0xFF00A86B)),
];

// ─── Modal Paiement Mobile Money ──────────────────────────────────────────────

class PaiementMobileMoneyModal extends StatefulWidget {
  final int montant;
  final String description;
  final VoidCallback? onSuccess;

  const PaiementMobileMoneyModal({
    super.key,
    required this.montant,
    required this.description,
    this.onSuccess,
  });

  @override
  State<PaiementMobileMoneyModal> createState() => _PaiementMobileMoneyModalState();

  static Future<bool> show(BuildContext context, {required int montant, required String description, VoidCallback? onSuccess}) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PaiementMobileMoneyModal(montant: montant, description: description, onSuccess: onSuccess),
    );
    return result ?? false;
  }
}

class _PaiementMobileMoneyModalState extends State<PaiementMobileMoneyModal> {
  int _etape = 0; // 0=choix, 1=numero, 2=otp, 3=succes, 4=echec
  Operateur? _operateur;
  final _numeroCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  bool _loading = false;
  String _otpGenere = '';
  int _tentativesOTP = 0;
  Timer? _timer;
  int _secondes = 60;

  @override
  void dispose() {
    _numeroCtrl.dispose();
    _otpCtrl.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _demarrerTimer() {
    _secondes = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _secondes--);
      if (_secondes <= 0) { t.cancel(); setState(() => _etape = 4); }
    });
  }

  String _genererOTP() {
    final rand = Random();
    return List.generate(4, (_) => rand.nextInt(10)).join();
  }

  Future<void> _validerNumero() async {
    final num = _numeroCtrl.text.replaceAll(' ', '');
    if (num.length < 8) {
      _showSnack('Numéro invalide', erreur: true);
      return;
    }
    setState(() { _loading = true; });
    await Future.delayed(const Duration(seconds: 2)); // simulation réseau
    _otpGenere = _genererOTP();
    setState(() { _loading = false; _etape = 2; });
    _demarrerTimer();
  }

  Future<void> _validerOTP() async {
    if (_otpCtrl.text != _otpGenere) {
      _tentativesOTP++;
      if (_tentativesOTP >= 3) {
        setState(() => _etape = 4);
        return;
      }
      _showSnack('Code incorrect. ${3 - _tentativesOTP} tentative(s) restante(s)', erreur: true);
      _otpCtrl.clear();
      return;
    }
    setState(() { _loading = true; });
    await Future.delayed(const Duration(seconds: 2)); // simulation traitement
    _timer?.cancel();

    // Notifier le succès
    NotificationService().ajouterNotif(
      id: 'paiement_${DateTime.now().millisecondsSinceEpoch}',
      titre: '✅ Paiement confirmé',
      message: '${widget.montant} FCFA débités via ${_operateur?.nom}. Cours téléchargé.',
      type: NotifType.succes,
    );

    setState(() { _loading = false; _etape = 3; });
    widget.onSuccess?.call();
  }

  void _showSnack(String msg, {bool erreur = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.plusJakartaSans(fontSize: 13)),
      backgroundColor: erreur ? AppColors.red : AppColors.green,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 20, left: 18, right: 18,
        bottom: MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Barre
        Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 18),
        if (_etape == 0) _buildChoixOperateur(),
        if (_etape == 1) _buildSaisieNumero(),
        if (_etape == 2) _buildSaisieOTP(),
        if (_etape == 3) _buildSucces(),
        if (_etape == 4) _buildEchec(),
      ]),
    );
  }

  Widget _buildChoixOperateur() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Text('📱', style: TextStyle(fontSize: 22)),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Paiement Mobile Money', style: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.text)),
          Text(widget.description, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.text3)),
        ]),
        const Spacer(),
        Text('${widget.montant} FCFA', style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.green)),
      ]),
      const SizedBox(height: 20),
      Text('CHOISIR L\'OPÉRATEUR', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.text3, letterSpacing: 0.8)),
      const SizedBox(height: 10),
      ...operateurs.map((op) => GestureDetector(
        onTap: () { HapticFeedback.selectionClick(); setState(() { _operateur = op; _etape = 1; }); },
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: AppColors.background,
            border: Border.all(color: AppColors.border, width: 1.5),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: op.couleur.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Center(child: Text(op.emoji, style: const TextStyle(fontSize: 20))),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(op.nom, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.text)),
              Text('USSD : ${op.ussd}', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.text3)),
            ])),
            Icon(Icons.chevron_right, color: AppColors.text3, size: 20),
          ]),
        ),
      )),
    ]);
  }

  Widget _buildSaisieNumero() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        GestureDetector(onTap: () => setState(() => _etape = 0), child: const Icon(Icons.arrow_back, color: AppColors.text3, size: 20)),
        const SizedBox(width: 10),
        Text(_operateur?.nom ?? '', style: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.text)),
        const Spacer(),
        Text('${widget.montant} FCFA', style: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.green)),
      ]),
      const SizedBox(height: 20),
      Text('TON NUMÉRO ${_operateur?.nom.toUpperCase()}', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.text3, letterSpacing: 0.8)),
      const SizedBox(height: 10),
      Container(
        decoration: BoxDecoration(color: AppColors.background, border: Border.all(color: AppColors.border, width: 1.5), borderRadius: BorderRadius.circular(13)),
        child: TextField(
          controller: _numeroCtrl,
          keyboardType: TextInputType.phone,
          autofocus: true,
          style: GoogleFonts.sora(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.text, letterSpacing: 2),
          decoration: InputDecoration(
            hintText: '07X XXX XXX',
            hintStyle: GoogleFonts.sora(fontSize: 18, color: AppColors.text3, letterSpacing: 1),
            prefixIcon: Padding(padding: const EdgeInsets.all(14), child: Text(_operateur?.emoji ?? '📱', style: const TextStyle(fontSize: 18))),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          ),
        ),
      ),
      const SizedBox(height: 8),
      Text('Un code de confirmation sera envoyé par SMS à ce numéro.',
          style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.text3)),
      const SizedBox(height: 20),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _loading ? null : _validerNumero,
          style: ElevatedButton.styleFrom(
            backgroundColor: _operateur?.couleur ?? AppColors.green,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
          ),
          child: _loading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text('Recevoir le code →', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
        ),
      ),
    ]);
  }

  Widget _buildSaisieOTP() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        GestureDetector(onTap: () { _timer?.cancel(); setState(() => _etape = 1); }, child: const Icon(Icons.arrow_back, color: AppColors.text3, size: 20)),
        const SizedBox(width: 10),
        Text('Code de confirmation', style: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.text)),
      ]),
      const SizedBox(height: 20),
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.goldLight, border: Border.all(color: AppColors.gold.withOpacity(0.2)), borderRadius: BorderRadius.circular(12)),
        child: Column(children: [
          Text('Code SMS envoyé au ${_numeroCtrl.text}', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.gold, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          // En démo — afficher le code pour la présentation
          Text('Code démo : $_otpGenere', style: GoogleFonts.sora(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.gold, letterSpacing: 6)),
          const SizedBox(height: 2),
          Text('(Affiché uniquement en mode démo)', style: GoogleFonts.plusJakartaSans(fontSize: 9, color: AppColors.gold.withOpacity(0.6))),
        ]),
      ),
      const SizedBox(height: 16),
      // Champs OTP
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 220,
          decoration: BoxDecoration(color: AppColors.background, border: Border.all(color: AppColors.border, width: 1.5), borderRadius: BorderRadius.circular(13)),
          child: TextField(
            controller: _otpCtrl,
            keyboardType: TextInputType.number,
            maxLength: 4,
            autofocus: true,
            textAlign: TextAlign.center,
            style: GoogleFonts.sora(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.text, letterSpacing: 10),
            decoration: InputDecoration(
              hintText: '----',
              hintStyle: GoogleFonts.sora(fontSize: 28, color: AppColors.text3, letterSpacing: 8),
              border: InputBorder.none,
              counterText: '',
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
        ),
      ]),
      const SizedBox(height: 10),
      Center(child: Text(
        _secondes > 0 ? 'Expire dans $_secondes sec' : 'Code expiré',
        style: GoogleFonts.plusJakartaSans(fontSize: 12, color: _secondes > 10 ? AppColors.text3 : AppColors.red, fontWeight: FontWeight.w600),
      )),
      const SizedBox(height: 20),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _loading ? null : _validerOTP,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.green,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
          ),
          child: _loading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text('Confirmer le paiement', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
        ),
      ),
    ]);
  }

  Widget _buildSucces() {
    return Column(children: [
      const SizedBox(height: 10),
      const Text('✅', style: TextStyle(fontSize: 56)),
      const SizedBox(height: 16),
      Text('Paiement confirmé !', style: GoogleFonts.sora(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.text)),
      const SizedBox(height: 8),
      Text('${widget.montant} FCFA débités via ${_operateur?.nom}', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.text3)),
      const SizedBox(height: 6),
      Text(widget.description, style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.green, fontWeight: FontWeight.w600)),
      const SizedBox(height: 24),
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.greenLight, border: Border.all(color: AppColors.greenMid.withOpacity(0.2)), borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          const Icon(Icons.download_done_rounded, color: AppColors.green, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text('Cours téléchargé automatiquement — disponible hors ligne', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.green, fontWeight: FontWeight.w600))),
        ]),
      ),
      const SizedBox(height: 20),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.green, padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13))),
          child: Text('Accéder au cours →', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
        ),
      ),
    ]);
  }

  Widget _buildEchec() {
    return Column(children: [
      const SizedBox(height: 10),
      const Text('❌', style: TextStyle(fontSize: 56)),
      const SizedBox(height: 16),
      Text('Paiement échoué', style: GoogleFonts.sora(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.text)),
      const SizedBox(height: 8),
      Text(_secondes <= 0 ? 'Le code a expiré. Réessaie.' : 'Trop de tentatives incorrectes.', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.text3), textAlign: TextAlign.center),
      const SizedBox(height: 24),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => setState(() { _etape = 0; _operateur = null; _numeroCtrl.clear(); _otpCtrl.clear(); _tentativesOTP = 0; }),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.green, padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13))),
          child: Text('Réessayer', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
        ),
      ),
      const SizedBox(height: 10),
      TextButton(
        onPressed: () => Navigator.pop(context, false),
        child: Text('Annuler', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.text3)),
      ),
    ]);
  }
}